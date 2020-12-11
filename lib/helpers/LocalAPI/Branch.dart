import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/helpers/ComunAPIcall.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/models/BranchTax.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/PosPermission.dart';
import 'package:mcncashier/models/Terminal.dart';
import 'package:mcncashier/services/allTablesSync.dart';

class BranchList {
  var db = DatabaseHelper.dbHelper.getDatabse();
  Future<Branch> getbranchData(branchID) async {
    Branch list = new Branch();
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.branch_detail;
      var stringParams = {"branch_id": branchID};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        dynamic list1 = result["data"];
        list = Branch.fromJson(list1);
      }
    } else {
      var db = DatabaseHelper.dbHelper.getDatabse();
      var cartdata = await db.query('branch',
          where: 'branch_id = ?', whereArgs: [branchID.toString()]);
      List<Branch> res = cartdata.isNotEmpty
          ? cartdata.map((c) => Branch.fromJson(c)).toList()
          : [];
      list = res[0];
    }
    return list;
  }

  Future<List<BranchTax>> getTaxList(branchid) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    List<BranchTax> list = [];
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.branch_tax;
      var stringParams = {"branch_id": branchid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> list1 = result["data"];
        list = list1.length > 0
            ? list1.map((c) => BranchTax.fromJson(c)).toList()
            : [];
      }
    } else {
      var tax = await db.rawQuery(
          "SELECT branch_tax.*,tax.code From branch_tax " +
              " Left join  tax on tax.tax_id = branch_tax.tax_id " +
              " WHERE branch_tax.status = 1 AND branch_id =" +
              branchid.toString());
      list =
          tax.isNotEmpty ? tax.map((c) => BranchTax.fromJson(c)).toList() : [];
    }
    return list;
  }

  Future<Terminal> getTerminalDetails(terminalkey) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    Terminal terminalDat;
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.terminal_data;
      var stringParams = {"terminal_id": terminalkey};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        dynamic list1 = result["data"];
        terminalDat = Terminal.fromJson(list1);
      }
    } else {
      var query = "SELECT * from terminal WHERE terminal_id  =$terminalkey";
      var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
      List<Terminal> list =
          res.length > 0 ? res.map((c) => Terminal.fromJson(c)).toList() : [];

      if (list.length > 0) {
        terminalDat = list[0];
      }
    }
    return terminalDat;
  }

  Future<int> getLastCustomerid(terminalid) async {
    int custid;
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.lastcustomer_id;
      var stringParams = {"terminal_id": terminalid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        dynamic list1 = result["data"];
        custid = list1;
      }
    } else {
      var qry = "SELECT customer.app_id from customer where terminal_id =" +
          terminalid +
          "  ORDER BY app_id DESC LIMIT 1";
      var checkisExit =
          await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
      List<Customer> list = checkisExit.length > 0
          ? checkisExit.map((c) => Customer.fromJson(c)).toList()
          : [];
      if (list.length > 0) {
        custid = list[0].appId;
      }
    }
    return custid;
  }

  Future<List<PosPermission>> getUserPermissions(userid) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    List<PosPermission> list = new List<PosPermission>();
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.get_user_permission;
      var stringParams = {"user_id": userid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        dynamic list1 = result["data"];
        list = list1.length > 0
            ? list1.map((c) => PosPermission.fromJson(c)).toList()
            : [];
      }
    } else {
      var qry = " SELECT  group_concat(pos_permission.pos_permission_name) as pos_permission_name  from users" +
          " Left join user_pos_permission on user_pos_permission.user_id = users.id  AND user_pos_permission.status = 1" +
          " left join pos_permission on pos_permission.pos_permission_id = user_pos_permission.pos_permission_id" +
          " WHERE user_id  =" +
          userid.toString();
      var permissionList = await db.rawQuery(qry);
      list = permissionList.length > 0
          ? permissionList.map((c) => PosPermission.fromJson(c)).toList()
          : [];
      await SyncAPICalls.logActivity("get PosPermission",
          "get PosPermission list", "pos_permission", userid);
    }
    return list;
  }
}
