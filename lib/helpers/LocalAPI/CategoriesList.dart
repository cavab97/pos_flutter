import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/helpers/ComunAPIcall.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Category.dart';
import 'package:mcncashier/services/allTablesSync.dart';

class CategoriesList {
  var db = DatabaseHelper.dbHelper.getDatabse();
  Future<List<Category>> getCategories(context, branchID) async {
    List<Category> list = [];
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.categories;
      var stringParams = {"branch_id": branchID};
      var result = await APICall.localapiCall(context, apiurl, stringParams);
      if (result != null && result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => Category.fromJson(c)).toList()
            : [];
      }
    } else {
      var query = "select * from category left join category_branch on " +
          " category_branch.category_id = category.category_id AND category_branch.status = 1 where " +
          " category_branch.branch_id =" +
          branchID.toString() +
          " AND category.status = 1";
      var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
      list =
          res.length > 0 ? res.map((c) => Category.fromJson(c)).toList() : [];
      await SyncAPICalls.logActivity(
          "Product", "geting category List", "category", branchID);
    }
    return list;
  }
}
