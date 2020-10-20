import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Category.dart';
import 'package:mcncashier/models/Printer.dart';
import 'package:mcncashier/services/allTablesSync.dart';
import 'package:mcncashier/helpers/ComunAPIcall.dart';
class PrinterList {
  var db = DatabaseHelper.dbHelper.getDatabse();

  /* pass param printer_is_cashier
  * if printer_is_cashier=0 then get all printer
  * otherwise get all printer for cashier*/

  Future<List<Printer>> getAllPrinterList(context, printer_is_cashier) async {
    List<Printer> list = [];
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = "http://192.168.0.113:8080/" + Configrations.printers;
      var stringParams = {"printer_is_cashier": printer_is_cashier};
      var result = await APICall.localapiCall(context, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        list = result["data"];
      }
    } else {
      var db = DatabaseHelper.dbHelper.getDatabse();
      var qry = "";
      if (printer_is_cashier == "0") {
        qry = "SELECT * from printer where status = 1 ";
      } else {
        qry =
            "SELECT * from printer where printer_is_cashier = $printer_is_cashier AND status = 1";
      }
      var result = await db.rawQuery(qry);
      list = result.isNotEmpty
          ? result.map((c) => Printer.fromJson(c)).toList()
          : [];

      await SyncAPICalls.logActivity(
          "Product", "get all printers", "Printer", "1");
    }
    return list;
  }

  /* This method is used when Add any product in cart
  * For the print KOT from cart*/

  Future<List<Printer>> getPrinterForAddCartProduct(context, productID) async {
    List<Printer> list = [];
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = "http://192.168.0.113:8080/" + Configrations.printersForCart;
      var stringParams = {"product_id": productID};
      var result = await APICall.localapiCall(context, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        list = result["data"];
      }
    } else {
      var db = DatabaseHelper.dbHelper.getDatabse();
      var qry =
          "SELECT * from printer where printer.printer_id = (Select printer_id from product_branch WHERE product_branch.product_id = $productID)";
      var result = await db.rawQuery(qry);
      list = result.isNotEmpty
          ? result.map((c) => Printer.fromJson(c)).toList()
          : [];

      await SyncAPICalls.logActivity("Product",
          "get printer for add in cart product", "Printer", productID);
    }
    return list;
  }
}
