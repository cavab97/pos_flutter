import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/helpers/ComunAPIcall.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Drawer.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/models/ShiftInvoice.dart';
import 'package:mcncashier/services/allTablesSync.dart';

class ShiftList {
  var db = DatabaseHelper.dbHelper.getDatabse();
  Future<List<Shift>> getShiftData(context, shiftId) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var isjoin = await CommunFun.checkIsJoinServer();
    List<Shift> list = [];
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.shift_datails;
      var stringParams = {"shift_id": shiftId};
      var result = await APICall.localapiCall(context, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list =
            data.length > 0 ? data.map((c) => Shift.fromJson(c)).toList() : [];
      }
    } else {
      var result =
          await db.query('shift', where: "app_id = ?", whereArgs: [shiftId]);
      list = result.isNotEmpty
          ? result.map((c) => Shift.fromJson(c)).toList()
          : [];
    }
    return list;
  }

  Future<int> insertShift(context, Shift shift, shiftId) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var isjoin = await CommunFun.checkIsJoinServer();
    int result;
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.add_shift;
      var stringParams = {"shift": shift, "shift_id": shiftId};
      var res =  await APICall.localapiCall(null, apiurl, stringParams);
      if (res["status"] == Constant.STATUS200) {
        result = res["shift_id"];
      }
    } else {
      if (shiftId != null) {
        var qry = "UPDATE shift set end_amount = " +
            shift.endAmount.toString() +
            " ,updated_at = '" +
            shift.updatedAt +
            "' where app_id = " +
            shift.appId.toString();
        var res = await db.rawQuery(qry);
      } else {
        var res = await db.insert("shift", shift.toJson());
      }
      result = shift.appId;
      var dis = shiftId != null ? "Update shift" : "Insert shift";
      await SyncAPICalls.logActivity("Product", dis, "shift", shift.appId);
    }
    return result;
  }

  Future<List<Drawerdata>> getPayinOutammount(shiftid) async {
    List<Drawerdata> drawerList = new List<Drawerdata>();
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.drawer_data;
      var stringParams = {"shift_id": shiftid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        drawerList = data.length > 0
            ? data.map((c) => Drawerdata.fromJson(c)).toList()
            : [];
      }
    } else {
      var qry = "SELECT * from drawer where shift_id = " + shiftid.toString();
      var mealList = await db.rawQuery(qry);
      drawerList = mealList.isNotEmpty
          ? mealList.map((c) => Drawerdata.fromJson(c)).toList()
          : [];
      await SyncAPICalls.logActivity(
          "Meals product List", "Meals product List", "drawer", shiftid);
    }
    return drawerList;
  }

  Future<int> saveInOutDrawerData(Drawerdata drawerData) async {
    var inveID;
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.add_drawer;
      var stringParams = {"drawer": drawerData};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        inveID = 1;
      }
    } else {
      inveID = await db.insert("drawer", drawerData.toJson());
    }
    return inveID;
  }

  Future<int> getLastShiftAppID(terminalid) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    int app_id;
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.shift_app_id;
      var stringParams = {"terminal_id": terminalid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        app_id = result["app_id"];
      }
    } else {
      var qry = "SELECT shift.app_id from shift where terminal_id =" +
          terminalid.toString() +
          "  ORDER BY app_id DESC LIMIT 1";
      var checkisExit = await db.rawQuery(qry);
      List<Shift> list = checkisExit.length > 0
          ? checkisExit.map((c) => Shift.fromJson(c)).toList()
          : [];
      if (list.length > 0) {
        app_id = list[0].appId;
      } else {
        app_id = 0;
      }
    }
    return app_id;
  }

  Future<int> getLastShiftInvoiceAppID(terminalid) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    int appId;
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.shift_Invoice_app_id;
      var stringParams = {"terminal_id": terminalid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        appId = result["app_id"];
      }
    } else {
      var qry =
          "SELECT shift_invoice.app_id from shift_invoice where terminal_id =" +
              terminalid +
              "  ORDER BY app_id DESC LIMIT 1";
      var checkisExit = await db.rawQuery(qry);
      List<ShiftInvoice> list = checkisExit.length > 0
          ? checkisExit.map((c) => ShiftInvoice.fromJson(c)).toList()
          : [];
      if (list.length > 0) {
        appId = list[0].app_id;
      } else {
        appId = 0;
      }
    }
    return appId;
  }

  Future<dynamic> getshiftID() async {
    var shiftid;
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.shift_id;
      var stringParams = {};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        shiftid = result["shift_id"];
      }
    } else {
      shiftid = await Preferences.getStringValuesSF(Constant.DASH_SHIFT);
    }
    return shiftid;
  }

  Future<dynamic> getshifisOpen() async {
    var isOpen;
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.check_shift;
      var stringParams = {};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        isOpen = result["data"];
      }
    } else {
      isOpen = await Preferences.getStringValuesSF(Constant.IS_SHIFT_OPEN);
    }
    return isOpen;
  }
}
