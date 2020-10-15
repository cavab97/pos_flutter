import 'package:mcncashier/components/commanutils.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:wifi_ip/wifi_ip.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String statusText = "Start Server";
  startServer() async {
    setState(() {
      statusText = "Starting server on Port : 8080";
    });
    WifiIpInfo info;
    try {
      info = await WifiIp.getWifiIp;
    } on PlatformException {
      print('Failed to get broadcast IP.');
    }
    var server = await HttpServer.bind(info.ip, 8080);
    print("Server running on IP : " +
        server.address.toString() +
        " On Port : " +
        server.port.toString());
    await for (var request in server) {
      handleRequest(request);
    }
    setState(() {
      statusText = "Server running on IP : " +
          server.address.toString() +
          " On Port : " +
          server.port.toString();
    });
  }

  void handleRequest(HttpRequest request) {
    try {
      if (request.method == 'GET') {
        handleGet(request);
      }
      if (request.method == 'POST') {
        handlePOST(request);
      } else {
        // ···
      }
    } catch (e) {
      print('Exception in handleRequest: $e');
    }
    print('Request handled.');
  }

  void handlePOST(HttpRequest request) {
    print(request);
    CommonUtils.showAlertDialog(context, () {
      Navigator.of(context).pop();
    }, () {
      Navigator.of(context).pop();
    }, "Warning", request.method, "Yes", "No", true);
  }

  void handleGet(HttpRequest request) {
    print(request);
    final guess = request.uri.queryParameters['q'];
    final response = request.response;
    response.statusCode = HttpStatus.ok;
  }

  sendReq() async {
    String _host = InternetAddress.loopbackIPv4.host;
    String path = 'file.txt';
    Map jsonData = {
      'name': 'Han Solo',
      'job': 'reluctant hero',
      'BFF': 'Chewbacca',
      'ship': 'Millennium Falcon',
      'weakness': 'smuggling debts'
    };
    HttpClientRequest request = await HttpClient().post("192.168.1.115", 8080, path) /*1*/
      ..headers.contentType = ContentType.json /*2*/
      ..write(jsonEncode(jsonData)); /*3*/
    HttpClientResponse response = await request.close(); /*4*/
    await utf8.decoder.bind(response /*5*/).forEach(print);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              startServer();
            },
            child: Text(statusText),
          ),
          RaisedButton(
            onPressed: () {
              sendReq();
            },
            child: Text("Connect"),
          )
        ],
      ),
    ));
  }
}
