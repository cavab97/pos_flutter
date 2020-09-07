import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/services/tableSyncAPI.dart' as repo;
import 'package:toast/toast.dart';

class CommunFun {
  static loginText() {
    return Text(Strings.login_text,
        style: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
  }

  static divider() {
    // Simple divider
    return Padding(
      padding: EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 15),
      child: Divider(
        height: 1,
        thickness: 1.0,
        color: Colors.grey[300],
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
      child: Text(
        text,
        style: TextStyle(
            color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
      ),
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

  static deviceInfo() {
    // Device Info
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    var deviceData;
    try {
      if (Platform.isAndroid) {
        deviceData = deviceInfo.androidInfo;
      } else if (Platform.isIOS) {
        deviceData = deviceInfo.iosInfo;
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
        height: 70.0,
        width: 70.0,
        child: CircularProgressIndicator(
          backgroundColor: Colors.white,
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
        ),
      ),
    );
  }

  static showToast(context, message) {
    Toast.show(message, context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
  }

  static syncAfterSuccess(context) async {
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

  static syncSingleTable(context) async {
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
}
