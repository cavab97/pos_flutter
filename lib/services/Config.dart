import 'dart:convert';
import 'package:mcncashier/helpers/config.dart';
import 'package:http/http.dart' as http;

Future<dynamic> getCongigData() async {
  try {
    Uri url = Uri.parse(Configrations.base_URL + Configrations.config);
    final client = new http.Client();
    final response = await client.post(
      url,
    );
    var data = json.decode(response.body);
    return data;
  } catch (e) {
    print(e);
    var res = {"status": -1, "message": e.message.toString()};
    return res;
  }
}
