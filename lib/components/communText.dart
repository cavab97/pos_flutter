import 'dart:convert';
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

class CommunFun {
  static loginText() {
    return Text(Strings.login_text,
        style: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
  }

  static isLogged() async {
    var loginUser = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
    if (loginUser != null) {
      return true;
    } else {
      return false;
    }
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

  static roundedButton(text, _onPress) {
    //round button like Login button
    return RaisedButton(
      padding: EdgeInsets.only(top: 20, bottom: 20),
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
      duration: Toast.LENGTH_LONG,
      gravity: Toast.BOTTOM,
    );
  }

  static syncDailog(context) {
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
                  Text(Strings.syncText, style: TextStyle(fontSize: 30))
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
        return syncDailog(context);
      },
    );
  }

  static syncAfterSuccess(context) async {
    // sync in 4 part api call
    opneSyncPop(context);
    var lastSync = await Preferences.getStringValuesSF(Constant.LastSync_Table);
    if (lastSync == null) {
      CommunFun.getDataTables1(context);
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
          Constant.SERVER_DATE_TIME, data["data"]["serverdatetime"]);
      await Preferences.setStringToSF(
          Constant.SERVER_TIME_ZONE, data["data"]["timezone"]);
    }
    await Preferences.setStringToSF(Constant.LastSync_Table, lastSync);
  }

  static getDataTables1(context) async {
    // start with 1 tables
    var data1 = await SyncAPICalls.getDataServerBulk1(context); //api call 1
    if (data1 != null) {
      await databaseHelper.insertData1(data1["data"]);
      await CommunFun.setServerTime(null, "1");
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }

    var data2_1 =
        await SyncAPICalls.getDataServerBulk2_1(context); //api call 2_1
    if (data2_1 != null) {
      await databaseHelper.insertData2_1(data2_1["data"]);
      await CommunFun.setServerTime(null, "1");
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }

    var data2_2 =
        await SyncAPICalls.getDataServerBulk2_2(context); //api call 2_2
    if (data2_2 != null) {
      await databaseHelper.insertData2_2(data2_2["data"]);
      await CommunFun.setServerTime(null, "1");
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }
    var data2_3 =
        await SyncAPICalls.getDataServerBulk2_3(context); //api call 2_3
    if (data2_3 != null) {
      await databaseHelper.insertData2_3(data2_3["data"]);
      await CommunFun.setServerTime(null, "2");
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }

    var data3 = await SyncAPICalls.getDataServerBulk3(context); // call 3
    if (data3 != null) {
      await databaseHelper.insertData3(data3["data"]);
      await CommunFun.setServerTime(null, "3");
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }
    var data4_1 = await SyncAPICalls.getDataServerBulk4_1(context);
    if (data4_1 != null) {
      await databaseHelper.insertData4_1(data4_1["data"]);
      await CommunFun.setServerTime(null, "3");
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }
    var data4_2 = await SyncAPICalls.getDataServerBulk4_2(context);
    if (data4_2 != null) {
      var result = await databaseHelper.insertData4_2(data4_2["data"]);
      print(result);
      if (result == 1) {
        await CommunFun.setServerTime(null, "4");
        Navigator.of(context).pop();
        Navigator.pushNamed(context, Constant.PINScreen);
      } else {
        print("Error when getting data4_3");
      }
    } else {
      CommunFun.showToast(context, "something want wrong!");
    }
    var aceets = await SyncAPICalls.getAssets(context);
    if (aceets != null) {
      databaseHelper.accetsData(aceets["data"]);
      await CommunFun.setServerTime(aceets, "4");
    } else {
      // handle Exaption
      print("Error when getting product image data");
    }
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
      databaseHelper.insertData4_2(data4_2["data"]);
    } else {
      // handle Exaption
      print("Error when getting data4_2");
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
  }

  static syncSingleTable(context) async {
    // For Single table data
    var data = {'serverdatetime': "2020-09-01 12:30:25", 'table': "users"};
    var isReturn;
    await repo.syncTable(data).then((value) async {
      if (value["status"] == Constant.STATUS200) {
        CommunFun.showToast(context, value["message"]);
        isReturn = true;
      } else {
        CommunFun.showToast(context, value["message"]);
        isReturn = false;
      }
    }).catchError((e) {
      CommunFun.showToast(context, e.message);
      isReturn = false;
    }).whenComplete(() {});
    return isReturn;
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

  static getCurrentDateTime(dateTime) async {
    tz.initializeTimeZones();
    //converttoserver tiem
    var timeZone =
        await Preferences.getStringValuesSF(Constant.SERVER_TIME_ZONE);
    if (timeZone != null) {
      final detroitTime =
          new tz.TZDateTime.from(dateTime, tz.getLocation(timeZone));
      print('Local India Time: ' + dateTime.toString());
      print('Detroit Time: ' + detroitTime.toString());
      DateTime serverDate = DateTime.parse(detroitTime.toString());
      String formattedDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(serverDate);
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
}
