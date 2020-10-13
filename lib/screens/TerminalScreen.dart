import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/TerminalKey.dart';
import 'package:mcncashier/services/teminalkey.dart' as repo;

class TerminalKeyPage extends StatefulWidget {
  //Terminal key page
  TerminalKeyPage({Key key}) : super(key: key);

  @override
  _TerminalKeyPageState createState() => _TerminalKeyPageState();
}

class _TerminalKeyPageState extends State<TerminalKeyPage> {
  TextEditingController terminalKey = new TextEditingController(text: "Hmpi");
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
    // validate Fields
    if (terminalKey.text == "" || terminalKey.text.length == 0) {
      setState(() {
        errormessage = Constant.VALID_TERMINAL_KEY;
        isValidatekey = false;
      });
      return false;
    } else {
      return true;
    }
  }

  setTerminalkey() async {
    var isValid = await validateFields(); // validate fields
    var deviceinfo = await CommunFun.deviceInfo();
    TemimalKey terminal = new TemimalKey();
    var connected = await CommunFun.checkConnectivity();
    if (connected) {
      if (isValid) {
        setState(() {
          isLoading = true;
        });
        terminal.terminalKey = terminalKey.text;
        terminal.deviceid = deviceinfo["deviceId"];
        terminal.terDeviceToken = deviceinfo["deviceToken"];
        await repo.sendTerminalKey(terminal).then((value) async {
          if (value != null && value["status"] == Constant.STATUS200) {
            Preferences.setStringToSF(
                Constant.TERMINAL_KEY, value["terminal_id"].toString());
            Preferences.setStringToSF(
                Constant.BRANCH_ID, value["branch_id"].toString());
            Navigator.pushNamed(context, Constant.LoginScreen,
                arguments: {"terminalId": value["terminal_id"]});
          } else if (value != null && value["status"] == Constant.STATUS422) {
            CommunFun.showToast(context, value["message"]);
          } else {
            CommunFun.showToast(context, value["message"]);
          }
        }).catchError((e) {
        
          CommunFun.showToast(context, e.message);
          setState(() {
            isLoading = false;
          });
        }).whenComplete(() {
          setState(() {
            isLoading = false;
          });
        });
      }
    } else {
      CommunFun.showToast(context, Strings.internet_connection_lost);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  main part of the page
      key: scaffoldKey,
      body: SafeArea(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width / 1.7,
            child: new SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  loginlogo(), // Login logo
                  SizedBox(height: 80),
                  terminalKeyInput((e) {
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
                          // Key add button
                          width: MediaQuery.of(context).size.width,
                          child: CommunFun.roundedButton(
                              Strings.set_terminal_key.toUpperCase(), context,
                              () {
                            setTerminalkey();
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
      height: 110.0,
      child: Image.asset(
        Strings.asset_headerLogo,
        fit: BoxFit.contain,
        gaplessPlayback: true,
      ),
    );
  }

  Widget terminalKeyInput(Function onChange) {
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
        hintText: Strings.terminalKey,
        hintStyle: Styles.normalBlack(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        filled: true,
        contentPadding: EdgeInsets.only(top: 20, bottom: 20),
        fillColor: Colors.white,
      ),
      style: Styles.normalBlack(),
      onChanged: onChange,
    );
  }
}
