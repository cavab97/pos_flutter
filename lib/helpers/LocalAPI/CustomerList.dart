import 'dart:convert';

import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/helpers/ComunAPIcall.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/services/allTablesSync.dart';

class CustomersList {
  var db = DatabaseHelper.dbHelper.getDatabse();

  Future<List<Customer>> getCustomers(context, teminalid) async {
    List<Customer> list = [];
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = "http://192.168.0.113:8080/" + Configrations.customers;
      var stringParams = {"terminal_id": teminalid};
      var result = await APICall.localapiCall(context, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        list = result["data"];
      }
    } else {
      var query = "SELECT * from customer WHERE " +
          " customer.status = 1 AND terminal_id = " +
          teminalid.toString();
      var res = await db.rawQuery(query);
      list =
          res.isNotEmpty ? res.map((c) => Customer.fromJson(c)).toList() : [];
      await SyncAPICalls.logActivity(
          "Customer", "geting customer list", "customer", teminalid);
    }
    return list;
  }

  Future<int> addCustomer(context, Customer customer) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var isjoin = await CommunFun.checkIsJoinServer();
    var result;
    if (isjoin == true) {
      var apiurl = "http://192.168.0.113:8080/" + Configrations.add_customer;
      var stringParams = {"customer": jsonEncode(customer)};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        result = 1;
      }
    } else {
      var result = await db.insert("customer", customer.toJson());
      await SyncAPICalls.logActivity(
          "Customer", "Adding customer", "customer", result);
    }
    return result;
  }
}
