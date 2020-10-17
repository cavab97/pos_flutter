import 'dart:convert';
import 'dart:io';
import 'package:mcncashier/helpers/LocalAPI/PaymentList.dart';

class PaymenntReq {
  static getPaymentMethods(request) async {
    PaymentList payment = new PaymentList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await payment.getPaymentMethods();
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 200, "message": "success.", "data": res}))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something want wrong"}))
        ..close();
    }
  }
}
