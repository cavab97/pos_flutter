import 'dart:convert';
import 'dart:io';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:http/http.dart' as http;
import 'package:mcncashier/models/User.dart';

Future<dynamic> allTablesync(dynamic data) async {
  var reqdata = data;
  try {
    Uri url = Uri.parse(Configrations.base_URL + Configrations.synch_table);
    //print("url");
    print(url);
    final client = new http.Client();
    Map<String, dynamic> params = {
      'serverdatetime': reqdata.name,
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
    if (data["status"] == Constant.STATUS200) {
      return User.fromJson(data["data"]);
    } else {
      return User.fromJson({});
    }
  } catch (e) {
    print(e);
    return User.fromJson({});
  }
}
