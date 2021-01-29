import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/app/app_config.dart';
import 'package:http/http.dart' as http;

class APICalls {
  static apiCall(apiurl, context, stringParams) async {
    try {
      var connected = await CommunFun.checkConnectivity();
      if (connected) {
        //print(apiurl);
        Uri url = Uri.parse(Configrations.base_URL + apiurl);
        final client = new http.Client();
        final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
        var params = json.encode(stringParams);
        //print(params);
        final response = await client.post(
          url,
          headers: headers,
          body: params,
        );
        if (response.statusCode == 500) {
          print('code error in laravel, check log in laravel');
          return [];
        } else if (response.statusCode == 404) {
          print(apiurl + ' no found');
          return [];
        } else {
          var data = json.decode(response.body);
          return data;
        }
      } else {
        CommunFun.showToast(context, Strings.internetConnectionLost);
      }
    } catch (e) {
      print(e);
      //CommunFun.showToast(context, e.message.toString());
      return [];
    }
  }

  static getDataCall(apiurl, context, stringParams,
      [int timeoutSeconds]) async {
    try {
      var connected = await CommunFun.checkConnectivity();
      if (connected) {
        //print(apiurl);
        Uri url = Uri.parse(Configrations.base_URL + apiurl);
        final client = new http.Client();
        final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
        var params = json.encode(stringParams);
        //print(params);
        final response = await client
            .post(
              url,
              headers: headers,
              body: params,
            )
            .timeout(Duration(seconds: (timeoutSeconds ?? 3)));
        if (response.statusCode == 500) {
          print('code error in laravel, check log in laravel');
          return [];
        } else if (response.statusCode == 404) {
          print(apiurl + ' no found');
          return [];
        } else if (response.statusCode == 405) {
          print('get/post, method no allow');
          return [];
        } else {
          var data = json.decode(response.body);
          return data;
        }
      } else {
        CommunFun.showToast(context, Strings.internetConnectionLost);
      }
    } on TimeoutException catch (e) {
      print('request timeout');
      print(e);
    } catch (e) {
      print(e);
      //CommunFun.showToast(context, e.message.toString());
      return [];
    }
  }
}
