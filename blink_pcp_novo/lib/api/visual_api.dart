import 'dart:io';
import 'dart:convert' as convert;
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class VisualAPI {
  static Future post() async {
    try {
      final url = Uri.parse('http://138.204.224.235:9001/socket/query');
      //final url = Uri.parse('http://localhost:9001');
      final headers = {
        // 'socket_client': '3C5B0512-81F1-4740-A5EC-54F21A24571A',
        'socket_client': 'B75E36CC-CD02-46A8-9E03-8FC5BE605FA2',
        'Content-type': 'application/json',
        'Content-Length': '2000',
        'Host': 'localhost'
      };
      final body = convert.jsonEncode({"query": "select id,nome from familia"});

      // Await the http get response, then decode the json-formatted response.
      final response = await http.post(url, headers: headers, body: body);
      // print(response);
      if (response.statusCode == 200) {
        final jsonResponse =
            convert.jsonDecode(response.body) as Map<String, dynamic>;
        // print(jsonResponse);
        return jsonResponse;
      } else {
        debugPrint('erro');
      }
    } on HttpException catch (e) {
      debugPrint(e.message);
      return [];
    }
  }
}
