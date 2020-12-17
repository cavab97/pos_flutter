import 'dart:convert';
import 'dart:io';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:http/http.dart' as http;

class APICall {
  final client = new http.Client();
  static localapiCall(context, apiurl, stringParams) async {
    try {
      var connected = await CommunFun.checkConnectivity();
      if (connected) {
        Uri url = Uri.parse(apiurl);
        final client = new http.Client();
        final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
        final response = await client.post(
          url,
          headers: headers,
          body: jsonEncode(stringParams),
        );
        var data = json.decode(response.body);
        return data;
      } else {
        print("Internet Connection lost");
        await CommunFun.showToast(context, Strings.internet_connection_lost);
      }
    } catch (e) {
      print(e);
      CommunFun.showToast(context, e.message.toString());
      return null;
    }
  }
}
