import 'dart:convert';

import 'dart:io';

import 'package:mcncashier/helpers/LocalAPI/CategoriesList.dart';

class CategoriesReq {
  static getcategoryCall(request) async {
    try {
      CategoriesList catCall = new CategoriesList();
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await catCall.getCategories(null, data["branch_id"]);
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
        ..write('Exception during get categoryList: $e.');
    }
  }
}
