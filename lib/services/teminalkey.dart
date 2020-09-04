import 'dart:convert';
import 'dart:io';

import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/models/TerminalKey.dart';
import 'package:http/http.dart' as http;

Future<TemimalKey> setTerminal(dynamic terkey, dynamic deviceid) async {
  try {
    final String url = Configrations.base_URL + Configrations.terminalKey;
    final client = new http.Client();
    Map<String, dynamic> params = {
      "terminal_key": terkey,
      "ter_device_id": deviceid,
    };
    final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    final response = await client.post(
      url,
      headers: headers,
      body: json.encode(params),
    );
    return TemimalKey.fromJson(json.decode(response.body));
  } catch (e) {
    //  print(CustomTrace(StackTrace.current, message: url).toString());
    return TemimalKey.fromJson({});
  }
}
