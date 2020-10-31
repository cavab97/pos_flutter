import 'dart:convert';
import 'dart:io';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:http/http.dart' as http;

class APICalls {
  static apiCall(apiurl, context, stringParams) async {
    try {
      var connected = await CommunFun.checkConnectivity();
      if (connected) {
        print(apiurl);
        Uri url = Uri.parse(Configrations.base_URL + apiurl);
        final client = new http.Client();
        final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
        var params = json.encode(stringParams);
        print(params);
        final response = await client.post(
          url,
          headers: headers,
          body: params,
        );
        print(response);
        var data = json.decode(response.body);
        return data;
      } else {
        CommunFun.showToast(context, Strings.internet_connection_lost);
      }
    } catch (e) {
      print(e);
      CommunFun.showToast(context, e.message.toString());
      return null;
    }
  }
}
