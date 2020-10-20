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
      var apiurl = await Configrations.ipAddress() + Configrations.payment_Methods;
      var stringParams;
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => Payments.fromJson(c)).toList()
            : [];
      }
    } else {
      var query = "SELECT * from payment where status = 1";
      var res = await db.rawQuery(query);
      list =
          res.length > 0 ? res.map((c) => Payments.fromJson(c)).toList() : [];
      await SyncAPICalls.logActivity(
          "payment", "get payment list", "payment", 1);
    }
    return list;
  }

  Future<Payments> getOrderpaymentmethod(methodID) async {
    Payments payment = new Payments();
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.payment_Methods;
      var stringParams = {"payment_id": methodID};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        dynamic data = result["data"];
        payment = Payments.fromJson(data);
      }
    } else {
      var paymentMeth = await db.query('payment',
          where: 'payment_id = ?', whereArgs: [methodID.toString()]);
      List<Payments> list = paymentMeth.isNotEmpty
          ? paymentMeth.map((c) => Payments.fromJson(c)).toList()
          : [];
      payment = list[0];
    }
    return payment;
  }
}
