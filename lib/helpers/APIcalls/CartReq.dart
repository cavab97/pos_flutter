import 'dart:convert';
import 'dart:io';
import 'package:mcncashier/helpers/LocalAPI/Cart.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/mst_sub_cart_details.dart';
import 'package:mcncashier/models/saveOrder.dart';

class CartReq {
  static addCart(request) async {
    Cartlist cartlist = new Cartlist();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      MST_Cart cart = MST_Cart.fromJson(data["cart_data"]);
      var res = await cartlist.addcart(null, cart);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({
          "status": 200,
          "message": "successfuly added cart",
          "cart_id": res
        }))
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

  static addSaveOrder(request) async {
    Cartlist cartlist = new Cartlist();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      SaveOrder order = SaveOrder.fromJson(jsonDecode(data["save_order"]));
      var res = await cartlist.addSaveOrder(null, order, data["table_id"]);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({
          "status": 200,
          "message": "successfuly added save Order",
          "save_order_id": res
        }))
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

  static addCartDetails(request) async {
    Cartlist cartlist = new Cartlist();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      MSTCartdetails details = MSTCartdetails.fromJson(data["cart_details"]);
      var res = await cartlist.addintoCartDetails(null, details);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({
          "status": 200,
          "message": "successfuly added cart details.",
          "detail_id": res
        }))
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

  static addSubCartDetails(request) async {
    Cartlist cartlist = new Cartlist();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      List<MSTSubCartdetails> details = jsonDecode(data["cart_details"]);
      var res = await cartlist.addsubCartData(details);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({
          "status": 200,
          "message": "successfuly added sub cart details",
        }))
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

  static cartItemList(request) async {
    Cartlist cartlist = new Cartlist();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await cartlist.getCartItem(data["cart_id"]);
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

  static getSaveOrder(request) async {
    Cartlist cartlist = new Cartlist();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await cartlist.getSaveOrder(data["save_order_id"]);
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

  static getCartTotals(request) async {
     Cartlist cartlist = new Cartlist();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await cartlist.getCurrCartTotals(data["cart_id"]);
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
