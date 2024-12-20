import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wallet_web3/pages/verify_mnemonic_page.dart';
import 'package:wallet_web3/providers/wallet_provider.dart';


class GenerateMnemonicPage extends StatelessWidget {
  const GenerateMnemonicPage({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final String mnemonic = walletProvider.generateMnemonic();
    final List<String> mnemonicWords = mnemonic.split(' ');

    void copyToClipboard() {
      Clipboard.setData(ClipboardData(text: mnemonic));
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Mnemonic Copied to Clipboard')),
      // );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyMnemonicPage(mnemonic: mnemonic),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Mnemonic'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                Icon(Icons.warning_rounded,),
                Expanded(
                  child: const Text(
                    'Please store this mnemonic phrase safely:',
                    style: TextStyle(
                      color: Color(0xffd0b010),
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              height: 320,
              child: GridView.builder(
                itemCount: mnemonicWords.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.25
                ),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Color(0xffcccccc),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal:  8.0, vertical: 4.0),
                    margin: const EdgeInsets.all(2.0),
                    child: Center(
                      child: Text(
                        mnemonicWords[index],
                        style: const TextStyle(fontSize: 15.0),
                      ),
                    ),
                  );
                }
              ),
            ),
            const SizedBox(height: 16.0,),
            ElevatedButton.icon(
              onPressed: () {
                copyToClipboard();
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy to Clipboard'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0,),
                textStyle: const TextStyle(fontSize: 16.0),
                elevation: 16,
                shadowColor: Colors.black.withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                  side: BorderSide(color: Color(0xffdfdfdf), width: 1.2),
                ),
              ),
            ),
            const SizedBox(height: 16.0,),
          ],
        ),
      ),
    );
  }
}