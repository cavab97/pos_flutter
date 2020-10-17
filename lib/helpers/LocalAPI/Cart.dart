import 'dart:convert';

import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/helpers/ComunAPIcall.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/mst_sub_cart_details.dart';
import 'package:mcncashier/models/saveOrder.dart';
import 'package:mcncashier/services/allTablesSync.dart';

class Cartlist {
  var db = DatabaseHelper.dbHelper.getDatabse();
  Future<int> addcart(context, MST_Cart cartData) async {
    var cartid;
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = "http://192.168.0.113:8080/" + Configrations.add_cart;
      var stringParams = {"cart_data": jsonEncode(cartData)};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        cartid = result["cart_id"];
      }
    } else {
      if (cartData.id == null) {
        cartid = await db.insert("mst_cart", cartData.toJson());
        await SyncAPICalls.logActivity(
            "product", "Product add in to cart", "mst_cart", cartid);
      } else {
        cartData.id = cartData.id;
        var rescartid = await db.update("mst_cart", cartData.toJson(),
            where: 'id = ?', whereArgs: [cartData.id]);
        cartid = cartData.id;
        await SyncAPICalls.logActivity(
            "product", "Product update in to cart", "mst_cart", rescartid);
      }
    }
    return cartid;
  }

  Future<int> addSaveOrder(context, SaveOrder saveorder, tableid) async {
    var saveOrderid;
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = "http://192.168.0.113:8080/" + Configrations.add_saveOrder;
      var stringParams = {
        "save_order": jsonEncode(saveorder),
        "table_id": tableid
      };
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        saveOrderid = result["save_order_id"];
      }
    } else {
      var response = await db.insert("save_order", saveorder.toJson());
      saveOrderid = response;
      if (saveorder.cartId != null) {
        var rawQuery = 'UPDATE mst_cart SET table_id = ' +
            tableid.toString() +
            " WHERE id = " +
            saveorder.cartId.toString();
        var res = await db.rawQuery(rawQuery);
        await SyncAPICalls.logActivity(
            "weborder", "update table_id", "mst_cart", tableid.toString());
      }
      await SyncAPICalls.logActivity(
          "product", "save item into save order table", "save_order", 1);
    }
    return saveOrderid;
  }

  Future<List<SaveOrder>> getSaveOrder(saveorderid) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    List<SaveOrder> list = [];
    if (isjoin == true) {
      var apiurl = "http://192.168.0.113:8080/" + Configrations.get_Cart_id;
      var stringParams = {"save_order_id": saveorderid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        list = result["data"];
      }
    } else {
      var qry = "SELECT * from save_order WHERE id =" + saveorderid.toString();
      List<Map> res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
      list =
          res.isNotEmpty ? res.map((c) => SaveOrder.fromJson(c)).toList() : [];
      await SyncAPICalls.logActivity(
          "product", "get save_order", "save_order", saveorderid);
    }
    return list;
  }

  Future<int> addintoCartDetails(context, MSTCartdetails cartdetails) async {
    var cartdetailid;

    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = "http://192.168.0.113:8080/" + Configrations.cart_Details;
      var stringParams = {"cart_details": jsonEncode(cartdetails)};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        cartdetailid = result["detail_id"];
      }
    } else {
      if (cartdetails.id != null) {
        cartdetailid = db.update("mst_cart_detail", cartdetails.toJson(),
            where: 'id = ?', whereArgs: [cartdetails.id]);
        cartdetailid = cartdetails.id;
      } else {
        cartdetailid = await db.insert("mst_cart_detail", cartdetails.toJson());
      }
      await SyncAPICalls.logActivity(
          "product", "insert  cart details", "mst_cart_detail", cartdetailid);
    }
    return cartdetailid;
  }

  Future<int> addsubCartData(List<MSTSubCartdetails> data) async {
    var result;
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl =
          "http://192.168.0.113:8080/" + Configrations.cart_Sub_Details;
      var stringParams = {"cart_sub_details": jsonEncode(data)};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        result = result;
      }
    } else {
      for (var i = 0; i < data.length; i++) {
        result = await db.insert("mst_cart_sub_detail", data[i].toJson());
      }
      await SyncAPICalls.logActivity(
          "product", "insert sub cart details", "mst_cart_sub_detail", 1);
    }
    return result;
  }

  Future<List<MSTCartdetails>> getCartItem(cartId) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    List<MSTCartdetails> list = [];
    if (isjoin == true) {
      var apiurl = "http://192.168.0.113:8080/" + Configrations.cart_items;
      var stringParams = {"cart_id": jsonEncode(cartId)};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        result = result;
      }
    } else {
      var qry =
          "SELECT * from mst_cart_detail where cart_id = " + cartId.toString();
      var res = await db.rawQuery(qry);
      list = res.isNotEmpty
          ? res.map((c) => MSTCartdetails.fromJson(c)).toList()
          : [];
      await SyncAPICalls.logActivity(
          "product", "get cart list", "mst_cart_detail", cartId);
    }
    return list;
  }

  Future<List<MST_Cart>> getCurrCartTotals(cartID) async {
    List<MST_Cart> list = [];
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = "http://192.168.0.113:8080/" + Configrations.cart_data;
      var stringParams = {"cart_id": cartID};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        list = result["data"];
      }
    } else {
      var query = "SELECT * from mst_cart where id = " + cartID.toString();
      var res = await db.rawQuery(query);
      list =
          res.length > 0 ? res.map((c) => MST_Cart.fromJson(c)).toList() : [];
      await SyncAPICalls.logActivity("product", "get cart data", "mst_cart", 1);
    }
    return list;
  }
}
