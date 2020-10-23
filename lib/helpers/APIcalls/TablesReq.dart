import 'dart:convert';
import 'dart:io';
import 'package:mcncashier/helpers/LocalAPI/TablesList.dart';
import 'package:mcncashier/models/Table_order.dart';

class TablesReq {
  static getTableCall(request) async {
    try {
      TablesList tablecall = new TablesList();
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await tablecall.getTables(null, data["branch_id"]);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({
          "status": 200,
          "message": res.length > 0 ? "success" : "No data Found",
          "data": res
        }))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write(jsonEncode(
            {"status": 200, "message": "Something went wrong", "data": []}));
    }
  }

  static addTableOrder(request) async {
    TablesList tablesList = new TablesList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      Table_order tables = new Table_order();
      var tabledata = data["table_order"];
      tables = Table_order.fromJson(tabledata);
      var res = await tablesList.insertTableOrder(null, tables);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({
          "status": 200,
          "message": "successfuly add table order",
        }))
        ..close();
    } catch (e) {
      print(e);
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static gettableDetails(request) async {
    TablesList tablesList = new TablesList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res =
          await tablesList.getTableDetails(data["branch_id"], data["table_id"]);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 200, "message": "success.", "data": res}))
        ..close();
    } catch (e) {
      print(e);
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode(
            {"status": 500, "message": "Something went wrong" + e.toString()}))
        ..close();
    }
  }

  static gettableOrder(request) async {
    TablesList tablesList = new TablesList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res =
          await tablesList.getTableOrders(data["table_id"]);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 200, "message": "success.", "data": res}))
        ..close();
    } catch (e) {
      print(e);
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode(
            {"status": 500, "message": "Something went wrong" + e.toString()}))
        ..close();
    }
  }
}
