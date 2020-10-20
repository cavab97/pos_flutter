import 'dart:convert';
import 'dart:io';
import 'package:mcncashier/helpers/LocalAPI/ShiftList.dart';
import 'package:mcncashier/models/Shift.dart';

class ShiftReq {
  static getShiftList(request) async {
    try {
      ShiftList shift = new ShiftList();
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await shift.getShiftData(null, data["shift_id"]);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({
          "status": 200,
          "message": res.length > 0 ? "success" : "No data Found",
          "data": res
        }))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static addShift(request) async {
    ShiftList shift = new ShiftList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      Shift shifts = new Shift();
      var tabledata = data["shift_data"];
      shifts = Shift.fromJson(tabledata);
      var res = await shift.insertShift(null, shifts);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({
          "status": 200,
          "message": "successfuly inserted shift",
        }))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }
}
