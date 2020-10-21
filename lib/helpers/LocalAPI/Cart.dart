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
      var apiurl = await Configrations.ipAddress() + Configrations.add_cart;
      var stringParams = {"cart_data": cartData};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        cartid = result["cart_id"];
      } else {
        CommunFun.showToast(context, result["message"]);
      }
    } else {
      if (cartData.id == null) {
        cartid = await db.insert("mst_cart", cartData.toJson());
        await SyncAPICalls.logActivity(
            "product", "Product add in to cart", "mst_cart", cartid);
      } else {
        var rescartid = await db.update("mst_cart", cartData.toJson(),
            where: 'id = ?', whereArgs: [cartData.id]);
        cartid = cartData.id;
        await SyncAPICalls.logActivity(
            "product", "Product update in to cart", "mst_cart", rescartid);
      }
    }
    return cartid;
  }

  Future<int> addSaveOrder(SaveOrder saveorder, tableid) async {
    var saveOrderid;
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.add_saveOrder;
      var stringParams = {"save_order": saveorder, "table_id": tableid};
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
        await db.rawQuery(rawQuery);
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
      var apiurl = await Configrations.ipAddress() + Configrations.get_Cart_id;
      var stringParams = {"save_order_id": saveorderid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => SaveOrder.fromJson(c)).toList()
            : [];
      }
    } else {
      var qry = "SELECT * from save_order WHERE id =" + saveorderid.toString();
      List<Map> res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
      list =
          res.length > 0 ? res.map((c) => SaveOrder.fromJson(c)).toList() : [];
      await SyncAPICalls.logActivity(
          "product", "get save_order", "save_order", saveorderid);
    }
    return list;
  }

  Future<int> addintoCartDetails(context, MSTCartdetails cartdetails) async {
    var cartdetailid;

    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.cart_Details;
      var stringParams = {"cart_details": cartdetails};
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

  Future<int> addsubCartData(context, List<MSTSubCartdetails> data) async {
    var result;
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.cart_Sub_Details;
      var stringParams = {"cart_sub_details": data};
      print(data);
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        result = result;
      } else {
        CommunFun.showToast(context, result["message"]);
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
      var apiurl = await Configrations.ipAddress() + Configrations.cart_items;
      var stringParams = {"cart_id": cartId};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => MSTCartdetails.fromJson(c)).toList()
            : [];
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
      var apiurl = await Configrations.ipAddress() + Configrations.cart_data;
      var stringParams = {"cart_id": cartID};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => MST_Cart.fromJson(c)).toList()
            : [];
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

  Future<List<MSTCartdetails>> deleteCartItem(
      cartItem, cartID, mainCart, isLast) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    List<MSTCartdetails> list = [];
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.delete_cart_item;
      var stringParams = {
        "cart_item": cartItem,
        "cart_id": cartID,
        "main_cart": mainCart,
        "is_last": isLast
      };
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        list = result;
      }
    } else {
      await db
          .delete("mst_cart_Detail", where: 'id = ?', whereArgs: [cartItem.id]);
      await SyncAPICalls.logActivity(
          "cart",
          "delete cart item from mst_cart_Detail",
          "mst_cart_Detail",
          cartItem.id);

      await db.delete("mst_cart_sub_detail",
          where: 'cart_details_id = ?', whereArgs: [cartItem.id]);
      await SyncAPICalls.logActivity(
          "cart",
          "delete cart item from mst_cart_sub_detail",
          "mst_cart_sub_detail",
          cartItem.id);

      if (isLast) {
        await db.delete("mst_cart", where: 'id = ?', whereArgs: [cartID]);
        await SyncAPICalls.logActivity(
            "cart", "delete cart all item", "mst_Cart", cartItem.id);
        await db
            .delete("save_order", where: 'cart_id = ?', whereArgs: [cartID]);
        await SyncAPICalls.logActivity("cart",
            "delete cart all item from save_order", "save_order", cartItem.id);
      } else {
        //Update cart
        await db.update("mst_cart", mainCart.toJson(),
            where: 'id = ?', whereArgs: [cartID]);
      }
      list = await cartapi.getCartItem(cartID);
    }
    return list;
  }

  Future clearCartItem(cartid, tableID) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.delete_cart_item;
      var stringParams = {
        "cart_id": cartid,
        "table_id": tableID,
      };
      await APICall.localapiCall(null, apiurl, stringParams);
    } else {
      await db.delete("mst_cart", where: 'id = ?', whereArgs: [cartid]);
      await SyncAPICalls.logActivity("orders", "clear cart", "mst_cart", 1);
      await db.delete("save_order", where: 'cart_id = ?', whereArgs: [cartid]);
      var cartDetail = await db
          .query("mst_cart_detail", where: 'cart_id = ?', whereArgs: [cartid]);
      await SyncAPICalls.logActivity(
          "orders", "clear cart detail", "mst_cart_detail", cartid);
      List<MSTCartdetails> list = cartDetail.isNotEmpty
          ? cartDetail.map((c) => MSTCartdetails.fromJson(c)).toList()
          : [];
      if (list.length > 0) {
        for (var i = 0; i < list.length; i++) {
          await db.delete("mst_cart_sub_detail",
              where: 'cart_details_id = ?', whereArgs: [list[i].id]);
        }
        await SyncAPICalls.logActivity(
            "orders", "clear cart detail", "mst_cart_sub_detail", cartid);
      }
    }
  }

  Future<List<MSTSubCartdetails>> getItemModifire(id) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    List<MSTSubCartdetails> list = [];
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.product_modifire;
      var stringParams = {
        "cart_details_id": id,
      };
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => MSTSubCartdetails.fromJson(c)).toList()
            : [];
      }
    } else {
      var cartDetail = await db.query("mst_cart_sub_detail",
          where: 'cart_details_id = ?', whereArgs: [id]);
      list = cartDetail.isNotEmpty
          ? cartDetail.map((c) => MSTSubCartdetails.fromJson(c)).toList()
          : [];
      await SyncAPICalls.logActivity("edit cart item",
          "get modifire list mst_cart_sub_detail", "mst_cart_sub_detail", id);
    }
    return list;
  }

  Future updateCartdetails(MST_Cart details) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.update_cart;
      var stringParams = {
        "cart_details": details,
      };
      await APICall.localapiCall(null, apiurl, stringParams);
    } else {
      await db.update("mst_cart", details.toJson(),
          where: "id =?", whereArgs: [details.id]);
      await SyncAPICalls.logActivity(
          "voucher", "add voucher in cart", "voucher", details.id);
    }
  }

  Future<int> updateCartList(List<MSTCartdetails> details) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.update_cart_items;
      var stringParams = {
        "cart_list": details,
      };
      await APICall.localapiCall(null, apiurl, stringParams);
    } else {
      for (var i = 0; i < details.length; i++) {
        await db.update("mst_cart_detail", details[i].toJson(),
            where: "id =?", whereArgs: [details[i].id]);
        await SyncAPICalls.logActivity(
            "voucher", "add voucher in cart", "voucher", details[i].id);
      }
    }
  }

  Future<dynamic> sendToKitched(ids) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.update_cart_items;
      var stringParams = {
        "ids": ids,
      };
      await APICall.localapiCall(null, apiurl, stringParams);
    } else {
      var qry = "update mst_cart_detail set is_send_kichen = 1 WHERE id in(" +
          ids.toString() +
          ")";
      var ordersList = await db.rawQuery(qry);
      await SyncAPICalls.logActivity(
          "Send to kitchen", "send item to kitchen", "mst_cart_detail", 1);
    }
  }
}
