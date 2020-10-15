import 'dart:io';

import 'package:mcncashier/components/communText.dart';

class Server {
  static createSetver(ip, context) async {
    var server = await HttpServer.bind(ip, 8080);
    print("Server running on IP : " +
        server.address.toString() +
        " On Port : " +
        server.port.toString());

    await for (var request in server) {
      handleRequest(request);
    }
  }

  static handleRequest(request) {
    try {
      if (request.method == 'GET') {
        handleGet(request);
      }
      if (request.method == 'POST') {
        handlePOST(request);
      }
    } catch (e) {
      print('Exception in handleRequest: $e');
    }
  }

  static handlePOST(request) {}
  static handleGet(request) {}
}
