import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wallet_web3/utils/api_services.dart';

class NFTListPage extends StatefulWidget {
  final String address;
  final String chain;

  const NFTListPage({
    super.key,
    required this.address,
    required this.chain,
  });

  @override
  _NFTListPageState createState() => _NFTListPageState();
}

class _NFTListPageState extends State<NFTListPage> {
  List<dynamic> _nftList = [];

  @override
  void initState() {
    super.initState();
    _loadNFTList();
  }

  Future<void> _loadNFTList() async {
    _nftList = [];
    final String nfts = await getNFTs(
        "0xDC24316b9AE028F1497c275EB9192a3Ea0f67022", widget.chain);

    final jsonData = json.decode(nfts);
    if (jsonData['result'] != null && jsonData['result']['result'] != null) {
      setState(() {
        _nftList = jsonData['result']['result'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return 
    _nftList.isNotEmpty
    ? Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var nft in _nftList)
          Card(
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  nft['name'] != null ? "Name: " + nft['name'] : "No Name",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 200, // adjust the height as needed
                  child: nft['media'] != null
                      ? nft['media']['original_media_url'] != null
                          ? Image.network(
                            nft['media']['original_media_url'],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Text('No Image'),
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child; // Fully loaded image
                              } else {
                                final progress = loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ?? 1)
                                    : null; // Null if the total size is unknown
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Loading...'),
                                    LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                                    ),
                                  ],
                                );
                              }
                            },
                          )
                          : const Center(
                              child: Text('No Image'),
                            )
                      : const Center(
                          child: Text('No Image'),
                        ),
                ),
                Text(
                  '${nft['description'] ?? "No Description"}',
                ),
              ],
            ),
          ),
      ],
    )
    : const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 24.0),
        child: Text(
          'No NFTs found',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          )
        ),
      ),
    );
  }
}
