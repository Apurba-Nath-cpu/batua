import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_web3/components/nft_balances.dart';
import 'package:wallet_web3/components/send_tokens.dart';
import 'package:wallet_web3/pages/create_or_import.dart';
import 'package:wallet_web3/providers/wallet_provider.dart';
import 'package:wallet_web3/utils/api_services.dart';
import 'package:web3dart/web3dart.dart';

import 'dart:convert';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  String walletAddress = '';
  String balance = '';
  String pvKey = '';

  @override
  void initState() {
    super.initState();
    loadWalletData();
  }

  Future<void> loadWalletData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? privateKey = prefs.getString('privateKey');
    if (privateKey != null) {
      final walletProvider = WalletProvider();
      await walletProvider.loadPrivateKey();
      EthereumAddress address = await walletProvider.getPublicKey(privateKey);
      print(address.hex);
      setState(() {
        walletAddress = address.hex;
        pvKey = privateKey;
      });
      print(pvKey);
      String response = await getBalances(address.hex, '0x1');
      dynamic data = json.decode(response);
      String newBalance = '0';
      if(data['result'] != null && data['result']['balance'] != null) {
        newBalance = data['result']['balance'];
      }

      String latestBalanceInUnit = formatWei(newBalance);

      setState(() {
        balance = latestBalanceInUnit;
      });
    }
  }

  String formatWei(String iwei) {
    // Constants
    BigInt wei = BigInt.parse(iwei);
    BigInt oneGWei = BigInt.from(1000000000); // 10^9
    BigInt oneETH = BigInt.from(1000000000000000000); // 10^18

    print(wei);
    print(wei / oneGWei);
    print(wei / oneETH);

    // Convert to GWei or ETH
    if (BigInt.parse('${iwei}000') < oneGWei) {
      return '${wei.toString()} Wei'; // For values smaller than 1 GWei
    } else if (BigInt.parse('${iwei}000') < oneETH) {
      // Convert to GWei, and format to 4 decimals for smaller sizes
      double gWeiValue = wei.toDouble() / oneGWei.toDouble();
      String formatted = removeTrailingZeros(gWeiValue.toStringAsFixed(6));
      return '$formatted GWei';
    } else {
      // Convert to ETH, and format to 4 decimals
      double ethValue = wei.toDouble() / oneETH.toDouble();
      String formatted = removeTrailingZeros(ethValue.toStringAsFixed(4));
      return '$formatted ETH';
    }
  }

  String removeTrailingZeros(String input) {
  // Remove trailing zeros after the decimal point
  if (input.contains('.')) {
    input = input.replaceAll(RegExp(r'0*$'), '');  // Remove trailing zeros
    if (input.endsWith('.')) {
      input = input.substring(0, input.length - 1);  // Remove the dot if it's the last character
    }
  }
  return input;
}

  void copyAddress(String address) {
    if (address.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: address));
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('privateKey');
    // ignore: use_build_context_synchronously
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateOrImportPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12.0,
                  children: [
                    const Text(
                      'Wallet Address',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.copy_rounded,
                        size: 24.0,
                      ),
                      onPressed: () {
                        copyAddress(walletAddress);
                      }
                    )
                  ],
                ),
                const SizedBox(height: 8.0),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Color(0xffc0c0d0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    walletAddress,
                    style: const TextStyle(
                      fontSize: 20.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 18.0),
                const Text(
                  'Balance',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  balance,
                  style: const TextStyle(
                    fontSize: 20.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  FloatingActionButton(
                    heroTag: 'sendButton', // Unique tag for send button
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SendTokensPage(privateKey: pvKey)),
                      );
                    },
                    child: const Icon(Icons.send),
                  ),
                  const SizedBox(height: 8.0),
                  const Text('Send'),
                ],
              ),
              Column(
                children: [
                  FloatingActionButton(
                    heroTag: 'refreshButton', // Unique tag for send button
                    onPressed: () {
                      setState(() {
                        // Update any necessary state variables or perform any actions to refresh the widget
                        loadWalletData();
                      });
                    },
                    child: const Icon(Icons.replay_outlined),
                  ),
                  const SizedBox(height: 8.0),
                  const Text('Refresh'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30.0),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Colors.blue,
                    tabs: [
                      Tab(text: 'Assets'),
                      Tab(text: 'NFTs'),
                      Tab(text: 'Options'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Assets Tab
                        Column(
                          children: [
                            Card(
                              margin: const EdgeInsets.all(16.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Sepolia ETH',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 24.0,
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        balance,
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        // NFTs Tab
                        SingleChildScrollView(
                            child: NFTListPage(
                                address: walletAddress, chain: '0x1')),
                        // Activities Tab
                        Center(
                          child: ListTile(
                            titleAlignment: ListTileTitleAlignment.center,
                            leading: const Icon(Icons.logout),
                            title: const Text('Logout'),
                            onTap: () async {
                              await logout();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
