import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/helpers/ComunAPIcall.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/models/BranchTax.dart';

class BranchList {
  var db = DatabaseHelper.dbHelper.getDatabse();
  Future<Branch> getbranchData(branchID) async {
    Branch list = new Branch();
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = Configrations.ipAddress + Configrations.branch_detail;
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
      var apiurl = Configrations.ipAddress + Configrations.branch_detail;
      var stringParams = {"branch_id": branchid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        dynamic list1 = result["data"];
        list = list1.isNotEmpty
            ? list1.map((c) => BranchTax.fromJson(c)).toList()
            : [];
      }
    } else {
      var tax = await db.rawQuery(
          "SELECT branch_tax.*,tax.code From branch_tax " +
              " Left join   tax on tax.tax_id = branch_tax.tax_id " +
              " WHERE branch_id =" +
              branchid.toString());
      list =
          tax.isNotEmpty ? tax.map((c) => BranchTax.fromJson(c)).toList() : [];
    }
    return list;
  }
}
