import 'package:flutter/material.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/models/TerminalKey.dart';
import 'package:mcncashier/services/teminalkey.dart' as repo;

class TerminalKeyPage extends StatefulWidget {
  TerminalKeyPage({Key key}) : super(key: key);
  @override
  _TerminalKeyPageState createState() => _TerminalKeyPageState();
}

class _TerminalKeyPageState extends State<TerminalKeyPage> {
  TextEditingController terminalKey = new TextEditingController();
  GlobalKey<ScaffoldState> scaffoldKey;
  var errormessage = "";
  bool isValidatekey = true;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  validateFields() async {
    if (terminalKey.text == "" || terminalKey.text.length == 0) {
      setState(() {
        errormessage = "Please enter terminal key.";
        isValidatekey = false;
      });
      return false;
    } else {
      return true;
    }
  }

  setTerminalkey() async {
    var isValid = await validateFields();
    var deviceinfo = await CommunFun.deviceInfo();
    TemimalKey terminal = new TemimalKey();
    if (isValid) {
      setState(() {
        isLoading = true;
      });
      terminal.terminalKey = terminalKey.text;
      terminal.deviceid = deviceinfo.id;
      await repo.sendTerminalKey(terminal).then((value) async {
        print(value);
        if (value != null && value.status == 200) {
          Navigator.pushNamed(context, '/Login');
        } else {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(value.message),
          ));
        }
      }).catchError((e) {
        print(e);
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(e.message),
        ));
      }).whenComplete(() {
        setState(() {
          isLoading = false;
        });
      });
      Navigator.pushNamed(context, '/Login');
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
              SizedBox(height: 80),
              emailInput((e) {
                print("on changes");
                if (e.length > 0) {
                  setState(() {
                    errormessage = "";
                    isValidatekey = true;
                  });
                }
              }),
              SizedBox(height: 50),
              isLoading
                  ? CommunFun.loader(context)
                  : Container(
                      width: MediaQuery.of(context).size.width,
                      child: CommunFun.roundedButton("Set Teminal Key", () {
                        setTerminalkey();
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
      controller: terminalKey,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 25, right: 25),
          child: Icon(
            Icons.vpn_key,
            color: Colors.black,
            size: 40,
          ),
        ),
        errorText: !isValidatekey ? errormessage : null,
        errorStyle: TextStyle(color: Colors.red, fontSize: 25.0),
        hintText: "Terminal Key",
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
}
