import 'package:flutter/material.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/services/user.dart' as repo;

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailAddress = new TextEditingController();
  TextEditingController userPin = new TextEditingController();
  GlobalKey<ScaffoldState> scaffoldKey;
  var errormessage = "";
  bool isValidateEmail = true;
  bool isValidatePassword = true;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  validateFields() async {
    if (emailAddress.text == "" || emailAddress.text.length == 0) {
      setState(() {
        errormessage = "Please enter email address.";
        isValidateEmail = false;
      });
      return false;
    } else if (userPin.text == "" || userPin.text.length == 0) {
      setState(() {
        errormessage = "Please enter PIN.";
        isValidatePassword = false;
      });
      return false;
    } else {
      return true;
    }
  }

  sendlogin() async {
    var isValid = await validateFields();
    var deviceinfo = await CommunFun.deviceInfo();
    Navigator.pushNamed(context, '/PINPage');
    // if (isValid) {
    //   setState(() {
    //     isLoading = true;
    //   });
    //   User user = new User();
    //   user.name = emailAddress.text;
    //   user.userPin = int.parse(userPin.text);
    //   user.deviceType = deviceinfo.type;
    //   user.deviceToken = deviceinfo.androidId;
    //   user.deviceId = deviceinfo.id;
    //   user.terminalId = "1";
    //   await repo.login(user).then((value) async {
    //     print(value);
    //     if (value != null && value.status == 200) {
    //       Navigator.pushNamed(context, '/PINPage');
    //     } else {
    //       setState(() {
    //         isLoading = false;
    //       });
    //       scaffoldKey.currentState.showSnackBar(SnackBar(
    //         content: Text(value.message),
    //       ));
    //     }
    //   }).catchError((e) {
    //     setState(() {
    //       isLoading = false;
    //     });
    //     print(e);
    //     scaffoldKey.currentState.showSnackBar(SnackBar(
    //       content: Text(e.message),
    //     ));
    //   }).whenComplete(() {
    //     setState(() {
    //       isLoading = false;
    //     });
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Container(
        width: MediaQuery.of(context).size.width / 1.8,
        padding: EdgeInsets.only(left: 30, right: 30),
        child: new SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              loginlogo(),
              SizedBox(height: 40),
              CommunFun.loginText(),
              SizedBox(height: 50),
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
              passwordInput((e) {
                setState(() {
                  errormessage = "";
                  isValidatePassword = true;
                });
              }),
              SizedBox(height: 50),
              GestureDetector(
                onTap: () {
                  // TODO : goto Forgot password
                },
                child: CommunFun.forgotPasswordText(context),
              ),
              SizedBox(height: 50),
              isLoading
                  ? CommunFun.loader(context)
                  : Container(
                      width: MediaQuery.of(context).size.width,
                      child: CommunFun.roundedButton("LOGIN", () {
                        // TODO : LOGIN API
                        //Navigator.pushNamed(context, '/PINPage'); // Goto next page
                        sendlogin();
                      }),
                    )
            ],
          ),
        ),
      ),
    ));
  }

  Widget loginlogo() {
    return SizedBox(
      height: 110.0,
      child: Image.asset(
        "assets/headerlogo.png",
        fit: BoxFit.contain,
      ),
    );
  }

  Widget emailInput(Function onChange) {
    return TextField(
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
        hintText: "Username",
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
      controller: userPin,
      keyboardType: TextInputType.number,
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
        errorStyle: TextStyle(color: Colors.red),
        hintText: "Pin",
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
