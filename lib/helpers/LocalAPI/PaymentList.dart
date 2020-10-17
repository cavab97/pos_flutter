import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/helpers/ComunAPIcall.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/services/allTablesSync.dart';

class PaymentList {
  var db = DatabaseHelper.dbHelper.getDatabse();
  Future<List<Payments>> getPaymentMethods() async {
    List<Payments> list = [];
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = "http://192.168.0.113:8080/" + Configrations.payment_Methods;
      var stringParams;
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        list = result["data"];
      }
    } else {
      var query = "SELECT * from payment where status = 1";
      var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
      List<Payments> list =
          res.isNotEmpty ? res.map((c) => Payments.fromJson(c)).toList() : [];
      await SyncAPICalls.logActivity(
          "payment", "get payment list", "payment", 1);
    }
    return list;
  }
}
