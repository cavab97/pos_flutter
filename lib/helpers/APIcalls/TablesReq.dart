import 'dart:convert';
import 'dart:io';
import 'package:mcncashier/helpers/LocalAPI/TablesList.dart';

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
            {"status": 200, "message": "Something want wrong", "data": []}));
    }
  }
}
