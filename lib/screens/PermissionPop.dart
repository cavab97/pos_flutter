import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/PosPermission.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/theme/Sized_Config.dart';

class OpenPermissionPop extends StatefulWidget {
  // Opning ammount popup
  OpenPermissionPop({Key key, this.perFor, this.onEnter}) : super(key: key);
  Function onEnter;
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
          print(permissions[0].posPermissionName);
          if (permissions[0].posPermissionName != null &&
              permissions[0].posPermissionName.contains(widget.perFor)) {
            Navigator.of(context).pop();
            widget.onEnter();
          } else {
            CommunFun.showToast(context,
                "This user have not permission to perform this action");
          }
        }
      } else {
        CommunFun.showToast(context, "Invalid PIN");
      }
    } else {
      CommunFun.showToast(context, "Invalid PIN");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      title: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(SizeConfig.safeBlockVertical * 3),
            height: SizeConfig.safeBlockVertical * 9,
            color: Colors.black,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Please enter PIN", style: Styles.whiteBoldsmall()),
              ],
            ),
          ),
          closeButton(context), //popup close btn
        ],
      ),
      content: mainContent(), // Popup body contents
    );
  }

  Widget closeButton(context) {
    return Positioned(
      top: -30,
      right: -20,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
              color: Colors.red, borderRadius: BorderRadius.circular(30.0)),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.clear,
              color: Colors.white,
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

  Widget _enterbutton(Function() f) {
    // Creating a method of return type Widget with number and function f as a parameter
    return MaterialButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(color: Colors.grey)),
      height: MediaQuery.of(context).size.height / 9,
      // minWidth: MediaQuery.of(context).size.width / 9.9,
      child: Icon(Icons.subdirectory_arrow_left),
      textColor: Colors.black,
      color: Colors.grey[100],
      onPressed: f,
    );
  }

  Widget _backbutton(Function() f) {
    // Creating a method of return type Widget with number and function f as a parameter
    return MaterialButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(color: Colors.grey)),
      height: MediaQuery.of(context).size.height / 9,
      // minWidth: MediaQuery.of(context).size.width / 9.9,
      child: Icon(Icons.clear),
      textColor: Colors.black,
      color: Colors.grey[100],
      onPressed: f,
    );
  }
}
