import 'dart:convert';
import 'dart:io';

import 'package:mcncashier/helpers/config.dart';
import 'package:http/http.dart' as http;

class APICalls {
  static apiCall(apiurl, context, stringParams) async {
    try {
      print(apiurl);
      print(stringParams);
      Uri url = Uri.parse(Configrations.base_URL + apiurl);
      final client = new http.Client();
      final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
      final response = await client.post(
        url,
        headers: headers,
        body: json.encode(stringParams),
      );
      print(response);
      var data = json.decode(response.body);
      return data;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
