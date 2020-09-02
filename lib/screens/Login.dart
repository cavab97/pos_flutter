import 'package:flutter/material.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailAddress = new TextEditingController();
  TextEditingController password = new TextEditingController();

  @override
  void initState() {
    super.initState();
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
              }),
              SizedBox(height: 50),
              passwordInput((e) {}),
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
                  Navigator.pushNamed(context, '/PINPage'); // Goto next page
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
