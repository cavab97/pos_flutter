import 'dart:convert';
import 'dart:io';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/models/TerminalKey.dart';
import 'package:http/http.dart' as http;

Future<TemimalKey> sendTerminalKey(TemimalKey terminal) async {
  try {
    Uri url = Uri.parse(Configrations.base_URL + Configrations.terminalKey);
    print("url");
    print(url);
    final client = new http.Client();
    Map<String, dynamic> params = {
      "terminal_key": terminal.terminalKey,
      "ter_device_id": terminal.deviceid,
    };
    print(params);
    final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    final response = await client.post(
      url,
      headers: headers,
      body: json.encode(params),
    );
    print(response);
    return TemimalKey.fromJson(json.decode(response.body));
  } catch (e) {
    print(e);
    return TemimalKey.fromJson({});
  }
}
