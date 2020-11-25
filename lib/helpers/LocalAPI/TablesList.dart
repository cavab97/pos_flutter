import 'dart:convert';

import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/helpers/ComunAPIcall.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/TableDetails.dart';
import 'package:mcncashier/models/Table_order.dart';
import 'package:mcncashier/services/allTablesSync.dart';

import '../../models/Table_order.dart';
import '../../models/saveOrder.dart';

class TablesList {
  var db = DatabaseHelper.dbHelper.getDatabse();

  Future<List<TablesDetails>> getTables(context, branchid) async {
    List<TablesDetails> list = [];
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.tables;
      var stringParams = {"branch_id": branchid};
      var result = await APICall.localapiCall(context, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => TablesDetails.fromJson(c)).toList()
            : [];
      }
    } else {
      var query =
          "SELECT tables.*, table_order.save_order_id,table_order.number_of_pax ,table_order.is_merge_table as is_merge_table, table_order.merged_table_id as merged_table_id, " +
              " (select tables.table_name from tables where table_order.merged_table_id = tables.table_id) as merge_table_name from tables " +
              " LEFT JOIN table_order on table_order.table_id = tables.table_id " +
              " WHERE tables.status = 1 AND branch_id = " +
              branchid.toString() +
              " GROUP by tables.table_id";

      var res = await db.rawQuery(query);
      list = res.isNotEmpty
          ? res.map((c) => TablesDetails.fromJson(c)).toList()
          : [];
      await SyncAPICalls.logActivity(
          "Tables", "Getting Tables list", "tables", branchid);
    }
    return list;
  }

  Future<int> insertTableOrder(context, Table_order tableOrder) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    var result;
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.add_table_order;
      var stringParams = {"table_order": tableOrder};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        result = 1;
      } else {
        CommunFun.showToast(context, result["message"]);
      }
    } else {
      var qry = "SELECT * from table_order where table_id =" +
          tableOrder.table_id.toString();
      var res = await db.rawQuery(qry);
      List<Table_order> list = res.length > 0
          ? res.map((c) => Table_order.fromJson(c)).toList()
          : [];

      if (list.length > 0) {
        result = await db.update("table_order", tableOrder.toJson(),
            where: 'table_id =?', whereArgs: [tableOrder.table_id]);
      } else {
        result = await db.insert("table_order", tableOrder.toJson());
      }
      await SyncAPICalls.logActivity(
          "Tables",
          list.length > 0 ? "Update table Order" : "Insert table Order",
          "table_order",
          tableOrder.table_id);
    }
    return result;
  }

  Future<List<TablesDetails>> getTableDetails(branchid, tableID) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    List<TablesDetails> list = [];
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.table_Details;
      var stringParams = {"branch_id": branchid, "table_id": tableID};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => TablesDetails.fromJson(c)).toList()
            : [];
      }
    } else {
      var query =
          "SELECT tables.*, table_order.save_order_id,table_order.number_of_pax from tables " +
              " LEFT JOIN table_order on table_order.table_id = " +
              tableID.toString() +
              " WHERE tables.table_id= " +
              tableID.toString() +
              " AND tables.status = 1 AND branch_id = " +
              branchid;
      var res = await db.rawQuery(query);
      list = res.length > 0
          ? res.map((c) => TablesDetails.fromJson(c)).toList()
          : [];
      await SyncAPICalls.logActivity(
          "tables", "get table details", "tables", tableID);
    }
    return list;
  }

  Future<List<Table_order>> getTableOrders(tableid) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    List<Table_order> list = [];
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.table_orders;
      var stringParams = {"table_id": tableid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => Table_order.fromJson(c)).toList()
            : [];
      }
    } else {
      var qry =
          "SELECT * from table_order where table_id = " + tableid.toString();
      var tableList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
      list = tableList.isNotEmpty
          ? tableList.map((c) => Table_order.fromJson(c)).toList()
          : [];
    }
    return list;
  }

  Future<int> mergeTableOrder(context, Table_order tableOrder) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    var result;
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.merge_table_order;
      var stringParams = {"table_order": tableOrder};
      var res = await APICall.localapiCall(null, apiurl, stringParams);
      if (res["status"] == Constant.STATUS200) {
        result = 1;
      } else {
        CommunFun.showToast(context, res["message"]);
      }
    } else {
      var db = DatabaseHelper.dbHelper.getDatabse();
      var qry = "SELECT * from table_order where table_id =" +
          tableOrder.merged_table_id.toString();
      var res = await db.rawQuery(qry);
      List<Table_order> list = res.isNotEmpty
          ? res.map((c) => Table_order.fromJson(c)).toList()
          : [];
      if (list.length > 0) {
        if (list[0].save_order_id != 0) {
          List<SaveOrder> cartIDs =
              await localAPI.gettableCartID(list[0].save_order_id);
          if (tableOrder.save_order_id == 0 && list[0].save_order_id != 0) {
            if (cartIDs.length > 0) {
              var qry1 = "UPDATE mst_cart SET table_id = " +
                  tableOrder.table_id.toString() +
                  " where id = " +
                  cartIDs[0].cartId.toString();
              var result1 = await db.rawQuery(qry1);
              list[0].table_id = tableOrder.table_id;
              var qry2 = "UPDATE table_order SET table_id = " +
                  tableOrder.table_id.toString() +
                  " where table_id = " +
                  list[0].table_id.toString();
              var res = await db.rawQuery(qry2);
              var qrysabve = "UPDATE save_order SET cart_id = " +
                  cartIDs[0].cartId.toString() +
                  " where id = " +
                  list[0].save_order_id.toString();
              var res1 = await db.rawQuery(qrysabve);
              tableOrder.save_order_id = list[0].save_order_id;
            }
          } else {
            if (tableOrder.save_order_id != 0 && cartIDs.length > 0) {
              List<SaveOrder> carts =
                  await localAPI.gettableCartID(tableOrder.save_order_id);
              if (carts.length > 0) {
                var detailqry = "UPDATE mst_cart_detail SET cart_id = " +
                    carts[0].cartId.toString() +
                    " where cart_id = " +
                    cartIDs[0].cartId.toString();
                var res1 = await db.rawQuery(detailqry);
              }
            }
            await deleteTableOrder(list[0].table_id);
            await deleteSaveOrder(list[0].save_order_id);
          }
        } else {
          await deleteTableOrder(list[0].table_id);
          await deleteSaveOrder(list[0].save_order_id);
        }
      }
      await insertTableOrder(context, tableOrder);
      await SyncAPICalls.logActivity(
          "Tables",
          list.length > 0 ? "Update table Order" : "Insert table Order",
          "table_order",
          tableOrder.table_id);
      result = 1;
    }
    return result;
  }

  Future deleteTableOrder(tableID) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    await db.delete("table_order", where: 'table_id = ?', whereArgs: [tableID]);
  }

  Future deleteSaveOrder(id) async {
    if (id != 0) {
      var db = DatabaseHelper.dbHelper.getDatabse();
      await db.delete("save_order", where: 'id  =?', whereArgs: [id]);
    }
  }

  Future changeTable(tableID, totableid, cartid) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.change_table;
      var stringParams = {
        "table_id": tableID,
        "to_table_id": totableid,
        "cart_id": cartid
      };
      await APICall.localapiCall(null, apiurl, stringParams);
    } else {
      var qry = "UPDATE table_order SET table_id = " +
          totableid.toString() +
          " where table_id = " +
          tableID.toString();
      var result = await db.rawQuery(qry);
      if (cartid != null) {
        var qry1 = "UPDATE mst_cart SET table_id = " +
            totableid.toString() +
            " where  id = " +
            cartid.toString();
        var result1 = await db.rawQuery(qry1);
      }
    }
  }
}
