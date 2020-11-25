import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/screens/OpningAmountPop.dart';
import 'package:mcncashier/screens/PermissionPop.dart';

class CommonUtils {
  /*load image from base64*/
  static Image imageFromBase64String(String base64) {
    if (base64 != null) {
      if (base64.isNotEmpty) {
        var strImage = base64;
        if (base64.contains("base64,")) {
          strImage = base64.split("base64,")[1];
        }
        return Image.memory(base64Decode(strImage),
            fit: BoxFit.cover, gaplessPlayback: true);
      }
    }
  }

  Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  String base64String(Uint8List data) {
    return base64Encode(data);
  }

  static showAlertDialog(
      BuildContext context,
      Function onNegativeClick,
      Function onPositiveClick,
      String title,
      String message,
      String positiveButton,
      String negativeButton,
      bool isShowNegative) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          titlePadding: EdgeInsets.all(20),
          title: Center(child: Text(title)),
          content: Container(
              width: MediaQuery.of(context).size.width / 3.4,
              child: Text(message)),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                onPositiveClick();
              },
              child: Text(positiveButton, style: Styles.orangeSmall()),
            ),
            isShowNegative
                ? FlatButton(
                    onPressed: () {
                      onNegativeClick();
                    },
                    child: Text(negativeButton, style: Styles.orangeSmall()),
                  )
                : SizedBox()
          ],
        );
      },
    );
  }

  static openPermissionPop(context, permissionFor, callback) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return OpenPermissionPop(
              perFor: permissionFor,
              onEnter: () {
                callback();
              });
        });
  }

  static openOpningAmmountPop(context, isopning, callback) {
    showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return OpeningAmmountPage(
              ammountext: isopning,
              onEnter: (ammountext) {
                callback(ammountext);
              });
        });
  }
}
