import 'dart:convert';

import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/helpers/ComunAPIcall.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/CheckInout.dart';
import 'package:mcncashier/services/allTablesSync.dart';

class CheckinOutList {
  var db = DatabaseHelper.dbHelper.getDatabse();

  Future<int> userCheckInOut(CheckinOut clockinOutData) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var shiftid;
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = "http://192.168.0.113:8080/" + Configrations.checkIn_Out;
      var stringParams = {"checkinout_data": jsonEncode(clockinOutData)};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        shiftid = result["shift_id"];
      }
    } else {
      if (clockinOutData.status == "IN") {
        shiftid = await db.insert("user_checkinout", clockinOutData.toJson());
      } else {
        shiftid = await db.update("user_checkinout", clockinOutData.toJson(),
            where: 'id = ?', whereArgs: [clockinOutData.id]);
      }
      var dis =
          clockinOutData.status == "IN" ? "User checkin" : "user checkout";
      await SyncAPICalls.logActivity(
          "PIN number", dis, "user_checkinout", shiftid);
    }
    return shiftid;
  }
}
