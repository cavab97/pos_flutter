import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:mcncashier/helpers/LocalAPI/OrdersList.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Order.dart';

class OrdersReq {
  static getcurrentOrders(request) async {
    OrdersList order = new OrdersList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await order.getcurrentOrders(data["order_id"]);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 200, "message": "success.", "data": res}))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something want wrong"}))
        ..close();
    }
  }

  static getLastOrderIds(request) async {
    OrdersList order = new OrdersList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await order.getLastids(data["terminal_id"]);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 200, "message": "success.", "data": res}))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something want wrong"}))
        ..close();
    }
  }

  static placeOrder(request) async {
     OrdersList order = new OrdersList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      Orders orderdata = Orders.fromJson(data["order"]); 
      
      var res = await order.placeOrder(orderdata);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 200, "message": "success.", "data": res}))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something want wrong"}))
        ..close();
    }
  }
}
