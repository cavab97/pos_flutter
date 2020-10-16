import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/helpers/ComunAPIcall.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/TableDetails.dart';
import 'package:mcncashier/models/Table_order.dart';
import 'package:mcncashier/services/allTablesSync.dart';

class TablesList {
  var db = DatabaseHelper.dbHelper.getDatabse();

  Future<List<TablesDetails>> getTables(context, branchid) async {
    List<TablesDetails> list = [];
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = "http://192.168.1.115/" + Configrations.tables;
      var stringParams = {"branch_id": branchid};
      var result = await APICall.localapiCall(context, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        list = result["data"];
      }
    } else {
      var query = "SELECT tables.*, table_order.save_order_id,table_order.number_of_pax ,table_order.is_merge_table as is_merge_table, table_order.merged_table_id as merged_table_id, " +
          " (select tables.table_name from tables where table_order.merged_table_id = tables.table_id) as merge_table_name from tables " +
          " LEFT JOIN table_order on table_order.table_id = tables.table_id " +
          " WHERE tables.status = 1 AND branch_id = " +
          branchid.toString() +
          // " AND tables.table_id NOT IN (select table_order.merged_table_id from table_order) " +
          " GROUP by tables.table_id";

      var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
      list = res.isNotEmpty
          ? res.map((c) => TablesDetails.fromJson(c)).toList()
          : [];
      await SyncAPICalls.logActivity(
          "Tables", "Getting Tables list", "tables", branchid);
    }
    return list;
  }

  Future<int> insertTableOrder(Table_order tableOrder) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
    } else {
      var qry = "SELECT * from table_order where table_id =" +
          tableOrder.table_id.toString();
      var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
      List<Table_order> list = res.isNotEmpty
          ? res.map((c) => Table_order.fromJson(c)).toList()
          : [];
      var result;
      if (list.length > 0) {
        result = await db.update("table_order", tableOrder.toJson(),
            where: 'table_id = ?', whereArgs: [tableOrder.table_id]);
      } else {
        result = await db.insert("table_order", tableOrder.toJson());
      }
      await SyncAPICalls.logActivity(
          "Tables",
          list.length > 0 ? "Update table Order" : "Insert table Order",
          "table_order",
          tableOrder.table_id);
    }
  }
}
