import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/services/user.dart' as repo;
import 'package:mcncashier/theme/Sized_Config.dart';

class LoginPage extends StatefulWidget {
  // LOGIN Page
  LoginPage({Key key, this.terminalId}) : super(key: key);
  final String terminalId;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailAddress = new TextEditingController(text: "marslab");
  TextEditingController userPin = new TextEditingController(text: "120332");
  GlobalKey<ScaffoldState> scaffoldKey;

  // DatabaseHelper databaseHelper = DatabaseHelper();
  var errorUserName = "";
  var errorPin = "";
  bool isValidateEmail = true;
  bool isValidatePassword = true;
  bool isScreenLoad = false;
  @override
  void initState() {
    super.initState();
    // databaseHelper.initializeDatabase(); // Initialize database first time here
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
        errorUserName = Strings.username_validation_msg;
        errorPin = "";
        isValidateEmail = false;
      });
      return false;
    } else if (userPin.text == "" || userPin.text.length == 0) {
      setState(() {
        errorPin = Strings.userPin_validation_msg;
        errorUserName = "";
        isValidatePassword = false;
      });
      return false;
    } else {
      return true;
    }
  }

  Future<bool> _willPopCallback() async {
    return false;
  }

  sendlogin() async {
    // Login click fun

    var isValid = await validateFields(); // check validation
    var deviceinfo = await CommunFun.deviceInfo();
    var connected = await CommunFun.checkConnectivity();
    if (connected) {
      if (isValid) {
        setState(() {
          isScreenLoad = true;
        });
        User user = new User();
        var terkey = await CommunFun.getTeminalKey();
        user.name = emailAddress.text;
        user.userPin = int.parse(userPin.text);
        user.deviceType = deviceinfo["deviceType"];
        user.deviceToken = deviceinfo["deviceToken"];
        user.deviceId = deviceinfo["deviceId"];
        user.terminalId = terkey != null ? terkey : '1'; //widget.terminalId;
        await repo.login(user).then((value) async {
          if (value != null && value["status"] == Constant.STATUS200) {
            await Preferences.setStringToSF(Constant.IS_LOGIN, "true");
            user = User.fromJson(value["data"]);
            await CommunFun.syncAfterSuccess(context, true);
            setState(() {
              isScreenLoad = false;
            });
          } else {
            setState(() {
              isScreenLoad = false;
            });
            CommunFun.showToast(context, value["message"]);
          }
        }).catchError((e) {
          setState(() {
            isScreenLoad = false;
          });
          CommunFun.showToast(context, e.message);
        }).whenComplete(() {});
      }
    } else {
      CommunFun.showToast(context, Strings.internet_connection_lost);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      child: Scaffold(
        key: scaffoldKey,
        body: LoadingOverlay(
            child: SafeArea(
              child: Center(
                // Login main part
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.8,
                  padding: EdgeInsets.only(left: 30, right: 30),
                  child: new SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        loginlogo(), // logo
                        SizedBox(height: SizeConfig.safeBlockVertical * 5),
                        CommunFun.loginText(),
                        SizedBox(height: SizeConfig.safeBlockVertical * 6),
                        // username input
                        emailInput((e) {
                          if (e.length > 0) {
                            setState(() {
                              errorUserName = "";
                              isValidateEmail = true;
                            });
                          }
                        }),
                        SizedBox(height: SizeConfig.safeBlockVertical * 6),
                        // password input
                        passwordInput((e) {
                          setState(() {
                            errorPin = "";
                            isValidatePassword = true;
                          });
                        }),
                        SizedBox(height: SizeConfig.safeBlockVertical * 6),
                        Container(
                          // Login button
                          width: MediaQuery.of(context).size.width,
                          child: CommunFun.roundedButton("LOGIN", context, () {
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
            isLoading: isScreenLoad,
            color: Colors.black87,
            progressIndicator: CommunFun.overLayLoader()),
      ),
      onWillPop: _willPopCallback,
    );
  }

  Widget loginlogo() {
    return SizedBox(
      // login logo
      //height: 110.0,
      height: SizeConfig.safeBlockVertical * 15,
      child: Image.asset(
        Strings.asset_headerLogo,
        fit: BoxFit.contain,
        gaplessPlayback: true,
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
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Icon(
            Icons.perm_identity,
            color: Colors.black,
            size: SizeConfig.safeBlockVertical * 6,
          ),
        ),
        errorText: !isValidateEmail ? errorUserName : null,
        errorStyle: TextStyle(
            color: Colors.red, fontSize: SizeConfig.safeBlockVertical * 4),
        hintText: Strings.username_hint,
        hintStyle: Styles.normalBlack(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
        ),
        filled: true,
        contentPadding: EdgeInsets.only(
            top: SizeConfig.safeBlockVertical * 3,
            bottom: SizeConfig.safeBlockVertical * 3),
        fillColor: Colors.white,
      ),
      style: Styles.normalBlack(),
      onChanged: onChange,
    );
  }

  Widget passwordInput(Function onChange) {
    return TextField(
      // User pin input
      controller: userPin,
      obscureText: true,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly
      ],
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Icon(
            Icons.lock_outline,
            color: Colors.black,
            size: SizeConfig.safeBlockVertical * 6,
          ),
        ),
        errorText: !isValidatePassword ? errorPin : null,
        errorStyle: TextStyle(
            color: Colors.red, fontSize: SizeConfig.safeBlockVertical * 4),
        hintText: Strings.pin_hint,
        hintStyle: Styles.normalBlack(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
        ),
        filled: true,
        contentPadding: EdgeInsets.only(
            top: SizeConfig.safeBlockVertical * 3,
            bottom: SizeConfig.safeBlockVertical * 3),
        fillColor: Colors.white,
      ),
      //obscureText: true,
      style: Styles.normalBlack(),
      onChanged: onChange,
    );
  }
}
