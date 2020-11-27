import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:mcncashier/helpers/LocalAPI/OrdersList.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/OrderAttributes.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/Order_Modifire.dart';
import 'package:mcncashier/models/ShiftInvoice.dart';
import 'package:mcncashier/models/Voucher_History.dart';

class OrdersReq {
  static getcurrentOrders(request) async {
    OrdersList order = new OrdersList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res =
          await order.getcurrentOrders(data["order_id"], data["terminal_Id"]);
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
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
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
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static placeOrder(request) async {
    OrdersList order = new OrdersList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      Orders orderdata = Orders.fromJson(data["order"]);

      List<OrderDetail> orderDetails = data["order_details"];
      List<OrderModifire> orderModifire = data["order_modifire"];
      List<OrderAttributes> orderAttributes = data["order_attributes"];
      List<OrderPayment> orderPayment = data["order_payment"];
      VoucherHistory history = data["order_history"];
      ShiftInvoice shiftInvoice = data["shift_invoice"];
      var res = await order.placeOrder(
          orderdata,
          orderDetails,
          orderModifire,
          orderAttributes,
          orderPayment,
          history,
          shiftInvoice,
          data["cart_id"]);
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
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static orderDetails(request) async {
    OrdersList order = new OrdersList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await order.getOrderDetailsList(
          data["order_id"], data["terminal_Id"]);
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
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static orderPaymentdata(request) async {
    OrdersList order = new OrdersList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await order.getOrderpaymentData(
          data["order_id"], data["terminal_Id"]);
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
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static getOrdersList(request) async {
    OrdersList order = new OrdersList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res =
          await order.getOrdersList(data["branch_id"], data["terminal_id"]);
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
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static getOrdersDetails(request) async {
    OrdersList order = new OrdersList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await order.getOrdersDetailsData(
          data["order_id"], data["terminal_id"]);
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
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static insertCancelOrd(request) async {
    OrdersList order = new OrdersList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      await order.insertCancelOrder(data["order"], data["orderList"]);
      await request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(
            jsonEncode({"status": 200, "message": "order cancel  success."}))
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

  static getStoreInvdata(request) async {
    OrdersList order = new OrdersList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await order.getStoreInventoryData(data["product_id"]);
      await request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 200, "message": "success.", data: res}))
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

  static updateStatus(request) async {
    OrdersList order = new OrdersList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await order.updateOrderStatus(
          data["order_id"], data["terminal_id"], data["status"]);
      await request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 200, "message": "success.", data: res}))
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

  static customerInvlastId(request) async {
    OrdersList order = new OrdersList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var res = await order.getLastCustomerInventoryLogid();
      await request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(
            jsonEncode({"status": 200, "message": "success.", "last_id": res}))
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

  static removeCartItem(request) async {
     OrdersList order = new OrdersList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      await order.removeCart(data["cart_id"], data["table_id"]);
      await request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 200, "message": "success."}))
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

  static checkitemIntoStore(request) async {
    OrdersList order = new OrdersList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await order.checkItemAvailableinStore(data["product_id"]);
      await request.response
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
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }
}
