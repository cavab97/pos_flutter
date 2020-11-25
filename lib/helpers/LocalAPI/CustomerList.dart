import 'dart:convert';

import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/helpers/ComunAPIcall.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Citys.dart';
import 'package:mcncashier/models/Countrys.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/States.dart';
import 'package:mcncashier/services/allTablesSync.dart';

class CustomersList {
  var db = DatabaseHelper.dbHelper.getDatabse();

  Future<List<Customer>> getCustomers(context, teminalid) async {
    List<Customer> list = [];
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.customers;
      var stringParams = {"terminal_id": teminalid};
      var result = await APICall.localapiCall(context, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => Customer.fromJson(c)).toList()
            : [];
      }
    } else {
      var query = "SELECT * from customer WHERE customer.status = 1";
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
      var apiurl = await Configrations.ipAddress() + Configrations.add_customer;
      var stringParams = {"customer": jsonEncode(customer)};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        result = 1;
      }
    } else {
      result = await db.insert("customer", customer.toJson());
      await SyncAPICalls.logActivity(
          "Customer", "Adding customer", "customer", result);
    }
    return result;
  }

  Future<List<Countrys>> getCountrysList() async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var contryList = await db.query("country");
    List<Countrys> list = contryList.isNotEmpty
        ? contryList.map((c) => Countrys.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<States>> getStatesList() async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var stateList = await db.query("state");
    List<States> list = stateList.isNotEmpty
        ? stateList.map((c) => States.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<Citys>> getCitysList() async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var cityList = await db.query("city");
    List<Citys> list = cityList.isNotEmpty
        ? cityList.map((c) => Citys.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<dynamic> getCustomerAddressList() async {
    var isjoin = await CommunFun.checkIsJoinServer();
    dynamic listdata;
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.get_addresses;
      var stringParams = {};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        dynamic data = result["data"];
        listdata = data;
        return listdata;
      }
    } else {
      var citys = await getCitysList();
      var states = await getStatesList();
      var countrys = await getCountrysList();
      dynamic addressList = {
        "Country": countrys,
        "State": states,
        "City": citys
      };
      return addressList;
    }
  }
}
