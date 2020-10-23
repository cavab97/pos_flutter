import 'dart:convert';

import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/helpers/ComunAPIcall.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/OrderAttributes.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/Order_Modifire.dart';

import 'package:mcncashier/models/Lastids.dart';
import 'package:mcncashier/models/ProductStoreInventoryLog.dart';
import 'package:mcncashier/models/Product_Store_Inventory.dart';
import 'package:mcncashier/models/ShiftInvoice.dart';
import 'package:mcncashier/models/Voucher_History.dart';
import 'package:mcncashier/services/allTablesSync.dart';

class OrdersList {
  var db = DatabaseHelper.dbHelper.getDatabse();

  Future<Orders> getcurrentOrders(orderid) async {
    List<Orders> list = [];
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.get_order;
      var stringParams = {"order_id": orderid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list =
            data.length > 0 ? data.map((c) => Orders.fromJson(c)).toList() : [];
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

  Future<LastAppids> getLastids(terminalid) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    LastAppids result = new LastAppids();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.getLastids;
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
          " where orders.terminal_id = " +
          terminalid +
          " ORDER BY order_date DESC LIMIT 1";
      var res = await db.rawQuery(qry);
      List<LastAppids> list =
          res.length > 0 ? res.map((c) => LastAppids.fromJson(c)).toList() : [];
      if (list.length > 0) {
        result = list[0];
      }
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
      ShiftInvoice shiftInvoice,
      cartID) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.place_order;
      var stringParams = {
        "order": orderData,
        "order_details": jsonEncode(orderDetails),
        "order_modifire": jsonEncode(orderModifire),
        "order_attributes": jsonEncode(orderAttributes),
        "order_payment": orderPayment,
        "order_history": history,
        "shift_invoice": shiftInvoice,
        "cart_id": cartID
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
      await OrdersList.removeCartItem(cartID, orderData.table_id);
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
      }
      // sttributes update
      for (var a = 0; a < orderAttributes.length; a++) {
        OrderAttributes attribute = orderAttributes[a];
        attribute.detail_id = orderdetailid;
        attribute.order_id = orderid;
        await db.insert("order_attributes", attribute.toJson());
        await SyncAPICalls.logActivity(
            "orders", "insert order attributes", "order_attributes", orderid);
      }

      // product store inve
      if (orderdata.issetMeal == 0) {
        var productdata = jsonDecode(orderdata.product_detail);
        if (productdata["hasInventory"] == 1) {
          List<ProductStoreInventory> inventory =
              await OrdersList.getStoreInventoryData(productdata.product_id);
          if (inventory.length > 0) {
            ProductStoreInventory invData = new ProductStoreInventory();
            invData = inventory[0];
            var prev = inventory[0];
            var qty = (invData.qty - orderdata.detail_qty);
            invData.qty = qty;
            invData.updatedAt =
                await CommunFun.getCurrentDateTime(DateTime.now());
            invData.updatedBy = orderdata.updated_by;
            var ulog = await OrdersList.updateInvetory(invData);

            //Inventory log update
            ProductStoreInventoryLog log = new ProductStoreInventoryLog();
            log.uuid = orderdata.uuid;
            log.inventory_id = prev.inventoryId;
            log.branch_id = orderdata.branch_id;
            log.product_id = orderdata.product_id;
            log.employe_id = orderdata.updated_by;
            log.qty = prev.qty;
            log.qty_before_change = prev.qty;
            log.qty_after_change = qty;
            log.updated_at = await CommunFun.getCurrentDateTime(DateTime.now());
            log.updated_by = orderdata.updated_by;
            var inventoryLog =
                await OrdersList.updateStoreInvetoryLogTable(log);
          }
        }
      }
    }
  }

  static payment(OrderPayment orderPayment, orderid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    orderPayment.order_id = orderid;
    var res = await db.insert("order_payment", orderPayment.toJson());
    print(res);
    await SyncAPICalls.logActivity(
        "orders", "insert order payment", "order_payment", orderid);
  }

  static voucherHistory(VoucherHistory voucherHis, orderid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    voucherHis.order_id = orderid;
    var res = await db.insert("voucher_history", voucherHis.toJson());
    print(res);
    await SyncAPICalls.logActivity(
        "order", "add voucher history in cart", "voucher_history", orderid);
    return orderid;
  }

  static shiftInvoice(ShiftInvoice shiftInvoice, orderid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    shiftInvoice.invoice_id = orderid;
    var res = await db.insert("shift_invoice", shiftInvoice.toJson());
    print(res);
    await SyncAPICalls.logActivity(
        "orders", "insert shift invoice", "shift_invoice", orderid);
    return shiftInvoice.invoice_id;
  }

  static getStoreInventoryData(productID) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var inventoryProd = await db.query("product_store_inventory",
        where: 'product_id = ?', whereArgs: [productID]);
    List<ProductStoreInventory> list = inventoryProd.length > 0
        ? inventoryProd.map((c) => ProductStoreInventory.fromJson(c)).toList()
        : [];
    return list;
  }

  static updateInvetory(ProductStoreInventory data) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var inventory = await db.update("product_store_inventory", data.toJson(),
        where: "inventory_id =?", whereArgs: [data.inventoryId]);
    await SyncAPICalls.logActivity("Order", "update InventoryTable",
        "product_store_inventory", data.productId);
    return inventory;
  }

  static updateStoreInvetoryLogTable(ProductStoreInventoryLog log) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var inventory =
        await db.insert("product_store_inventory_log", log.toJson());
    await SyncAPICalls.logActivity("product_store_inventory_log insert",
        "insert", "product_store_inventory_log", log.inventory_id);
    return inventory;
  }

  static removeCartItem(cartid, tableID) async {
    var db = DatabaseHelper.dbHelper.getDatabse();

    await db.delete("mst_cart", where: 'id =?', whereArgs: [cartid]);

    await SyncAPICalls.logActivity("orders", "clear cart", "mst_cart", 1);

    await db.delete("save_order", where: 'cart_id =?', whereArgs: [cartid]);

    await SyncAPICalls.logActivity(
        "orders", "clear save_order", "save_order", cartid);

    await db.delete("table_order", where: 'table_id =?', whereArgs: [tableID]);

    await SyncAPICalls.logActivity(
        "orders", "clear table_order", "table_order", cartid);

    var cartDetail = await db
        .query("mst_cart_detail", where: 'cart_id =?', whereArgs: [cartid]);

    List<MSTCartdetails> list = cartDetail.isNotEmpty
        ? cartDetail.map((c) => MSTCartdetails.fromJson(c)).toList()
        : [];
    if (list.length > 0) {
      for (var i = 0; i < list.length; i++) {
        await db.delete("mst_cart_sub_detail",
            where: 'cart_details_id = ?', whereArgs: [list[i].id]);
      }
    }
    await SyncAPICalls.logActivity(
        "orders", "clear cart detail", "mst_cart_sub_detail", cartid);

    // cart details
    var cartd = await db
        .delete("mst_cart_detail", where: 'cart_id = ?', whereArgs: [cartid]);
    await SyncAPICalls.logActivity(
        "orders", "clear cart detail", "mst_cart_detail", cartid);
    return cartd;
  }

  Future<List<OrderDetail>> getOrderDetailsList(orderid) async {
    List<OrderDetail> list = [];
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.order_details;
      var stringParams = {"order_id": orderid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => OrderDetail.fromJson(c)).toList()
            : [];
      }
    } else {
      var ordersList = await db
          .query("order_detail", where: "order_id =?", whereArgs: [orderid]);
      list = ordersList.isNotEmpty
          ? ordersList.map((c) => OrderDetail.fromJson(c)).toList()
          : [];
      await SyncAPICalls.logActivity(
          "invoice", "get Orders details list", "ProductDetails", orderid);
    }
    return list;
  }

  Future<OrderPayment> getOrderpaymentData(orderid) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    OrderPayment list;
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.order_details;
      var stringParams = {"order_id": orderid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        var data = result["data"];
        list = OrderPayment.fromJson(data);
      }
    } else {
      var qry =
          "SELECT * from order_payment where order_id = " + orderid.toString();
      var ordersList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
      List<OrderPayment> res = ordersList.length > 0
          ? ordersList.map((c) => OrderPayment.fromJson(c)).toList()
          : [];
      if (res.length > 0) {
        list = res[0];
      }
    }
    return list;
  }

  Future<List<Orders>> getOrdersList(branchid, terminalid) async {
    List<Orders> list = [];
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.orders_list;
      var stringParams = {"branch_id": branchid, "terminal_id": terminalid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list =
            data.length > 0 ? data.map((c) => Orders.fromJson(c)).toList() : [];
      }
    } else {
      var qry = "SELECT * from orders where branch_id = " +
          branchid.toString() +
          " AND terminal_id = " +
          terminalid.toString();
      var ordersList = await db.rawQuery(qry);
      list = ordersList.isNotEmpty
          ? ordersList.map((c) => Orders.fromJson(c)).toList()
          : [];
      await SyncAPICalls.logActivity(
          "Transactions", "get Orders list", "Orders", branchid);
    }
    return list;
  }
}
