import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/QrScanAndGenrate.dart';
import 'package:mcncashier/helpers/APIcalls/CategoriesReq.dart';
import 'package:mcncashier/helpers/APIcalls/CustomerReq.dart';
import 'package:mcncashier/helpers/APIcalls/ProductsReq.dart';
import 'package:mcncashier/helpers/APIcalls/TablesReq.dart';

class Server {
  static createSetver(ip, context) async {
    var server = await HttpServer.bind(ip, 8080);
    print("Server running on IP : " +
        server.address.toString() +
        " On Port : " +
        server.port.toString());
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return QRCodesImagePop(ip: ip);
        });
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
      } else {
        request.response
          ..statusCode = HttpStatus.methodNotAllowed
          ..write('Unsupported request: ${request.method}.');
      }
    } catch (e) {
      print('Exception in handleRequest: $e');
    }
  }

  static handlePOST(request) async {
    print(request);
    var path = request.uri.path;
    switch (path) {
      case "/Categories":
        CategoriesReq.getcategoryCall(request);
        break;
      case "/Products":
        ProductsReq.getProductCall(request);
        break;
      case "/Search_product":
        ProductsReq.getProductSearchCall(request);
        break;
      case "/Customers":
        CustomerReq.getCustomerCall(request);
        break;
      case "/Add_Customer":
        CustomerReq.addCustomerCall(request);
        break;
      case "/Tables":
        TablesReq.getTableCall(request);
        break;
      default:
    }
  }

  static handleGet(request) {
    print(request);
  }
}
