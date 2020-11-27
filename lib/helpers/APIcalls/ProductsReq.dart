import 'dart:convert';
import 'dart:io';

import 'package:mcncashier/helpers/LocalAPI/ProductList.dart';
import 'package:mcncashier/models/PorductDetails.dart';

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
      var result = await product.getMealsProductData(data["setmeal_Id"]);
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
  static getProductSubDetails(request) async {
    ProductsList product = new ProductsList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var result = await product.getProductDetails(
          data["branch_id"],
          data["product_id"],
          data["setmeal_id"],
          data["cart_details_id"],
          data["cartID"]);
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

  static getcartproductData(request) async {
    ProductsList product = new ProductsList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var result = await product.productdData(
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

  static getcartsetMealData(request) async {
    ProductsList product = new ProductsList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var result = await product.setmealData(
        data["setmeal_id"],
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

  static getracData(request) async {
    ProductsList product = new ProductsList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var result = await product.getRacList(
        data["branch_id"],
      );
      await request.response
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

  static getboxData(request) async {
    ProductsList product = new ProductsList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var result = await product.getBoxList(data["branch_id"], data["rac_id"]);
      await request.response
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
