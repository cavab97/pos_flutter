import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommunFun {
  static loginText() {
    return Text("YOU CAN ENTER YOUR USERNAME & PASSWORD HERE",
        style: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
  }

  static forgotPasswordText(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.centerRight,
      child: Text(
        "Forgot password?",
        style: TextStyle(color: Colors.blue, fontSize: 22),
      ),
    );
  }

  static roundedButton(text, _onPress) {
    return RaisedButton(
      padding: EdgeInsets.only(top: 20, bottom: 20),
      onPressed: _onPress,
      child: Text(
        text,
        style: TextStyle(
            color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
      ),
      color: Colors.deepOrange,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
    );
  }
}
