import 'dart:convert';
import 'dart:html';

import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/helpers/ComunAPIcall.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/OrderAttributes.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/Order_Modifire.dart';
import 'package:mcncashier/models/ShiftInvoice.dart';
import 'package:mcncashier/models/Voucher_History.dart';
import 'package:mcncashier/services/allTablesSync.dart';

class OrdersList {
  var db = DatabaseHelper.dbHelper.getDatabse();

  Future<Orders> getcurrentOrders(orderid) async {
    List<Orders> list = [];
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = "http://192.168.0.113:8080/" + Configrations.get_order;
      var stringParams = {"order_id": orderid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        list = result["data"];
      }
    } else {
      var result =
          await db.query('orders', where: "app_id = ?", whereArgs: [orderid]);
      list = result.length > 0
          ? result.map((c) => Orders.fromJson(c)).toList()
          : [];
    }
    return list[0];
  }

  Future<List> getLastids(terminalid) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    List<Map> result;
    if (isjoin == true) {
      var apiurl = "http://192.168.0.113:8080/" + Configrations.getLastids;
      var stringParams = {"terminal_id": terminalid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        result = result["data"];
      }
    } else {
      var qry = " SELECT " +
          " orders.app_id,order_detail.app_id as order_detail_id, order_attributes.app_id as order_attr_id," +
          " order_modifier.app_id as order_modifier_id,order_payment.app_id as order_payment_id from orders " +
          " Left JOIN order_detail on order_detail.order_id = orders.app_id" +
          " Left JOIN order_attributes on order_attributes.order_id = orders.app_id" +
          " Left JOIN order_modifier on order_modifier.order_id = orders.app_id" +
          " Left JOIN order_payment on order_payment.order_id = orders.app_id" +
          " where orders.terminal_id = 1 ORDER BY order_date DESC LIMIT 1";
      result = await db.rawQuery(qry);
      print(result);
    }
    return result;
  }

  Future<int> placeOrder(
      Orders orderData,
      List<OrderDetail> orderDetails,
      List<OrderModifire> orderModifire,
      List<OrderAttributes> orderAttributes,
      OrderPayment orderPayment,
      VoucherHistory history,
      ShiftInvoice shiftInvoice) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = "http://192.168.0.113:8080/" + Configrations.place_order;
      var stringParams = {
        "order": orderData,
        "order_details": jsonEncode(orderDetails),
        "order_modifire": jsonEncode(orderModifire),
        "order_attributes": jsonEncode(orderAttributes),
        "order_payment": orderPayment,
        "order_history": history,
        "shift_invoice": shiftInvoice
      };
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        result = result["data"];
      }
    } else {
      var orderid = await db.insert("orders", orderData.toJson());
      await SyncAPICalls.logActivity(
          "orders", "place order", "orders", orderid);
      await OrdersList.orderDetails(
          orderid, orderDetails, orderModifire, orderAttributes);
      await OrdersList.payment(orderPayment, orderid);
      await OrdersList.voucherHistory(history, orderid);
      await OrdersList.shiftInvoice(shiftInvoice, orderid);
    }
    return orderData.app_id;
  }

  static orderDetails(
    orderid,
    List<OrderDetail> orderDetails,
    List<OrderModifire> orderModifire,
    List<OrderAttributes> orderAttributes,
  ) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    for (var i = 0; i < orderDetails.length; i++) {
      OrderDetail orderdata = orderDetails[i];
      orderdata.order_id = orderid;
      var orderdetailid = await db.insert("order_detail", orderdata.toJson());
      await SyncAPICalls.logActivity(
          "orders", "insert order details", "order_detail", orderid);
      // Modifire
      for (var m = 0; m < orderModifire.length; m++) {
        OrderModifire modifire = orderModifire[m];
        modifire.detail_id = orderdetailid;
        modifire.order_id = orderid;
        await db.insert("order_modifier", modifire.toJson());
        await SyncAPICalls.logActivity(
            "orders", "insert order modifier", "order_modifier", orderid);
        return modifire.app_id;
      }
      for (var a = 0; a < orderAttributes.length; a++) {
        OrderAttributes attribute = orderAttributes[a];
        attribute.detail_id = orderdetailid;
        attribute.order_id = orderid;
        await db.insert("order_attributes", attribute.toJson());
        await SyncAPICalls.logActivity(
            "orders", "insert order attributes", "order_attributes", orderid);
        return attribute.app_id;
      }
    }
  }

  static payment(OrderPayment orderPayment, orderid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    orderPayment.order_id = orderid;
    await db.insert("order_payment", orderPayment.toJson());
    await SyncAPICalls.logActivity(
        "orders", "insert order payment", "order_payment", orderid);
  }

  static voucherHistory(VoucherHistory voucherHis, orderid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    voucherHis.order_id = orderid;
    await db.insert("voucher_history", voucherHis.toJson());
    await SyncAPICalls.logActivity(
        "order", "add voucher history in cart", "voucher_history", orderid);
    return orderid;
  }

  static shiftInvoice(ShiftInvoice shiftInvoice, orderid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    shiftInvoice.invoice_id = orderid;
    await db.insert("shift_invoice", shiftInvoice.toJson());
    await SyncAPICalls.logActivity(
        "orders", "insert shift invoice", "shift_invoice", orderid);
    return shiftInvoice.invoice_id;
  }
}
