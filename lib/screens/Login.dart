import 'package:flutter/material.dart';
import 'package:mcncashier/components/communText.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailAddress = new TextEditingController();
  TextEditingController password = new TextEditingController();
  var errormessage = "";
  bool isValidateEmail = true;
  bool isValidatePassword = true;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
  }

  validateFields() async {
    if (emailAddress.text == "" || emailAddress.text.length == 0) {
      setState(() {
        errormessage = "Please enter email address.";
        isValidateEmail = false;
      });
      return false;
    } else if (password.text == "" || password.text.length == 0) {
      setState(() {
        errormessage = "Please enter password.";
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
    if (isValid) {
      setState(() {
        isLoading = true;
      });
      var email = emailAddress.text;
      var password = emailAddress.text;
      var deviceType = deviceinfo.type;
      var deviceToken = deviceinfo.androidId;
      var device_id = deviceinfo.id;

      ///TODO : API call
      ///
      Navigator.pushNamed(context, '/PINPage');
      setState(() {
        isLoading = false;
      });
    }
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
              Container(
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
            Icons.mail_outline,
            color: Colors.black,
            size: 40,
          ),
        ),
        errorText: !isValidateEmail ? errormessage : null,
        errorStyle: TextStyle(color: Colors.red, fontSize: 25.0),
        hintText: "Email",
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
      controller: password,
      keyboardType: TextInputType.text,
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
        hintText: "Password",
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
      obscureText: true,
      style: TextStyle(color: Colors.black, fontSize: 25.0),
      onChanged: onChange,
    );
  }
}
