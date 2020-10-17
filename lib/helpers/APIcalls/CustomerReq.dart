import 'dart:convert';
import 'dart:io';
import 'package:mcncashier/helpers/LocalAPI/CustomerList.dart';
import 'package:mcncashier/models/Customer.dart';

class CustomerReq {
  static getCustomerCall(request) async {
    CustomersList customer = new CustomersList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await customer.getCustomers(null, data["terminal_id"]);
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
        ..write(jsonEncode({"status": 500, "message": "Something want wrong"}));
    }
  }

  static addCustomerCall(request) async {
    CustomersList customer = new CustomersList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      Customer addcustomer = new Customer();
      var custdata = data["customer"];
      addcustomer = Customer.fromJson(custdata);
      var res = await customer.addCustomer(null, addcustomer);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({
          "status": 200,
          "message": "successfuly add customer",
        }))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something want wrong"}));
    }
  }
}
