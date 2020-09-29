import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/CheckInout.dart';
import 'package:mcncashier/models/Role.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/services/LocalAPIs.dart';

class PINPage extends StatefulWidget {
  // PIN Enter PAGE
  PINPage({Key key}) : super(key: key);

  @override
  _PINPageState createState() => _PINPageState();
}

class _PINPageState extends State<PINPage> {
  var pinNumber = "";
  GlobalKey<ScaffoldState> scaffoldKey;
  bool isCheckIn = false;
  bool isLoading = false;
  LocalAPI localAPI = LocalAPI();
  @override
  void initState() {
    super.initState();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    checkAlreadyclockin();
  }

  checkAlreadyclockin() async {
    var isClockin = await Preferences.getStringValuesSF(Constant.IS_CHECKIN);
    if (isClockin != null) {
      isCheckIn = isClockin == "true" ? true : false;
    }
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

  clockInwithPIN() async {
    if (!isCheckIn) {
      if (pinNumber.length >= 6) {
        List<User> checkUserExit = await localAPI.checkUserExit(pinNumber);
        if (checkUserExit.length != 0) {
          setState(() {
            isLoading = true;
          });
          User user = checkUserExit[0];
          CheckinOut checkIn = new CheckinOut();
          var terminalId = await CommunFun.getTeminalKey();
          var branchid = await CommunFun.getbranchId();
          var date = DateTime.now();
          checkIn.localID = await CommunFun.getLocalID();
          checkIn.terminalId = int.parse(terminalId);
          checkIn.userId = user.id;
          checkIn.branchId = int.parse(branchid);
          checkIn.status = "IN";
          checkIn.timeInOut = date.toString();
          checkIn.createdAt = date.toString();
          checkIn.sync = 0;
          var result = await localAPI.userCheckInOut(checkIn);
          List<Role> rolData = await localAPI.getRoldata(user.role);

          if (rolData.length > 0) {
            Role rolda = rolData[0];
            await Preferences.setStringToSF(
                Constant.USER_ROLE, json.encode(rolda));
          }
          await Preferences.setStringToSF(
              Constant.LOIGN_USER, json.encode(user));
          await Preferences.setStringToSF(Constant.IS_CHECKIN, "true");
          await Preferences.setStringToSF(Constant.SHIFT_ID, result.toString());

          Navigator.pushNamed(context, Constant.DashboardScreen);
          setState(() {
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          CommunFun.showToast(context, Strings.invalid_pin_msg);
        }
      } else {
        if (pinNumber.length >= 6) {
          CommunFun.showToast(context, Strings.invalid_pin_msg);
        } else {
          CommunFun.showToast(context, Strings.pin_validation_message);
        }
      }
    } else {
      CommunFun.showToast(context, Strings.already_clockin_msg);
    }
  }

  clockOutwithPIN() async {
    var loginUser = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
    var user = json.decode(loginUser);
    var pin = user["user_pin"];
    if (isCheckIn) {
      if (pinNumber.length >= 6 && pin.toString() == pinNumber) {
        setState(() {
          isLoading = true;
        });
        CheckinOut checkIn = new CheckinOut();
        var shiftid = await Preferences.getStringValuesSF(Constant.SHIFT_ID);
        var terminalId = await CommunFun.getTeminalKey();
        var branchid = await CommunFun.getbranchId();
        var date = DateTime.now();
        checkIn.id = int.parse(shiftid);
        checkIn.localID = await CommunFun.getLocalID();
        checkIn.terminalId = int.parse(terminalId);
        checkIn.userId = user["id"];
        checkIn.branchId = int.parse(branchid);
        checkIn.status = "OUT";
        checkIn.timeInOut = date.toString();
        checkIn.sync = 0;
        var result = await localAPI.userCheckInOut(checkIn);
        await Preferences.removeSinglePref(Constant.IS_CHECKIN);
        await Preferences.removeSinglePref(Constant.SHIFT_ID);
        await Preferences.removeSinglePref(Constant.LOIGN_USER);
        Navigator.pushNamed(context, Constant.PINScreen);
        setState(() {
          isLoading = false;
        });
      } else {
        if (pinNumber.length >= 6) {
          CommunFun.showToast(context, Strings.invalid_pin_msg);
        } else {
          CommunFun.showToast(context, Strings.pin_validation_message);
        }
      }
    } else {
      CommunFun.showToast(context, Strings.already_clockout_msg);
    }
  }

  Future<bool> _willPopCallback() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: SafeArea(
        child: Scaffold(
          key: scaffoldKey,
          body: Center(
            child: Container(
              //page background image
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(Strings.assetsBG), fit: BoxFit.cover),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.white),
                    width: MediaQuery.of(context).size.width / 1.2,
                    height: MediaQuery.of(context).size.height / 1.2,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        imageview(context), // Part 1 image with logo
                        getNumbers(context), // Part 2  Muber keypade
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      onWillPop: _willPopCallback,
    );
  }

  Widget imageview(context) {
    return Container(
        width: MediaQuery.of(context).size.width / 2.9,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30), topLeft: Radius.circular(30)),
          // image: DecorationImage(
          //     image: AssetImage("assets/bg.jpg"), fit: BoxFit.cover)
        ),
        child: Center(
            child: Padding(
                padding: EdgeInsets.all(10),
                child: SizedBox(
                  // login logo
                  height: 110.0,
                  child: Image.asset(
                    Strings.asset_headerLogo,
                    fit: BoxFit.contain,
                  ),
                ))));
  }

