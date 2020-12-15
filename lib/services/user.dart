import 'dart:convert';
import 'dart:io';
import 'package:mcncashier/helpers/config.dart';
import 'package:http/http.dart' as http;
import 'package:mcncashier/services/allTablesSync.dart';

Future<dynamic> login(dynamic user) async {
  try {
    Uri url = Uri.parse(Configrations.base_URL + Configrations.login);

    final client = new http.Client();
    Map<String, dynamic> params = {
      'username': user.name,
      'user_pin': user.userPin,
      'device_type': user.deviceType,
      'device_token': user.deviceToken,
      'device_id': user.deviceId,
      'terminal_id': user.terminalId,
    };
    print(params);
    final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    final response = await client.post(
      url,
      headers: headers,
      body: json.encode(params),
    );
    print(response);
    var data = json.decode(response.body);
    await SyncAPICalls.logActivity(
        "Login", "login-user", "user", user.terminalId);
    return data;
  } catch (e) {
    print(e);
    var res = {"status": -1, "message": e.message.toString()};
    return res;
  }
}
