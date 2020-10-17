import 'dart:convert';
import 'dart:io';

import 'package:mcncashier/helpers/LocalAPI/ProductList.dart';

class ProductsReq {
  static getProductCall(request) async {
    ProductsList product = new ProductsList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var result = await product.getProduct(
          null, data["category_id"], data["branch_id"]);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({
          "status": 200,
          "message": result.length > 0 ? "success" : "No data Found",
          "data": result
        }))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write('Exception during get saerch products: $e.');
    }
  }

  static getProductSearchCall(request) async {
    ProductsList product = new ProductsList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await product.getSeachProduct(null, data["search_text"]);
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
        ..write('Exception during get products: $e.');
    }
  }
}
