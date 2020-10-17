import 'dart:convert';
import 'dart:io';
import 'package:mcncashier/helpers/LocalAPI/CategoriesList.dart';
import 'package:mcncashier/helpers/LocalAPI/CheckinOutList.dart';
import 'package:mcncashier/models/CheckInout.dart';

class CheckInOutReq {
  static userCheckInOut(request) async {
    try {
      CheckinOutList catCall = new CheckinOutList();
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      CheckinOut checkinoutdata =
          new CheckinOut.fromJson(jsonDecode(data["checkinout_data"]));
      var res = await catCall.userCheckInOut(checkinoutdata);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(
          jsonEncode({
            "status": 200,
            "message": "successfully intsert check inout data",
            "shift_id": res
          }),
        )
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write(jsonEncode({"status": 500, "message": "Something want wrong"}))
        ..close();
    }
  }
}
