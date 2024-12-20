import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> getBalances(String address, String chain) async {
  final url = Uri.http('192.168.18.32:3000', '/get_token_balance');

  print(url);

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'address': address,
      'chain': chain,
    }),
  );

  if (response.statusCode == 200) {
    return response.body;
  } else {
    print(response.body);
    throw Exception('Failed to get balances');
  }
}

Future<String> getNFTs(String address, String chain) async {
  final url = Uri.http('192.168.18.32:3000', '/get_user_nfts');

  print(url);

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'address': address,
      'chain': chain,
    }),
  );

  if (response.statusCode == 200) {
    return response.body;
  } else {
    print(response.body);
    throw Exception('Failed to get balances');
  }
}
