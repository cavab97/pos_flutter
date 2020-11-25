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
      print(content);
      var data = await jsonDecode(content);
      Shift shifts = new Shift();
      shifts = Shift.fromJson(data);
      print(shifts);
      var res = await shift.insertShift(null, shifts);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({
          "status": 200,
          "message": "successfuly inserted shift",
          "shift_id": res
        }))
        ..close();
    } catch (e) {
      print(e);
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static drawerList(request) async {
    ShiftList shift = new ShiftList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await shift.getPayinOutammount(data["shift_id"]);
      await request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 200, "message": "success.", "data": res}))
        ..close();
    } catch (e) {
      print(e);
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }
}
