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
      print(e);
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
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
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static getsetmealSearchCall(request) async {
    ProductsList product = new ProductsList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await product.getSearchSetMealsData(
          data["search_text"], data["branch_id"]);
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
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static getProductAttributes(request) async {
    ProductsList product = new ProductsList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var result = await product.getProductAttributes(
        data["product_id"],
      );
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
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static getProductModifires(request) async {
    ProductsList product = new ProductsList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var result = await product.getProductModifiers(
        data["product_id"],
      );
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
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static getSetMeals(request) async {
    ProductsList product = new ProductsList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var result = await product.getMealsData(data["branch_id"]);
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
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static getSetmealProducts(request) async {
    ProductsList product = new ProductsList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var result = await product.getMealsProductData(data["setmeal_id"]);
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
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

//**********************************************
  //Product details
  static getProductDetails(request) async {
    ProductsList product = new ProductsList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var result = await product.getMealsProductData(data["setmeal_id"]);
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
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }
}
