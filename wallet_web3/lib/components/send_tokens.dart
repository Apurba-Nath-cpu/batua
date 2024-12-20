import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

class SendTokensPage extends StatelessWidget {
  final String privateKey;
  final TextEditingController recipientController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  SendTokensPage({super.key, required this.privateKey});

  void sendToken() {
    String recipient = recipientController.text;
    double? amount = double.tryParse(amountController.text);

    if (recipient.isEmpty || amount == null) {
      Fluttertoast.showToast(msg: 'Please enter valid recipient and amount.');
      return;
    }

    BigInt bigIntValue = BigInt.from(amount * pow(10, 18));
    EtherAmount ethAmount = EtherAmount.fromBigInt(EtherUnit.wei, bigIntValue);
    // Convert the amount to EtherAmount
    sendTransaction(recipient, ethAmount);
  }

  void sendTransaction(String receiver, EtherAmount txValue) async {
    var apiUrl = dotenv.get("RPC_URL");
    var httpClient = http.Client();
    var ethClient = Web3Client(apiUrl, httpClient);

    EthPrivateKey credentials = EthPrivateKey.fromHex('0x$privateKey');

    EtherAmount etherAmount = await ethClient.getBalance(credentials.address);
    EtherAmount gasPrice = await ethClient.getGasPrice();

    try {
      await ethClient.sendTransaction(
        credentials,
        Transaction(
          to: EthereumAddress.fromHex(receiver),
          gasPrice: gasPrice,
          maxGas: 100000,
          value: txValue,
        ),
        chainId: 11155111,
      );

      Fluttertoast.showToast(msg: 'Transaction Successful');
    } catch (e) {
      print('Error sending transaction: $e');
      Fluttertoast.showToast(msg: 'Transaction Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Tokens'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: recipientController,
              decoration: const InputDecoration(
                labelText: 'Recipient Address',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                sendToken();
              },
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
