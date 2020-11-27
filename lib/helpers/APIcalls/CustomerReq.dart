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
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
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
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static getCustomerAddList(request) async {
    CustomersList customer = new CustomersList();
    try {
      var res = await customer.getCustomerAddressList();
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({
          "status": 200,
          "message": "Customer country city state",
          "data": res
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

  static getCustomerRedeem(request) async {
    CustomersList customer = new CustomersList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await customer.getCustomerRedeem(data["customer_id"]);
      await request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode(
            {"status": 200, "message": "Customer redeem", "data": res}))
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
