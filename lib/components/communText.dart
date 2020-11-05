import 'dart:async';
import 'dart:convert';
import 'package:mcncashier/models/BranchTax.dart';
import 'package:mcncashier/models/CheckInout.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/PosPermission.dart';
import 'package:mcncashier/models/Printer.dart';
import 'package:mcncashier/models/SetMeal.dart';
import 'package:mcncashier/models/Table.dart';
import 'package:mcncashier/models/Table_order.dart';
import 'package:mcncashier/models/SetMeal.dart';
import 'package:mcncashier/models/Table.dart';
import 'package:mcncashier/models/Tax.dart';
import 'package:mcncashier/models/mst_sub_cart_details.dart';
import 'package:mcncashier/models/saveOrder.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/services/allTablesSync.dart';
import 'package:mcncashier/services/tableSyncAPI.dart' as repo;
import 'package:toast/toast.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:intl/intl.dart';

DatabaseHelper databaseHelper = DatabaseHelper();
LocalAPI localAPI = LocalAPI();
Timer timer;
double taxvalues = 0;

class CommunFun {
  static loginText() {
    return Text(Strings.login_text,
        style: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
  }

  static checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  static isLogged() async {
    var loginUser = await Preferences.getStringValuesSF(Constant.IS_LOGIN);
    if (loginUser != null) {
      return true;
    } else {
      return false;
    }
  }

  static overLayLoader() {
    return Container(
      padding: EdgeInsets.all(10),
      height: 70,
      width: 70,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100), color: Colors.white),
      child: CircularProgressIndicator(
        strokeWidth: 4,
        backgroundColor: Colors.grey[200],
      ),
    );
  }

  static divider() {
    // Simple divider
    return Padding(
      padding: EdgeInsets.all(10),
      child: Divider(
        height: 1,
        thickness: 1.0,
        color: Colors.grey[400],
      ),
    );
  }

  static forgotPasswordText(context) {
    // forgot password text
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.centerRight,
      child: Text(
        Strings.forgot_password,
        style: TextStyle(color: Colors.blue, fontSize: 22),
      ),
    );
  }

  static roundedButton(text, BuildContext context, _onPress) {
    SizeConfig().init(context);

    //round button like Login button
    return RaisedButton(
      padding: EdgeInsets.only(
          top: SizeConfig.safeBlockVertical * 3,
          bottom: SizeConfig.safeBlockVertical * 3),
      onPressed: _onPress,
      child: Text(text, style: Styles.whiteBold()),
      color: Colors.deepOrange,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
    );
  }

  static searchBar(onChange) {
    // search input
    TextField(
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 25, right: 25),
          child: Icon(
            Icons.search,
            color: Colors.deepOrange,
            size: 40,
          ),
        ),
        hintText: "Search product here...",
        hintStyle: TextStyle(fontSize: 25.0, color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
        ),
        filled: true,
        contentPadding: EdgeInsets.only(top: 25, bottom: 25),
        fillColor: Colors.white,
      ),
      style: TextStyle(color: Colors.black, fontSize: 25.0),
      onChanged: (e) {
        print(e);
      },
    );
  }

  static deviceInfo() async {
    // Device Info
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    var deviceData;
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceData = {
          "deviceId": androidInfo.device,
          "deviceToken": androidInfo.androidId,
          "deviceType": androidInfo.type
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceData = {
          "deviceId": iosInfo.identifierForVendor,
          "deviceToken": iosInfo.utsname.machine,
          "deviceType": iosInfo.name
        };
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
    return deviceData;
  }

  static loader(context) {
    // basic Loader
    return Center(
      child: Container(
        height: 50.0,
        width: 50.0,
        child: CircularProgressIndicator(
          backgroundColor: Colors.white,
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
        ),
      ),
    );
  }

  static showToast(context, message) {
    Toast.show(
      message,
      context,
      duration: Toast.LENGTH_SHORT,
      gravity: Toast.CENTER,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  static syncDailog(context, title) {
    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0))),
        content: Builder(
          builder: (context) {
            return Container(
              height: 150,
              width: 150,
              child: Center(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CommunFun.loader(context),
                  SizedBox(
                    height: 30,
                  ),
                  Text(title, style: Styles.normalBlack())
                ],
              )),
            );
          },
        ));
  }

  static opneSyncPop(context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return syncDailog(context, Strings.syncText);
      },
    );
  }

  static syncOrdersANDStore(context, isClose) async {
    await CommunFun.getsetWebOrders(context);
    await SyncAPICalls.sendCustomerTable(context);
    await SyncAPICalls.syncOrderstoDatabase(context);
    await SyncAPICalls.sendInvenotryTable(context);
    await SyncAPICalls.sendCancledOrderTable(context);
    if (isClose) {
      Navigator.of(context).pop();
    }
  }

  static syncAfterSuccess(context, isOpen) async {
    if (isOpen) {
      opneSyncPop(context);
    }
    var lastSync = await Preferences.getStringValuesSF(Constant.LastSync_Table);
    if (lastSync == null) {
      CommunFun.getDataTables1(context, isOpen);
    } else if (lastSync == "1") {
      CommunFun.getDataTables2(context);
    } else if (lastSync == "2") {
      CommunFun.getDataTables3(context);
    } else if (lastSync == "3") {
      CommunFun.getDataTables4(context);
    } else {
      Navigator.of(context).pop();
      Navigator.pushNamed(context, Constant.PINScreen);
    }
  }

  static setServerTime(data, lastSync) async {
    if (data != null) {
      await Preferences.setStringToSF(
          Constant.SERVER_TIME_ZONE, data["data"]["timezone"]);
      await Preferences.setStringToSF(
          Constant.SERVER_DATE_TIME, data["data"]["serverdatetime"]);
    }
    await Preferences.setStringToSF(Constant.LastSync_Table, lastSync);
  }

  static getDataTables1(context, isOpen) async {
    // start with 1 tables
    var data1 = await SyncAPICalls.getDataServerBulk1(context); //api call 1
    if (data1 != null) {
      databaseHelper.insertData1(data1["data"]);
      CommunFun.setServerTime(null, "1");
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }

    var data2_1 =
        await SyncAPICalls.getDataServerBulk2_1(context); //api call 2_1
    if (data2_1 != null) {
      databaseHelper.insertData2_1(data2_1["data"]);
      CommunFun.setServerTime(null, "1");
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }

    var data2_2 =
        await SyncAPICalls.getDataServerBulk2_2(context); //api call 2_2
    if (data2_2 != null) {
      databaseHelper.insertData2_2(data2_2["data"]);
      CommunFun.setServerTime(null, "1");
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }
    var data2_3 =
        await SyncAPICalls.getDataServerBulk2_3(context); //api call 2_3
    if (data2_3 != null) {
      databaseHelper.insertData2_3(data2_3["data"]);
      CommunFun.setServerTime(null, "2");
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }

    var data3 = await SyncAPICalls.getDataServerBulk3(context); // call 3
    if (data3 != null) {
      databaseHelper.insertData3(data3["data"]);
      CommunFun.setServerTime(null, "3");
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }
    var data4_1 = await SyncAPICalls.getDataServerBulk4_1(context);
    if (data4_1 != null) {
      databaseHelper.insertData4_1(data4_1["data"]);
      CommunFun.setServerTime(null, "3");
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }
    var data4_2 = await SyncAPICalls.getDataServerBulk4_2(context);
    if (data4_2 != null) {
      var result = await databaseHelper.insertData4_2(data4_2["data"]);
      print(result);
      if (result == 1) {
        CommunFun.setServerTime(null, "4");
      } else {
        print("Error when getting data4_3");
      }
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }

    var countrys = await SyncAPICalls.getDataServerBulkAddressData(context);
    if (countrys != null) {
      var result = await databaseHelper.insertAddressData(countrys["data"]);
      print(result);
      if (result == 1) {
        CommunFun.setServerTime(null, "4");
      } else {
        print("Error when getting counry state city");
      }
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }
    getAssetsData(context, isOpen);
  }

  static getAssetsData(context, isOpen) async {
    var offset = await CommunFun.getOffset();
    var aceets = await SyncAPICalls.getAssets(context);
    if (aceets != null) {
      await databaseHelper.accetsData(aceets["data"]);
      await Preferences.setStringToSF(
          Constant.OFFSET, aceets["data"]["next_offset"].toString());
      print(aceets["data"]["product_image"]);
      if (offset == null) {
        if (aceets["data"]["next_offset"] != 0) {
          getAssetsData(context, isOpen);
        }
        if (isOpen) {
          Navigator.of(context).pop();
        }
        var serverTime =
            await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);
        if (serverTime == null) {
          Navigator.pushNamed(context, Constant.PINScreen);
        } else {
          await checkUserDeleted(context);
          await checkpermission();
          Navigator.pushNamed(context, Constant.DashboardScreen);
        }
      } else {
        if (aceets["data"]["next_offset"] == 0) {
          await CommunFun.setServerTime(aceets, "4");
        } else {
          getAssetsData(context, isOpen);
        }
      }
    } else {
      // handle Exaption
      print("Error when getting product image data");
    }
  }

  static checkpermission() async {
    var loginUser = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
    var user = json.decode(loginUser);
    var id = user["id"];
    checkUserPermission(id);
  }

  static checkUserDeleted(context) async {
    var loginUser = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
    var user = json.decode(loginUser);
    var pin = user["user_pin"];
    List<User> checkUserExit = await localAPI.checkUserExit(pin);
    if (checkUserExit.length == 0) {
      checkoutMenualy(context, user["id"]);
    }
  }

  static checkoutMenualy(context, id) async {
    CheckinOut checkIn = new CheckinOut();
    var shiftid = await Preferences.getStringValuesSF(Constant.SHIFT_ID);
    var terminalId = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    var date = DateTime.now();
    checkIn.id = int.parse(shiftid);
    checkIn.localID = await CommunFun.getLocalID();
    checkIn.terminalId = int.parse(terminalId);
    checkIn.userId = id;
    checkIn.branchId = int.parse(branchid);
    checkIn.status = "OUT";
    checkIn.timeInOut = date.toString();
    checkIn.sync = 0;
    var result = await localAPI.userCheckInOut(checkIn);
    clearAfterCheckout(context);
    CommunFun.showToast(context, "User deleted from database.");
  }

  static clearAfterCheckout(context) async {
    await Preferences.removeSinglePref(Constant.IS_CHECKIN);
    await Preferences.removeSinglePref(Constant.SHIFT_ID);
    await Preferences.removeSinglePref(Constant.LOIGN_USER);
    await Preferences.removeSinglePref(Constant.USER_PERMISSION);
    await Navigator.pushNamed(context, Constant.PINScreen);
  }

  static getDataTables2(context) async {
    // start api call fron second api
    var data2_1 =
        await SyncAPICalls.getDataServerBulk2_1(context); //api call 2_1
    if (data2_1 != null) {
      databaseHelper.insertData2_1(data2_1["data"]);
    } else {
      // handle Exaption
      print("Error when getting data2_1");
    }
    var data2_2 =
        await SyncAPICalls.getDataServerBulk2_2(context); //api call 2_2
    if (data2_2 != null) {
      databaseHelper.insertData2_2(data2_2["data"]);
    } else {
      // handle Exaption
      print("Error when getting data2_2");
    }
    var data2_3 =
        await SyncAPICalls.getDataServerBulk2_3(context); //api call 2_3
    if (data2_3 != null) {
      databaseHelper.insertData2_3(data2_3["data"]);
    } else {
      // handle Exaption
      print("Error when getting data2_3");
    }
    var data3 = await SyncAPICalls.getDataServerBulk3(context); //api call 3
    if (data3 != null) {
      databaseHelper.insertData3(data3["data"]);
    } else {
      // handle Exaption
      print("Error when getting data3");
    }
    var data4_1 =
        await SyncAPICalls.getDataServerBulk4_1(context); //api call 4_1
    if (data4_1 != null) {
      databaseHelper.insertData4_1(data4_1["data"]);
    } else {
      // handle Exaption
      print("Error when getting data4_1");
    }
    var data4_2 =
        await SyncAPICalls.getDataServerBulk4_2(context); //api call 4_2
    if (data4_2 != null) {
      var result = databaseHelper.insertData4_2(data4_2["data"]);
      if (result == 1) {
        CommunFun.setServerTime(null, "4");
      } else {
        print("Error when getting bulk4_2");
      }
    } else {
      // handle Exaption
      print("Error when getting data4_2");
    }
    var countrys = await SyncAPICalls.getDataServerBulkAddressData(context);
    if (countrys != null) {
      var result = await databaseHelper.insertAddressData(countrys["data"]);
      print(result);
      if (result == 1) {
        CommunFun.setServerTime(null, "4");
      } else {
        print("Error when getting counry state city");
      }
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }
  }

  static getDataTables3(context) async {
    var data3 = await SyncAPICalls.getDataServerBulk3(context); // call from  3
    if (data3 != null) {
      databaseHelper.insertData3(data3["data"]);
    } else {
      // handle Exaption
      print("Error when getting data3");
    }

    var data4_1 =
        await SyncAPICalls.getDataServerBulk4_1(context); //api call 4_1
    if (data4_1 != null) {
      databaseHelper.insertData3(data4_1["data"]);
    } else {
      // handle Exaption
      print("Error when getting data4_1");
    }
    var data4_2 =
        await SyncAPICalls.getDataServerBulk4_2(context); //api call 4_2
    if (data4_2 != null) {
      databaseHelper.insertData4_2(data4_2["data"]);
    } else {
      // handle Exaption
      print("Error when getting data4_2");
    }
    var countrys = await SyncAPICalls.getDataServerBulkAddressData(context);
    if (countrys != null) {
      var result = await databaseHelper.insertAddressData(countrys["data"]);
      print(result);
      if (result == 1) {
        CommunFun.setServerTime(null, "4");
      } else {
        print("Error when getting counry state city");
      }
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }
  }

  static getDataTables4(context) async {
    //start from tables 4 API calls
    var data4_1 =
        await SyncAPICalls.getDataServerBulk4_1(context); //api call 4_1
    if (data4_1 != null) {
      databaseHelper.insertData4_1(data4_1["data"]);
    } else {
      // handle Exaption
      print("Error when getting data4_1");
    }
    var data4_2 =
        await SyncAPICalls.getDataServerBulk4_2(context); //api call 4_2
    if (data4_2 != null) {
      databaseHelper.insertData4_2(data4_2["data"]);
    } else {
      // handle Exaption
      print("Error when getting data4_2");
    }
    var countrys = await SyncAPICalls.getDataServerBulkAddressData(context);
    if (countrys != null) {
      var result = await databaseHelper.insertAddressData(countrys["data"]);
      print(result);
      if (result == 1) {
        CommunFun.setServerTime(null, "4");
      } else {
        print("Error when getting counry state city");
      }
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }
  }

  static checkDatabaseExit() async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    if (db != null) {
      return true;
    } else {
      return false;
    }
  }

  static getTeminalKey() async {
    var terminalId = await Preferences.getStringValuesSF(Constant.TERMINAL_KEY);
    return terminalId;
  }

  static getbranchId() async {
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    return branchid;
  }

  static getCustomerData() async {
    Customer customer = new Customer();
    var localdata = await Preferences.getStringValuesSF(Constant.CUSTOMER_DATA);
    if (localdata != null) {
      var custData = json.decode(localdata);
      return customer = Customer.fromJson(custData);
    } else {
      return customer;
    }
  }

  static getTableData() async {
    Table_order table = new Table_order();
    var localdata = await Preferences.getStringValuesSF(Constant.TABLE_DATA);
    if (localdata != null) {
      var tableData = json.decode(localdata);
      return table = Table_order.fromJson(tableData);
    } else {
      return table;
    }
  }

  static getOffset() async {
    var offset = await Preferences.getStringValuesSF(Constant.OFFSET);
    return offset;
  }

  static getCurrentDateTime(dateTime) async {
    tz.initializeTimeZones();
    //converttoserver tiem
    var timeZone =
        await Preferences.getStringValuesSF(Constant.SERVER_TIME_ZONE);
    print(timeZone);
    if (timeZone != null) {
      final detroitTime =
          new tz.TZDateTime.from(dateTime, tz.getLocation(timeZone));
      print('Local India Time: ' + dateTime.toString());
      print('Detroit Time: ' + detroitTime.toString());
      // DateTime serverDate = DateTime.parse(detroitTime.toString());
      String formattedDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(detroitTime);
      print(formattedDate);
      return formattedDate;
    } else {
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
      return formattedDate.toString();
    }
  }

  static getLocalID() async {
    var deviceInfo = await CommunFun.deviceInfo();
    var terminalId = await CommunFun.getTeminalKey();
    var localid = Platform.isAndroid
        ? "ANDROID" + deviceInfo["deviceId"] + terminalId
        : "IOS" + deviceInfo["deviceId"] + terminalId;
    return localid.toString();
  }

  static getuserDetails() async {
    User user = new User();
    var users = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
    if (users != null) {
      var user1 = json.decode(users);
      return user = User.fromJson(user1);
    } else {
      return user;
    }
  }

  static processingPopup(context) {
    showDialog(
        // Opning Ammount Popup
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30.0))),
            content: Builder(
              builder: (context) {
                return Container(
                  height: 150,
                  width: 150,
                  child: Center(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CommunFun.loader(context),
                      SizedBox(
                        height: 30,
                      ),
                      Text(Strings.procesing, style: TextStyle(fontSize: 30))
                    ],
                  )),
                );
              },
            ),
          );
        });
  }

  static savewebOrdersintoCart(cartdata) async {
    LocalAPI localAPI = LocalAPI();
    for (var i = 0; i < cartdata.length; i++) {
      var cart = cartdata[i];
      var cartdataitem = {
        "id": cart["cart_id"],
        "localID": cart["localID"],
        "user_id": cart["user_id"],
        "branch_id": cart["branch_id"],
        "sub_total": cart["sub_total"],
        "discount": cart["discount"],
        "discount_type": cart["discount_type"],
        "remark": cart["remark"],
        "tax": cart["tax"],
        "tax_json": cart["tax_json"],
        "voucher_id": cart["voucher_id"],
        "grand_total": cart["grand_total"],
        "total_qty": cart["total_qty"],
        "is_deleted": cart["is_deleted"],
        "created_by": cart["created_by"],
        "created_at": cart["created_at"],
        "customer_terminal": cart["customer_terminal"],
        "voucher_detail": cart["voucher_detail"],
        "sub_total_after_discount": cart["sub_total_after_discount"],
        "source": cart["source"],
        "total_item": cart["total_item"],
        "cart_payment_id": cart["cart_payment_id"],
        "cart_payment_response": cart["cart_payment_response"],
        "cart_payment_status": cart["cart_payment_status"],
      };
      var cartJson = MST_Cart.fromJson(cartdataitem);

      var detaildata = cart["cart_detail"];
      for (var j = 0; j < detaildata.length; j++) {
        var detailitem = detaildata[j];
        var cartDeatils = {
          "id": detailitem["cart_detail_id"],
          "cart_id": detailitem["cart_id"],
          "localID": detailitem["localID"],
          "product_id": detailitem["product_id"],
          "printer_id": detailitem["printer_id"],
          "product_name": detailitem["product_name"],
          "product_price": detailitem["product_price"],
          "product_qty": detailitem["product_qty"],
          "product_net_price": detailitem["product_net_price"],
          "tax_id": detailitem["tax_id"],
          "tax_value": detailitem["tax_value"],
          "discount": detailitem["discount"],
          "discount_type": detailitem["discount_type"],
          "remark": detailitem["remark"],
          "is_deleted": detailitem["is_deleted"],
          "is_send_kichen": detailitem["is_send_kichen"],
          "cart_detail": detailitem["product_detail"],
          "issetMeal": detailitem["issetMeal"],
          "setmeal_product_detail": cart["setmeal_product_detail"],
          "has_composite_inventory": detailitem["has_composite_inventory"],
          "item_unit": detailitem["item_unit"],
          "created_by": detailitem["created_by"],
          "created_at": detailitem["created_at"]
        };
        var cartdetailJson = MSTCartdetails.fromJson(cartDeatils);

        await localAPI.updateWebCartdetails(cartdetailJson);
        var cartSubData = detailitem["cart_sub_detail"];
        for (var p = 0; p < cartSubData.length; p++) {
          var subdetailitem = cartSubData[p];
          var subdata = {
            "id": subdetailitem["cart_sub_detail_id"],
            "cart_details_id": subdetailitem["cart_detail_id"],
            "localID": subdetailitem["localID"],
            "product_id": subdetailitem["product_id"],
            "modifier_id": subdetailitem["modifier_id"],
            "modifier_price": subdetailitem["modifier_price"],
            "ca_id": subdetailitem["ca_id"],
            "attr_price": subdetailitem["attr_price"],
          };
          var subjson = MSTSubCartdetails.fromJson(subdata);

          await localAPI.updateWebCartsubdetails(subjson);
        }
      }

      // Insert cart json
      await localAPI.updateWebCart(cartJson);
    }
  }

  static checkUserPermission(userid) async {
    LocalAPI localAPI = LocalAPI();
    List<PosPermission> permissions = await localAPI.getUserPermissions(userid);
    if (permissions.length > 0) {
      await Preferences.setStringToSF(
          Constant.USER_PERMISSION, permissions[0].posPermissionName);
    }
  }

  static getPemission() async {
    var permission =
        await Preferences.getStringValuesSF(Constant.USER_PERMISSION);
    if (permission != null) {
      return permission;
    } else {
      return "";
    }
  }

  static autosyncAllTables(context) async {
    await getsetWebOrders(context);
    await SyncAPICalls.syncOrderstoDatabase(context);
    await SyncAPICalls.sendInvenotryTable(context);
    await SyncAPICalls.sendCancledOrderTable(context);
    await Preferences.removeSinglePref(Constant.LastSync_Table);
    await Preferences.removeSinglePref(Constant.OFFSET);
    await CommunFun.syncAfterSuccess(context, false);
  }

  static getsetWebOrders(context) async {
    var res = await SyncAPICalls.getWebOrders(context);
    var sertvertime = res["data"]["serverdatetime"];
    await Preferences.setStringToSF(
        Constant.ORDER_SERVER_DATE_TIME, sertvertime);
    var cartdata = res["data"]["cart"];
    await CommunFun.savewebOrdersintoCart(cartdata);
  }

  static checkisAutoSync(context) async {
    var isSync = await Preferences.getStringValuesSF(Constant.IS_AUTO_SYNC);
    if (isSync != null) {
      print(isSync);
      if (isSync == "true") {
        startAutosync(context);
      }
    }
  }

  static startAutosync(context) async {
    int timertime = 1;
    var isSynctimer = await Preferences.getStringValuesSF(Constant.SYNC_TIMER);
    if (isSynctimer != null && isSynctimer != "") {
      timertime = int.parse(isSynctimer);
    }
    print("++++++++++++++++++++++++++++++++++++");
    print(timertime);
    var _inactivityTimeout = Duration(minutes: timertime);
    timer =
        Timer(_inactivityTimeout, () => CommunFun.autosyncAllTables(context));
  }

  static stopAutoSync() {
    timer?.cancel();
  }

  static countTotalQty(
      List<MSTCartdetails> cartItems, productItem, productQty) {
    double qty = 0;
    if (cartItems.length > 0) {
      for (var i = 0; i < cartItems.length; i++) {
        var item = cartItems[i];
        if (item.productId == productItem.productId) {
          item.productQty = productQty;
        }
        qty += item.productQty;
      }
    } else {
      qty += productQty;
    }
    return qty;
  }

  static countSubtotal(List<MSTCartdetails> cartItems, price) {
    double subT = 0;
    if (cartItems.length > 0) {
      double selectedITemTotal = 0;
      for (var i = 0; i < cartItems.length; i++) {
        var item = cartItems[i];
        selectedITemTotal += item.productPrice;
      }
      subT = selectedITemTotal + price;
    } else {
      subT += price;
    }
    return subT;
  }

  static countGrandtotal(subt, tax, dis) {
    double grandTotal = 0;
    grandTotal = ((subt - dis) + tax);
    return grandTotal;
  }

  static getTaxs() async {
    var branchid = await CommunFun.getbranchId();
    List<BranchTax> taxlists = await localAPI.getTaxList(branchid);
    return taxlists;
  }

  static countTax(subT) async {
    var taxlist = await CommunFun.getTaxs();
    var totalTax = [];
    double taxvalue = taxvalues;
    if (taxlist.length > 0) {
      for (var i = 0; i < taxlist.length; i++) {
        var taxlistitem = taxlist[i];
        List<Tax> tax = await localAPI.getTaxName(taxlistitem.taxId);
        var taxval = taxlistitem.rate != null
            ? subT * double.parse(taxlistitem.rate) / 100
            : 0.0;
        taxval = double.parse(taxval.toStringAsFixed(2));
        taxvalue += taxval;
        taxvalues = taxvalue;
        var taxmap = {
          "id": taxlistitem.id,
          "tax_id": taxlistitem.taxId,
          "branch_id": taxlistitem.branchId,
          "rate": taxlistitem.rate,
          "status": taxlistitem.status,
          "updated_at": taxlistitem.updatedAt,
          "updated_by": taxlistitem.updatedBy,
          "taxAmount": taxval.toStringAsFixed(2),
          "taxCode": tax.length > 0 ? tax[0].code : "" //tax.code
        };
        totalTax.add(taxmap);
      }
    }
    return totalTax;
  }

  static countDiscount(MST_Cart currentCart) {
    return currentCart.discount != null
        ? double.parse(currentCart.discount.toStringAsFixed(2))
        : 0.00;
  }

  static getPrinter(productItem) async {
    Printer printer = new Printer();
    List<Printer> printerlist =
        await localAPI.getPrinter(productItem.productId.toString());
    if (printerlist.length > 0) {
      printer = printerlist[0];
    }
    return printer;
  }

  static addItemToCart(productItem, List<MSTCartdetails> cartItems,
      MST_Cart allcartData, callback) async {
    MST_Cart cart = new MST_Cart();
    SaveOrder orderData = new SaveOrder();
    var branchid = await CommunFun.getbranchId();
    Table_order table = await CommunFun.getTableData();
    User loginUser = await CommunFun.getuserDetails();
    Customer customerData = await CommunFun.getCustomerData();
    Printer printer = await CommunFun.getPrinter(productItem);
    bool isEditing = false;
    MSTCartdetails sameitem;
    var contain = cartItems
        .where((element) => element.productId == productItem.productId);
    if (contain.isNotEmpty) {
      isEditing = true;
      var jsonString = jsonEncode(contain.map((e) => e.toJson()).toList());
      List<MSTCartdetails> myModels = (json.decode(jsonString) as List)
          .map((i) => MSTCartdetails.fromJson(i))
          .toList();
      sameitem = myModels[0];
    }
    var qty = await CommunFun.countTotalQty(cartItems, productItem, 1.0);
    var disc = await CommunFun.countDiscount(allcartData);
    var subtotal = await CommunFun.countSubtotal(cartItems, productItem.price);
    var totalTax = await CommunFun.countTax(subtotal);
    var grandTotal = await CommunFun.countGrandtotal(subtotal, taxvalues, disc);
    cart.user_id = customerData.customerId;
    cart.branch_id = int.parse(branchid);
    cart.sub_total = double.parse(subtotal.toStringAsFixed(2));
    cart.discount = disc;
    cart.table_id = table.table_id;
    cart.discount_type = allcartData.discount_type;
    cart.total_qty = qty;
    cart.tax = double.parse(taxvalues.toStringAsFixed(2));
    cart.source = 2;
    cart.tax_json = json.encode(totalTax);
    cart.grand_total = double.parse(grandTotal.toStringAsFixed(2));
    cart.customer_terminal = customerData != null ? customerData.terminalId : 0;
    if (!isEditing) {
      cart.created_at = await CommunFun.getCurrentDateTime(DateTime.now());
    }
    cart.created_by = loginUser.id;
    cart.localID = await CommunFun.getLocalID();
    if (!isEditing) {
      orderData.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
    }
    orderData.numberofPax = table != null ? table.number_of_pax : 0;
    orderData.isTableOrder = table != null ? 1 : 0;
    var cartid = await localAPI.insertItemTocart(
        allcartData.id, cart, productItem, orderData, table.table_id);
    ProductDetails cartItemproduct = new ProductDetails();
    cartItemproduct = productItem;

    cartItemproduct
        .toJson()
        .removeWhere((String key, dynamic value) => value == null);
    var data = cartItemproduct;
    MSTCartdetails cartdetails = new MSTCartdetails();
    if (isEditing) {
      cartdetails.id = sameitem.id;
    }
    cartdetails.cartId = cartid;
    cartdetails.productId = productItem.productId;
    cartdetails.productName = productItem.name;
    cartdetails.productSecondName = productItem.name_2;
    cartdetails.productPrice = isEditing
        ? double.parse(productItem.price.toStringAsFixed(2)) +
            sameitem.productPrice
        : double.parse(productItem.price.toStringAsFixed(2));
    cartdetails.productQty = isEditing ? sameitem.productQty + 1.0 : 1.0;
    cartdetails.productNetPrice = isEditing
        ? sameitem.productNetPrice +
            double.parse(productItem.price.toStringAsFixed(2))
        : double.parse(productItem.price.toStringAsFixed(2));
    cartdetails.createdBy = loginUser.id;
    cartdetails.cart_detail = jsonEncode(data);
    cartdetails.discount = isEditing ? sameitem.discount : 0;
    cartdetails.remark = isEditing ? sameitem.remark : "";
    cartdetails.issetMeal = 0;
    cartdetails.taxValue = taxvalues;
    cartdetails.printer_id = printer != null ? printer.printerId : 0;
    cartdetails.createdAt = await CommunFun.getLocalID();
    var detailID = await localAPI.addintoCartDetails(cartdetails);
    print(detailID);
    callback();
  }

  // sendTokitched(itemList) async {
  //   String ids = "";
  //   var list = [];
  //   for (var i = 0; i < itemList.length; i++) {
  //     if (itemList[i].isSendKichen == null || itemList[i].isSendKichen == 0) {
  //       if (ids == "") {
  //         ids = itemList[i].id.toString();
  //       } else {
  //         ids = ids + "," + itemList[i].id.toString();
  //       }
  //       list.add(itemList[i]);
  //     }
  //     if (i == itemList.length - 1) {
  //       if (list.length > 0) {
  //         dynamic send = await localAPI.sendToKitched(ids);
  //         openPrinterPop(list);
  //       }
  //     }
  //   }
  // }

}
