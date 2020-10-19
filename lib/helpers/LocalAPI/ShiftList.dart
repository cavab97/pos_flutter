import 'dart:convert';

import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/helpers/ComunAPIcall.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/services/allTablesSync.dart';

class ShiftList {
  var db = DatabaseHelper.dbHelper.getDatabse();
  Future<List<Shift>> getShiftData(context, shiftId) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var isjoin = await CommunFun.checkIsJoinServer();
    List<Shift> list = [];
    if (isjoin == true) {
      var apiurl = Configrations.ipAddress + Configrations.shift_datails;
      var stringParams = {"shift_id": shiftId};
      var result = await APICall.localapiCall(context, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list =
            data.length > 0 ? data.map((c) => Shift.fromJson(c)).toList() : [];
      }
    } else {
      var result =
          await db.query('shift', where: "shift_id = ?", whereArgs: [shiftId]);
      list = result.isNotEmpty
          ? result.map((c) => Shift.fromJson(c)).toList()
          : [];
    }
    return list;
  }

  Future<int> insertShift(context, Shift shift) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var isjoin = await CommunFun.checkIsJoinServer();
    var result;
    if (isjoin == true) {
      var apiurl = Configrations.ipAddress + Configrations.add_shift;
      var stringParams = {"shift_data": jsonEncode(shift)};
      result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        result = 1;
      }
    } else {
      if (shift.shiftId != null) {
        result = await db.update("shift", shift.toJson(),
            where: 'shift_id = ?', whereArgs: [shift.shiftId]);
      } else {
        result = await db.insert("shift", shift.toJson());
      }
      var dis = shift.shiftId != null ? "Update shift" : "Insert shift";
      await SyncAPICalls.logActivity("Product", dis, "shift", result);
    }
    return result;
  }
}
