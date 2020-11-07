import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/CheckInout.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/theme/Sized_Config.dart';

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
      setState(() {
        isCheckIn = isClockin == "true" ? true : false;
      });
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
          // List<Role> rolData = await localAPI.getRoldata(user.role);
          // if (rolData.length > 0) {
          //   Role rolda = rolData[0];
          //   await Preferences.setStringToSF(
          //       Constant.USER_ROLE, json.encode(rolda));
          // }
          await Preferences.setStringToSF(
              Constant.LOIGN_USER, json.encode(user));
          await CommunFun.checkUserPermission(user.id);
          await Preferences.setStringToSF(Constant.IS_CHECKIN, "true");
          await Preferences.setStringToSF(Constant.SHIFT_ID, result.toString());
          // await Navigator.pushNamed(context, Constant.SelectTableScreen);
          await Navigator.pushNamedAndRemoveUntil(context,
              Constant.SelectTableScreen, (Route<dynamic> route) => false,
              arguments: {"isAssign": false});
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
        clearAfterCheckout();
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

  clearAfterCheckout() async {
    await Preferences.removeSinglePref(Constant.IS_CHECKIN);
    await Preferences.removeSinglePref(Constant.SHIFT_ID);
    await Preferences.removeSinglePref(Constant.LOIGN_USER);
    await Preferences.removeSinglePref(Constant.USER_PERMISSION);
    await Navigator.pushNamed(context, Constant.PINScreen);
    setState(() {
      isLoading = false;
    });
  }

  Future<bool> _willPopCallback() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      child: SafeArea(
        child: Scaffold(
          key: scaffoldKey,
          body: Container(
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
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.top,
                    border: TableBorder(
                        horizontalInside: BorderSide(
                            width: 1,
                            color: Colors.grey,
                            style: BorderStyle.solid)),
                    columnWidths: {
                      0: FractionColumnWidth(.2),
                      1: FractionColumnWidth(.4),
                    },
                    children: [
                      TableRow(children: [
                        imageview(context),
                        getNumbers(context)
                      ]) // Part 1 image with logo
                      , // Part 2  Muber keypade
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onWillPop: _willPopCallback,
    );
  }

  Widget imageview(context) {
    return Container(
      // width: MediaQuery.of(context).size.width / 2.9,
      height: MediaQuery.of(context).size.height / 1.2,
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
            height: SizeConfig.safeBlockVertical * 10,
            child: Image.asset(
              Strings.asset_headerLogo,
              fit: BoxFit.contain,
              gaplessPlayback: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget getNumbers(context) {
    // Numbers buttons
    return Container(
      //padding: EdgeInsets.symmetric(horizontal: 80),
      height: MediaQuery.of(context).size.height / 1.2,
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
            /* isCheckIn
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                            padding: EdgeInsets.only(right: 40, top: 10),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.black,
                              size: SizeConfig.safeBlockVertical * 7,
                            )),
                      ],
                    )
                  : SizedBox(),*/

            Container(
                child: new Stack(children: [
              Container(
                margin: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 3),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    Strings.pin_Number,
                    style: Styles.communBlack(),
                  ),
                ),
              ),
              isCheckIn
                  ? Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                          padding: EdgeInsets.only(
                              right: SizeConfig.safeBlockVertical * 5),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.black,
                            size: SizeConfig.safeBlockVertical * 7,
                          )),
                    )
                  : SizedBox(),
            ])),
            /* mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      Strings.pin_Number,
                      style: Styles.blackBoldLarge(),
                    )
                  ]),*/
            SizedBox(
              height: SizeConfig.safeBlockVertical * 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  pinNumber.length >= 1 ? Icons.lens : Icons.panorama_fish_eye,
                  color: Colors.deepOrange,
                  size: SizeConfig.safeBlockVertical * 5,
                ),
                Icon(
                  pinNumber.length >= 2 ? Icons.lens : Icons.panorama_fish_eye,
                  color: Colors.deepOrange,
                  size: SizeConfig.safeBlockVertical * 5,
                ),
                Icon(
                  pinNumber.length >= 3 ? Icons.lens : Icons.panorama_fish_eye,
                  color: Colors.deepOrange,
                  size: SizeConfig.safeBlockVertical * 5,
                ),
                Icon(
                  pinNumber.length >= 4 ? Icons.lens : Icons.panorama_fish_eye,
                  color: Colors.deepOrange,
                  size: SizeConfig.safeBlockVertical * 5,
                ),
                Icon(
                  pinNumber.length >= 5 ? Icons.lens : Icons.panorama_fish_eye,
                  color: Colors.deepOrange,
                  size: SizeConfig.safeBlockVertical * 5,
                ),
                Icon(
                  pinNumber.length >= 6 ? Icons.lens : Icons.panorama_fish_eye,
                  color: Colors.deepOrange,
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
                      _buttonCN(Strings.btnclockin, () {
                        clockInwithPIN();
                      }),
                      _button("0", () {
                        addINPin("0");
                      }),
                      _buttonCN(Strings.btnclockout, () {
                        clockOutwithPIN();
                      }),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.safeBlockVertical * 2,
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
                                      style: Styles.orangeMedium()))
                            ])
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
          side: BorderSide(color: Colors.grey)),
      height: MediaQuery.of(context).size.height / 9,
      // minWidth: MediaQuery.of(context).size.width / 9.9,
      child: Text(number,
          textAlign: TextAlign.center, style: Styles.communBlack()),
      textColor: Colors.black,
      color: Colors.grey[100],
      onPressed: f,
    );
  }

  Widget _buttonCN(String number, Function() f) {
    // Creating a method of return type Widget with number and function f as a parameter
    return MaterialButton(
      padding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(color: Colors.grey)),
      height: MediaQuery.of(context).size.height / 8.7,
      // minWidth: MediaQuery.of(context).size.width / 9.9,
      child: Text(number,
          textAlign: TextAlign.center, style: Styles.blackBoldsmall()),
      textColor: Colors.black,
      color: Colors.grey[100],
      onPressed: f,
    );
  }
}
