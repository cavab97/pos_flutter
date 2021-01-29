import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/PosPermission.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/services/allTablesSync.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:mcncashier/components/colors.dart';
import 'package:mcncashier/widget/CloseButtonWidget.dart';

class OpenPermissionPop extends StatefulWidget {
  // Opning ammount popup
  OpenPermissionPop({Key key, this.perFor, this.onEnter, this.onClose})
      : super(key: key);
  Function onEnter;
  Function onClose;
  final perFor;
  @override
  OpenPermissionPopState createState() => OpenPermissionPopState();
}

class OpenPermissionPopState extends State<OpenPermissionPop> {
  var pinNumber = "";
  LocalAPI localAPI = LocalAPI();
  @override
  void initState() {
    super.initState();
  }

  addINPin(val) {
    if (pinNumber.length < 6) {
      var currentpinNumber = pinNumber;
      currentpinNumber += val;
      setState(() {
        pinNumber = currentpinNumber;
      });
    }
  }

  clearPin() {
    setState(() {
      pinNumber = "";
    });
  }

  checkPermission() async {
    if (pinNumber.length >= 6) {
      List<User> checkUserExit = await localAPI.checkUserExit(pinNumber);
      if (checkUserExit.length != 0) {
        List<PosPermission> permissions =
            await localAPI.getUserPermissions(checkUserExit[0].id);
        if (permissions.length > 0) {
          if (permissions[0].posPermissionName != null &&
              permissions[0].posPermissionName.contains(widget.perFor)) {
            Navigator.of(context).pop();
            await SyncAPICalls.logActivity(
                "permission",
                "manager permission done",
                "permission",
                1,
                checkUserExit[0].id);
            widget.onEnter();
          } else {
            await CommunFun.showToast(context, Strings.permissionMsg);
            await SyncAPICalls.logActivity("permission", Strings.permissionMsg,
                "permission", 1, checkUserExit[0].id);
          }
        }
      } else {
        await CommunFun.showToast(context, Strings.invalidPinMsg);
        await SyncAPICalls.logActivity(
            "permission",
            "manager permission pin invalid",
            "permission",
            1,
            checkUserExit[0].id);
      }
    } else {
      await CommunFun.showToast(context, Strings.invalidPinMsg);
      await SyncAPICalls.logActivity(
          "permission", "manager permission pin invalid", "permission", 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _willPopCallback() async {
      widget.onClose();
    }

    return WillPopScope(
        child: AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: EdgeInsets.only(left: 30, right: 10, top: 10, bottom: 10),
            height: SizeConfig.safeBlockVertical * 9,
            color: StaticColor.colorBlack,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  Strings.invalidPinMsg,
                  style: Styles.whiteBoldsmall(),
                ),
                CloseButtonWidget(inputContext: context),
              ],
            ),
          ),
          content: mainContent(), // Popup body contents
        ),
        onWillPop: _willPopCallback);
  }

  Widget closeButton(context) {
    return Positioned(
      top: 0,
      right: 0,
      child: GestureDetector(
        onTap: () async {
          widget.onClose();
          Navigator.of(context).pop();
          await SyncAPICalls.logActivity(
              "permission", "Ignored permission pin enter", "permission", 1);
        },
        child: Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
              color: StaticColor.colorRed,
              borderRadius: BorderRadius.circular(30.0)),
          child: IconButton(
            onPressed: () async {
              widget.onClose();
              Navigator.of(context).pop();
              await SyncAPICalls.logActivity("permission",
                  "Ignored permission pin enter", "permission", 1);
            },
            icon: Icon(
              Icons.clear,
              color: StaticColor.colorWhite,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget mainContent() {
    return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [getNumbers(context)],
        ));
  }

  Widget getNumbers(context) {
    // Numbers buttons
    return Container(
      //padding: EdgeInsets.symmetric(horizontal: 80),
      height: MediaQuery.of(context).size.height / 1.6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: SizeConfig.safeBlockVertical * 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  pinNumber.length >= 1 ? Icons.lens : Icons.panorama_fish_eye,
                  color: StaticColor.deepOrange,
                  size: SizeConfig.safeBlockVertical * 5,
                ),
                Icon(
                  pinNumber.length >= 2 ? Icons.lens : Icons.panorama_fish_eye,
                  color: StaticColor.deepOrange,
                  size: SizeConfig.safeBlockVertical * 5,
                ),
                Icon(
                  pinNumber.length >= 3 ? Icons.lens : Icons.panorama_fish_eye,
                  color: StaticColor.deepOrange,
                  size: SizeConfig.safeBlockVertical * 5,
                ),
                Icon(
                  pinNumber.length >= 4 ? Icons.lens : Icons.panorama_fish_eye,
                  color: StaticColor.deepOrange,
                  size: SizeConfig.safeBlockVertical * 5,
                ),
                Icon(
                  pinNumber.length >= 5 ? Icons.lens : Icons.panorama_fish_eye,
                  color: StaticColor.deepOrange,
                  size: SizeConfig.safeBlockVertical * 5,
                ),
                Icon(
                  pinNumber.length >= 6 ? Icons.lens : Icons.panorama_fish_eye,
                  color: StaticColor.deepOrange,
                  size: SizeConfig.safeBlockVertical * 5,
                ),
              ],
            ),
            SizedBox(
              height: SizeConfig.safeBlockVertical * 4,
            ),
            Container(
              width: MediaQuery.of(context).size.width / 3,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _button("1", () {
                        addINPin("1");
                      }), // using custom widget _button
                      _button("2", () {
                        addINPin("2");
                      }),
                      _button("3", () {
                        addINPin("3");
                      }),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.safeBlockVertical * 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _button("4", () {
                        addINPin("4");
                      }), // using custom widget _button
                      _button("5", () {
                        addINPin("5");
                      }),
                      _button("6", () {
                        addINPin("6");
                      }),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.safeBlockVertical * 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _button("7", () {
                        addINPin("7");
                      }), // using custom widget _button
                      _button("8", () {
                        addINPin("8");
                      }),
                      _button("9", () {
                        addINPin("9");
                      }),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.safeBlockVertical * 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      // _buttonCN(Strings.btnclockin, () {
                      //   clockInwithPIN();
                      // }),
                      _backbutton(() {
                        clearPin();
                      }),
                      _button("0", () {
                        addINPin("0");
                      }),
                      _enterbutton(() {
                        checkPermission();
                      }),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _button(String number, Function() f) {
    // Creating a method of return type Widget with number and function f as a parameter
    return MaterialButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(
            color: StaticColor.colorGrey,
          )),
      height: MediaQuery.of(context).size.height / 9,
      // minWidth: MediaQuery.of(context).size.width / 9.9,
      child: Text(number,
          textAlign: TextAlign.center, style: Styles.communBlack()),
      textColor: StaticColor.colorBlack,
      color: StaticColor.lightGrey100,
      onPressed: f,
    );
  }

  Widget _enterbutton(Function() f) {
    // Creating a method of return type Widget with number and function f as a parameter
    return MaterialButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(color: StaticColor.colorGrey)),
      height: MediaQuery.of(context).size.height / 9,
      // minWidth: MediaQuery.of(context).size.width / 9.9,
      child: Icon(Icons.subdirectory_arrow_left),
      textColor: StaticColor.colorBlack,
      color: StaticColor.lightGrey100,
      onPressed: f,
    );
  }

  Widget _backbutton(Function() f) {
    // Creating a method of return type Widget with number and function f as a parameter
    return MaterialButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(
            color: StaticColor.colorGrey,
          )),
      height: MediaQuery.of(context).size.height / 9,
      // minWidth: MediaQuery.of(context).size.width / 9.9,
      child: Icon(Icons.clear),
      textColor: StaticColor.colorBlack,
      color: StaticColor.lightGrey100,
      onPressed: f,
    );
  }
}