  Widget _button(String number, Function() f) {
    // Creating a method of return type Widget with number and function f as a parameter
    return Padding(
      padding: EdgeInsets.all(5),
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(color: Colors.grey)),
        height: MediaQuery.of(context).size.height / 8.7,
        minWidth: MediaQuery.of(context).size.width / 9.9,
        child: Text(number,
            textAlign: TextAlign.center, style: Styles.blackBoldLarge()),
        textColor: Colors.black,
        color: Colors.grey[100],
        onPressed: f,
      ),
    );
  }

  Widget getNumbers(context) {
    // Numbers buttons
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(right: 90),
        child: Column(
          children: <Widget>[
            // isCheckIn
            //     ? Row(
            //         mainAxisAlignment: MainAxisAlignment.end,
            //         children: <Widget>[
            //           IconButton(
            //               padding: EdgeInsets.only(
            //                 left: 100,
            //               ),
            //               onPressed: () {
            //                 Navigator.of(context).pop();
            //               },
            //               icon: Icon(
            //                 Icons.close,
            //                 color: Colors.black,
            //                 size: 50,
            //               )),
            //         ],
            //       )
            //     : SizedBox(height: 20),
            SizedBox(height: 20),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    Strings.pin_Number,
                    style: Styles.blackBoldLarge(),
                  )
                ]),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  pinNumber.length >= 1 ? Icons.lens : Icons.panorama_fish_eye,
                  color: Colors.deepOrange,
                  size: 40,
                ),
                Icon(
                  pinNumber.length >= 2 ? Icons.lens : Icons.panorama_fish_eye,
                  color: Colors.deepOrange,
                  size: 40,
                ),
                Icon(
                  pinNumber.length >= 3 ? Icons.lens : Icons.panorama_fish_eye,
                  color: Colors.deepOrange,
                  size: 40,
                ),
                Icon(
                  pinNumber.length >= 4 ? Icons.lens : Icons.panorama_fish_eye,
                  color: Colors.deepOrange,
                  size: 40,
                ),
                Icon(
                  pinNumber.length >= 5 ? Icons.lens : Icons.panorama_fish_eye,
                  color: Colors.deepOrange,
                  size: 40,
                ),
                Icon(
                  pinNumber.length >= 6 ? Icons.lens : Icons.panorama_fish_eye,
                  color: Colors.deepOrange,
                  size: 40,
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
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
              height: 10,
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
              height: 10,
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
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _button(Strings.btnclockin, () {
                  clockInwithPIN();
                }),
                _button("0", () {
                  addINPin("0");
                }),
                _button(Strings.btnclockout, () {
                  clockOutwithPIN();
                }),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            isLoading
                ? CommunFun.loader(context)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                        FlatButton(
                            onPressed: () {
                              clearPin();
                            },
                            child: Text(Strings.clear,
                                style: Styles.orangeLarge()))
                      ])
          ],
        ),
      ),
    );
  }
}
