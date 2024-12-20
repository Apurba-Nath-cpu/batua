import 'package:flutter/material.dart';
import 'package:wallet_web3/pages/create_or_import.dart';
import 'package:wallet_web3/pages/wallet_page.dart';
import 'package:wallet_web3/providers/wallet_provider.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);

    if (walletProvider.privateKey == null) {
      // If private key doesn't exist, load CreateOrImportPage
      return const CreateOrImportPage();
    } else {
      // If private key exists, load WalletPage
      return WalletPage();
    }
  }
}