import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/services/user.dart' as repo;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  // LOGIN Page
  LoginPage({Key key, this.terminalId}) : super(key: key);
  final String terminalId;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailAddress = new TextEditingController();
  TextEditingController userPin = new TextEditingController();
  GlobalKey<ScaffoldState> scaffoldKey;
  DatabaseHelper databaseHelper = DatabaseHelper();
  var errormessage = "";
  bool isValidateEmail = true;
  bool isValidatePassword = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    databaseHelper.initializeDatabase(); // Initialize database first time here
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
  }

  validateFields() async {
    if (emailAddress.text == "" || emailAddress.text.length == 0) {
      setState(() {
        errormessage = Strings.username_validation_msg;
        isValidateEmail = false;
      });
      return false;
    } else if (userPin.text == "" || userPin.text.length == 0) {
      setState(() {
        errormessage = Strings.userPin_validation_msg;
        isValidatePassword = false;
      });
      return false;
    } else {
      return true;
    }
  }

  sendlogin() async {
    // Login click fun
    // Navigator.pushNamed(context, '/PINPage');
    var isValid = await validateFields(); // check validation
    var deviceinfo = await CommunFun.deviceInfo();
    if (isValid) {
      setState(() {
        isLoading = true;
      });
      User user = new User();
      var terkey = await Preferences.getStringValuesSF(Constant.TERMINAL_KEY);
      user.name = emailAddress.text;
      user.userPin = int.parse(userPin.text);
      user.deviceType = deviceinfo.type;
      user.deviceToken = deviceinfo.androidId;
      user.deviceId = deviceinfo.id;
      user.terminalId = terkey != null ? terkey : '1'; //widget.terminalId;
      await repo.login(user).then((value) async {
        if (value != null && value["status"] == Constant.STATUS200) {
          print(value);
          user = User.fromJson(value["data"]);
          Preferences.setJsonSF(Constant.LOIGN_USER, user);
          Preferences.setBoolToSF(Constant.IS_USER_LOGIN, true);
          await CommunFun.syncAfterSuccess(context);
        } else {
          setState(() {
            isLoading = false;
          });
          CommunFun.showToast(context, value["message"]);
        }
      }).catchError((e) {
        setState(() {
          isLoading = false;
        });
        print(e);
        CommunFun.showToast(context, e.message);
      }).whenComplete(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Center(
          // Login main part
          child: Container(
            width: MediaQuery.of(context).size.width / 1.8,
            padding: EdgeInsets.only(left: 30, right: 30),
            child: new SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  loginlogo(), // logo
                  SizedBox(height: 40),
                  CommunFun.loginText(),
                  SizedBox(height: 50),
                  // username input
                  emailInput((e) {
                    print("on changes");
                    if (e.length > 0) {
                      setState(() {
                        errormessage = "";
                        isValidateEmail = true;
                      });
                    }
                  }),
                  SizedBox(height: 50),
                  // password input
                  passwordInput((e) {
                    setState(() {
                      errormessage = "";
                      isValidatePassword = true;
                    });
                  }),
                  SizedBox(height: 50),
                  GestureDetector(
                    // forgot password btn
                    onTap: () {
                      // TODO : goto Forgot password
                    },
                    child: CommunFun.forgotPasswordText(context),
                  ),
                  SizedBox(height: 50),
                  isLoading
                      ? CommunFun.loader(context)
                      : Container(
                          // Login button
                          width: MediaQuery.of(context).size.width,
                          child: CommunFun.roundedButton("LOGIN", () {
                            // LOGIN API
                            sendlogin();
                          }),
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget loginlogo() {
    return SizedBox(
      // login logo
      height: 110.0,
      child: Image.asset(
        "assets/headerlogo.png",
        fit: BoxFit.contain,
      ),
    );
  }

  Widget emailInput(Function onChange) {
    return TextField(
      // username input
      controller: emailAddress,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 25, right: 25),
          child: Icon(
            Icons.perm_identity,
            color: Colors.black,
            size: 40,
          ),
        ),
        errorText: !isValidateEmail ? errormessage : null,
        errorStyle: TextStyle(color: Colors.red, fontSize: 25.0),
        hintText: Strings.username_hint,
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
      onChanged: onChange,
    );
  }

  Widget passwordInput(Function onChange) {
    return TextField(
      // User pin input
      controller: userPin,
      obscureText: true,
      keyboardType: TextInputType.number,
      // inputFormatters: <TextInputFormatter>[
      //    FilteringTextInputFormatter.digitsOnly
      //  ],
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Icon(
            Icons.lock_outline,
            color: Colors.black,
            size: 40,
          ),
        ),
        errorText: !isValidatePassword ? errormessage : null,
        errorStyle: TextStyle(color: Colors.red, fontSize: 25.0),
        hintText: Strings.pin_hint,
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
      //obscureText: true,
      style: TextStyle(color: Colors.black, fontSize: 25.0),
      onChanged: onChange,
    );
  }
}
