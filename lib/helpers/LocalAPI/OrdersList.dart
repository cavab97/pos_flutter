import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/helpers/ComunAPIcall.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Box.dart';
import 'package:mcncashier/models/Customer_Liquor_Inventory.dart';
import 'package:mcncashier/models/Customer_Liquor_Inventory_Log.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/OrderAttributes.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/Order_Modifire.dart';
import 'package:mcncashier/models/Lastids.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/ProductStoreInventoryLog.dart';
import 'package:mcncashier/models/Product_Store_Inventory.dart';
import 'package:mcncashier/models/ShiftInvoice.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/models/Voucher_History.dart';
import 'package:mcncashier/models/cancelOrder.dart';
import 'package:mcncashier/models/saveOrder.dart';
import 'package:mcncashier/services/allTablesSync.dart';
import '../../models/Payment.dart';

class OrdersList {
  var db = DatabaseHelper.dbHelper.getDatabse();

  Future<Orders> getcurrentOrders(orderid, terminalID) async {
    List<Orders> list = [];
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.get_order;
      var stringParams = {"order_id": orderid, "terminal_Id": terminalID};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list =
            data.length > 0 ? data.map((c) => Orders.fromJson(c)).toList() : [];
        if (list.length > 0) {
          return list[0];
        }
      }
    } else {
      var query =
          "SELECT * from orders WHERE app_id=$orderid AND terminal_id=$terminalID";
      var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
      list = res.length > 0 ? res.map((c) => Orders.fromJson(c)).toList() : [];
      if (list.length > 0) {
        return list[0];
      }
    }
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
      List<OrderPayment> orderPayments,
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
        "order_payment": jsonEncode(orderPayments),
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
          "orders", "place order", "orders", orderData.app_id);
      await OrdersList.orderDetails(orderData.app_id, orderDetails,
          orderModifire, orderAttributes, orderData.customer_id);
      await OrdersList.payment(orderPayments, orderData.app_id);
      await OrdersList.voucherHistory(history, orderData.app_id);
      await OrdersList.shiftInvoice(shiftInvoice, orderData.app_id);
      await removeCart(cartID, orderData.table_id);
    }
    return orderData.app_id;
  }

  static orderDetails(
      orderid,
      List<OrderDetail> orderDetails,
      List<OrderModifire> orderModifire,
      List<OrderAttributes> orderAttributes,
      customerid) async {
    try {
      var db = DatabaseHelper.dbHelper.getDatabse();
      OrdersList orderAPI = new OrdersList();
      for (var i = 0; i < orderDetails.length; i++) {
        OrderDetail orderdata = orderDetails[i];
        orderdata.order_app_id = orderid;
        var orderdetailid = await db.insert("order_detail", orderdata.toJson());
        await SyncAPICalls.logActivity(
            "orders", "insert order details", "order_detail", orderid);
        // Modifire
        for (var m = 0; m < orderModifire.length; m++) {
          OrderModifire modifire = orderModifire[m];
          modifire.detail_app_id = orderdetailid;
          modifire.order_app_id = orderid;
          var newObj = modifire.toJson();
          newObj.remove("name");
          await db.insert("order_modifier", newObj);
          await SyncAPICalls.logActivity(
              "orders", "insert order modifier", "order_modifier", orderid);
        }
        // sttributes update
        for (var a = 0; a < orderAttributes.length; a++) {
          OrderAttributes attribute = orderAttributes[a];
          attribute.detail_app_id = orderdetailid;
          attribute.order_app_id = orderid;
          var newObj = attribute.toJson();
          newObj.remove("name");
          await db.insert("order_attributes", newObj);
          await SyncAPICalls.logActivity(
              "orders", "insert order attributes", "order_attributes", orderid);
        }

        // product store inventory data updates
        if (orderdata.issetMeal == 0 || orderdata.hasRacManagemant == 0) {
          var productdata = jsonDecode(orderdata.product_detail);
          if (productdata["hasInventory"] == 1) {
            List<ProductStoreInventory> inventory =
                await orderAPI.getStoreInventoryData(productdata.product_id);
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
              log.updated_at =
                  await CommunFun.getCurrentDateTime(DateTime.now());
              log.updated_by = orderdata.updated_by;
              var inventoryLog = await updateStoreInvetoryLogTable(log);
            }
          }
        }
        if (orderdata.hasRacManagemant == 1) {
          insertRacInv(orderdata.detail_by, orderdata, customerid);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  static insertRacInv(userid, cartItem, customer) async {
    OrdersList orderapi = new OrdersList();
    Customer_Liquor_Inventory inventory = new Customer_Liquor_Inventory();
    var orderDateF;
    var appid = await getLastCustomerInventoryId();
    if (appid != 0) {
      inventory.appId = appid + 1;
    } else {
      inventory.appId = 1;
    }
    var branchid = await CommunFun.getbranchId();
    var now = DateTime.now();
    var newDate = new DateTime(now.year, now.month + 1, now.day);
    orderDateF = DateFormat('yyyy-MM-dd HH:mm:ss').format(newDate);
    List<Box> boxList = await orderapi.getBoxForProduct(cartItem.productId);
    if (boxList.length > 0) {
      inventory.uuid = await CommunFun.getLocalID();
      inventory.clCustomerId = customer;
      inventory.clProductId = cartItem.productId;
      inventory.clBranchId = int.parse(branchid);
      inventory.clRacId = boxList[0].racId;
      inventory.clBoxId = boxList[0].boxId;
      inventory.type = boxList[0].boxFor;
      inventory.clTotalQuantity = boxList[0].wineQty;
      inventory.clExpiredOn = orderDateF;
      inventory.clLeftQuantity = boxList[0].wineQty != null
          ? (boxList[0].wineQty - cartItem.productQty)
          : 0;
      inventory.status = 1;
      inventory.updatedAt = await CommunFun.getCurrentDateTime(DateTime.now());
      inventory.updatedBy = userid;
      var clid = await orderapi.insertWineInventory(inventory, false);
      Customer_Liquor_Inventory_Log log = new Customer_Liquor_Inventory_Log();
      var lastappid = await orderapi.getLastCustomerInventoryLogid();
      if (lastappid != 0) {
        log.appId = lastappid + 1;
      } else {
        log.appId = 1;
      }
      log.uuid = await CommunFun.getLocalID();
      log.clAppId = inventory.appId;
      log.branchId = int.parse(branchid);
      log.productId = cartItem.productId;
      log.customerId = customer;
      log.liType = boxList[0].boxFor;
      log.qty = cartItem.productQty;
      log.qtyBeforeChange = boxList[0].wineQty;
      log.qtyAfterChange = boxList[0].wineQty != null
          ? (boxList[0].wineQty - cartItem.productQty)
          : 0;
      log.updatedAt = await CommunFun.getCurrentDateTime(DateTime.now());
      log.updatedBy = userid;
      var lid = await orderapi.insertWineInventoryLog(log);
    }
  }

  getBoxForProduct(productId) async {
    var qry = "SELECT * from box where product_id = " +
        productId.toString() +
        " AND status = 1";
    var result = await db.rawQuery(qry);
    List<Box> list =
        result.length > 0 ? result.map((c) => Box.fromJson(c)).toList() : [];
    return list;
  }

  static payment(List<OrderPayment> orderPayments, orderid) async {
    try {
      var db = DatabaseHelper.dbHelper.getDatabse();
      for (var i = 0; i < orderPayments.length; i++) {
        OrderPayment orderPayment = new OrderPayment();
        orderPayment = orderPayments[i];
        orderPayment.order_app_id = orderid;
        var res = await db.insert("order_payment", orderPayment.toJson());

        await SyncAPICalls.logActivity(
            "orders", "insert order payment", "order_payment", orderid);
      }
    } catch (e) {
      print(e);
    }
  }

  static voucherHistory(VoucherHistory voucherHis, orderid) async {
    try {
      if (voucherHis != null) {
        var db = DatabaseHelper.dbHelper.getDatabse();
        voucherHis.order_id = orderid;
        var res = await db.insert("voucher_history", voucherHis.toJson());

        await SyncAPICalls.logActivity(
            "order", "add voucher history in cart", "voucher_history", orderid);
        return orderid;
      }
    } catch (e) {
      print(e);
    }
  }

  static shiftInvoice(ShiftInvoice shiftInvoice, orderid) async {
    try {
      var db = DatabaseHelper.dbHelper.getDatabse();
      shiftInvoice.invoice_id = orderid;
      var res = await db.insert("shift_invoice", shiftInvoice.toJson());
      await SyncAPICalls.logActivity(
          "orders", "insert shift invoice", "shift_invoice", orderid);
      return shiftInvoice.invoice_id;
    } catch (e) {
      print(e);
    }
  }

  Future<List<ProductStoreInventory>> getStoreInventoryData(productID) async {
    List<ProductStoreInventory> list = new List<ProductStoreInventory>();
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.store_inv_data;
      var stringParams = {
        "product_id": productID,
      };
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> listdata = result["data"];
        list = listdata.length > 0
            ? listdata.map((c) => ProductStoreInventory.fromJson(c)).toList()
            : [];
      }
    } else {
      var inventoryProd = await db.query("product_store_inventory",
          where: 'product_id = ?', whereArgs: [productID]);
      list = inventoryProd.length > 0
          ? inventoryProd.map((c) => ProductStoreInventory.fromJson(c)).toList()
          : [];
    }
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

  Future<int> getLastCustomerInventoryLogid() async {
    int lastid;
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.last_wine_int_log_id;
      var stringParams = {};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        lastid = result["last_id"];
      }
    } else {
      var qey = "SELECT app_id from customer_liquor_inventory_log " +
          " ORDER BY app_id DESC LIMIT 1";
      var checkisExit =
          await DatabaseHelper.dbHelper.getDatabse().rawQuery(qey);
      List<Customer_Liquor_Inventory_Log> list = checkisExit.length > 0
          ? checkisExit
              .map((c) => Customer_Liquor_Inventory_Log.fromJson(c))
              .toList()
          : [];
      if (list.length > 0) {
        lastid = list[0].appId;
      } else {
        lastid = 0;
      }
    }
    return lastid;
  }

  Future<int> insertWineInventory(
      Customer_Liquor_Inventory data, isUpdate) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var invData = data.toJson();
    await invData.remove("name");
    var result;
    if (isUpdate) {
      result = await db.update("customer_liquor_inventory", invData,
          where: "app_id =?", whereArgs: [data.appId]);
    } else {
      result = await db.insert("customer_liquor_inventory", invData);
    }
    await SyncAPICalls.logActivity("customer liquor inventory",
        "insert Wine inventory", "customer_liquor_inventory", data.clBranchId);
    return result;
  }

  Future<int> insertWineInventoryLog(Customer_Liquor_Inventory_Log data) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var result =
        await db.insert("customer_liquor_inventory_log", data.toJson());
    await SyncAPICalls.logActivity(
        "customer liquor inventory log",
        "insert Wine inventory log",
        "customer_liquor_inventory_log",
        data.branchId);
    return result;
  }

  static getLastCustomerInventoryId() async {
    var qey = "SELECT app_id from customer_liquor_inventory " +
        " ORDER BY app_id DESC LIMIT 1";
    var checkisExit = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qey);
    List<Customer_Liquor_Inventory> list = checkisExit.length > 0
        ? checkisExit.map((c) => Customer_Liquor_Inventory.fromJson(c)).toList()
        : [];
    if (list.length > 0) {
      return list[0].appId;
    } else {
      return 0;
    }
  }

  Future removeCart(cartid, tableID) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.remove_cart;
      var stringParams = {"cart_id": cartid, "table_id": tableID};
      await APICall.localapiCall(null, apiurl, stringParams);
    } else {
      var db = DatabaseHelper.dbHelper.getDatabse();
      if (cartid == null) {
        List<SaveOrder> cartID = await gettableCartID(tableID);
        if (cartID.length > 0) {
          cartid = cartID[0];
        } else {
          cartid = 0;
        }
      }
      await db.delete("mst_cart", where: 'id =?', whereArgs: [cartid]);
      await SyncAPICalls.logActivity("orders", "clear cart", "mst_cart", 1);
      await db.delete("save_order", where: 'cart_id =?', whereArgs: [cartid]);
      await SyncAPICalls.logActivity(
          "orders", "clear save_order", "save_order", cartid);
      await db
          .delete("table_order", where: 'table_id =?', whereArgs: [tableID]);
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
      await db
          .delete("mst_cart_detail", where: 'cart_id = ?', whereArgs: [cartid]);
      await SyncAPICalls.logActivity(
          "orders", "clear cart detail", "mst_cart_detail", cartid);
    }
  }

  Future<List<SaveOrder>> gettableCartID(tableid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT save_order.cart_id  from table_order " +
        " LEFT join save_order on save_order.id = table_order.save_order_id " +
        " WHERE table_order.table_id  = " +
        tableid.toString();
    var result = await db.rawQuery(qry);
    List<SaveOrder> list = result.length > 0
        ? result.map((c) => SaveOrder.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<OrderDetail>> getOrderDetailsList(orderid, terminalid) async {
    List<OrderDetail> list = [];
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.order_details;
      var stringParams = {"order_id": orderid, "terminal_Id": terminalid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => OrderDetail.fromJson(c)).toList()
            : [];
      }
    } else {
      var qry = "SELECT * from order_detail WHERE terminal_id = " +
          terminalid.toString() +
          " AND order_app_id = " +
          orderid.toString();
      var ordersList = await db.rawQuery(qry);
      list = ordersList.isNotEmpty
          ? ordersList.map((c) => OrderDetail.fromJson(c)).toList()
          : [];
      await SyncAPICalls.logActivity(
          "invoice", "get Orders details list", "ProductDetails", orderid);
    }
    return list;
  }

  Future<List<OrderPayment>> getOrderpaymentData(orderid, terminalid) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    List<OrderPayment> list;
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.order_details;
      var stringParams = {"order_id": orderid, "terminal_Id": terminalid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => OrderPayment.fromJson(c)).toList()
            : [];
      }
    } else {
      var qry = "SELECT * from order_payment where terminal_id = " +
          terminalid.toString() +
          " AND order_app_id = " +
          orderid.toString();
      var ordersList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
      list = ordersList.length > 0
          ? ordersList.map((c) => OrderPayment.fromJson(c)).toList()
          : [];
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

  Future<List<OrderAttributes>> getOrderAttributes(orderid) async {
    var query = "SELECT order_attributes.*,attributes.name from order_attributes " +
        " LEFT join attributes on attributes.attribute_id =  order_attributes.attribute_id WHERE order_attributes.order_app_id = " +
        orderid.toString();
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<OrderAttributes> list = res.isNotEmpty
        ? res.map((c) => OrderAttributes.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<OrderModifire>> getOrderModifire(orderid) async {
    var query = "SELECT order_modifier.*,modifier.name  from order_modifier " +
        " LEFT JOIN modifier on modifier.modifier_id = order_modifier.modifier_id" +
        " WHERE order_modifier.order_app_id  = " +
        orderid.toString();
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<OrderModifire> list = res.isNotEmpty
        ? res.map((c) => OrderModifire.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<Payments>> getOrderpaymentmethod(orderid, terminalid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from payment " +
        " LEFT JOIN order_payment on order_payment.op_method_id = payment.payment_id " +
        " WHERE order_payment.terminal_id = " +
        terminalid.toString() +
        " AND order_payment.order_app_id = " +
        orderid.toString();
    var paymentMeth = await db.rawQuery(qry);
    List<Payments> list = paymentMeth.isNotEmpty
        ? paymentMeth.map((c) => Payments.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<ProductDetails>> getOrderDetails(orderid, terminalID) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT P.product_id,P.name,P.price, base64" +
        " FROM order_detail O " +
        " LEFT JOIN product P ON O.product_id = P.product_id" +
        " LEFT JOIN asset on asset.asset_type_id = P.product_id " +
        " WHERE O.terminal_id = " +
        terminalID.toString() +
        "  AND O.order_app_id = " +
        orderid.toString();
    var ordersList = await db.rawQuery(qry);
    List<ProductDetails> list = ordersList.isNotEmpty
        ? ordersList.map((c) => ProductDetails.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Transactions", "get Orders details list", "ProductDetails", orderid);
    return list;
  }

  Future<User> getPaymentUser(userid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var user = await db
        .query('users', where: 'id = ?', whereArgs: [userid.toString()]);
    List<User> list =
        user.isNotEmpty ? user.map((c) => User.fromJson(c)).toList() : [];
    return list[0];
  }

  Future<dynamic> getOrdersDetailsData(orderid, terminalid) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    dynamic listdata;
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.order_data;
      var stringParams = {
        "order_id": orderid,
        "terminal_id": terminalid,
      };
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        dynamic data = result["data"];
        listdata = data;
      }
      return listdata;
    } else {
      List<OrderPayment> orderpaymentdata =
          await getOrderpaymentData(orderid, terminalid);
      List<Payments> paymentMethod =
          await getOrderpaymentmethod(orderid, terminalid);
      List<OrderDetail> orderitem =
          await getOrderDetailsList(orderid, terminalid);
      List<ProductDetails> orderProductitem =
          await getOrderDetails(orderid, terminalid);
      Orders order = await getcurrentOrders(orderid, terminalid);
      List<OrderAttributes> attributes = await getOrderAttributes(orderid);
      List<OrderModifire> modifires = await getOrderModifire(orderid);
      User user;
      if (orderpaymentdata.length > 0) {
        user = await getPaymentUser(orderpaymentdata[0].op_by);
      }
      dynamic productDetais = {
        "order_payment": orderpaymentdata,
        "order_payment_method": paymentMethod,
        "order_items": orderitem,
        "order_products": orderProductitem,
        "order": order,
        "paymentBy": user,
        "order_attributes": attributes,
        "order_modifires": modifires
      };
      return productDetais;
    }
  }

  Future insertCancelOrder(
      CancelOrder order, List<OrderDetail> orderItemList) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.cancel_order;
      var stringParams = {"order": order, "orderList": orderItemList};
      await APICall.localapiCall(null, apiurl, stringParams);
    } else {
      var result = await db.insert('order_cancel', order.toJson());
      await updatedAfterCancleORder(orderItemList);
    }
  }

  updatedAfterCancleORder(orderItemList) async {
    OrdersList orderAPI = new OrdersList();
    List<OrderDetail> orderItem = orderItemList;
    User userdata = await CommunFun.getuserDetails();
    var branchid = await CommunFun.getbranchId();
    var uuid = await CommunFun.getLocalID();
    if (orderItem.length > 0) {
      for (var i = 0; i < orderItem.length; i++) {
        OrderDetail productDetail = orderItem[i];
        var productData = productDetail.product_detail;
        var jsonProduct = json.decode(productData);
        if (jsonProduct["has_inventory"] == 1) {
          List<ProductStoreInventory> inventory =
              await orderAPI.getStoreInventoryData(productDetail.product_id);
          if (inventory.length > 0) {
            ProductStoreInventory invData;
            invData = inventory[0];
            invData.qty = invData.qty + productDetail.detail_qty;
            invData.updatedAt =
                await CommunFun.getCurrentDateTime(DateTime.now());
            invData.updatedBy = userdata.id;
            var ulog = await updateInvetory(invData);
            ProductStoreInventoryLog log = new ProductStoreInventoryLog();
            if (inventory.length > 0) {
              log.uuid = uuid;
              log.inventory_id = inventory[0].inventoryId;
              log.branch_id = int.parse(branchid);
              log.product_id = productDetail.product_id;
              log.employe_id = userdata.id;
              log.qty = invData.qty;
              log.qty_before_change = invData.qty;
              log.qty_after_change = invData.qty + productDetail.detail_qty;
              log.updated_at =
                  await CommunFun.getCurrentDateTime(DateTime.now());
              log.updated_by = userdata.id;
              var ulog = await updateStoreInvetoryLogTable(log);
            }
          }
        }
      }
    }
  }

  Future<int> updateOrderStatus(orderid, terminalid, status) async {
    var result;
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.update_order_status;
      var stringParams = {
        "order_id": orderid,
        "terminal_id": terminalid,
        "status": status
      };
      var res = await APICall.localapiCall(null, apiurl, stringParams);
      if (res["status"] == Constant.STATUS200) {
        result = 1;
      }
    } else {
      var qry = "UPDATE orders SET order_status = " +
          status.toString() +
          " where terminal_id = " +
          terminalid.toString() +
          " AND app_id = " +
          orderid.toString();
      result = db.rawUpdate(qry);
      var payqry = "UPDATE order_payment SET op_status = " +
          status.toString() +
          " where terminal_id = " +
          terminalid.toString() +
          " AND order_app_id = " +
          orderid.toString();
      result = db.rawUpdate(payqry);
      await SyncAPICalls.logActivity(
          "order staus change", "update order status", "orders", orderid);
      await SyncAPICalls.logActivity("order payment staus change",
          "update payment status", "order_payment", orderid);
    }
    return result;
  }

  Future<List<ProductStoreInventory>> checkItemAvailableinStore(
      productId) async {
    List<ProductStoreInventory> list = new List<ProductStoreInventory>();
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.check_item_into_store;
      var stringParams = {
        "product_id": productId,
      };
      var res = await APICall.localapiCall(null, apiurl, stringParams);
      if (res["status"] == Constant.STATUS200) {
        List<dynamic> listdata = res["data"];
        list = listdata.length > 0
            ? listdata.map((c) => ProductStoreInventory.fromJson(c)).toList()
            : [];
      }
    } else {
      var inventoryProd = await db.query("product_store_inventory",
          where: 'product_id = ?', whereArgs: [productId]);
      list = inventoryProd.length > 0
          ? inventoryProd.map((c) => ProductStoreInventory.fromJson(c)).toList()
          : [];
    }
    return list;
  }
}
