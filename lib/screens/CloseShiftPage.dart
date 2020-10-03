import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/services/LocalAPIs.dart';

class CloseShiftPage extends StatefulWidget {
  CloseShiftPage({Key key, this.onClose}) : super(key: key);
  Function onClose;
  @override
  CloseShiftPageState createState() => CloseShiftPageState();
}

class CloseShiftPageState extends State<CloseShiftPage> {
  LocalAPI localAPI = LocalAPI();
  Shift shifittem = new Shift();
  @override
  void initState() {
    super.initState();

    getshiftData();
  }

  getshiftData() async {
    var shiftid = await Preferences.getStringValuesSF(Constant.DASH_SHIFT);
    if (shiftid != null) {
      List<Shift> shift = await localAPI.getShiftData(shiftid);
      setState(() {
        shifittem = shift[0];
      });
    }
  }

  Widget shiftbtn(Function onPress) {
    return RaisedButton(
      padding: EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 20),
      onPressed: onPress,
      child: Text(
        Strings.close_shift,
        style: TextStyle(color: Colors.white, fontSize: 25),
      ),
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        side:
            BorderSide(width: 1, style: BorderStyle.solid, color: Colors.white),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent.withOpacity(0.7),
      contentPadding: EdgeInsets.all(0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              color: Colors.white,
              iconSize: 50,
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ],
      ),
      content: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                Strings.shiftTextLableOpen,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              Text(
                Strings.opened_at,
                textAlign: TextAlign.center,
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.white,
                    fontSize: 25),
              ),
              SizedBox(height: 30),
              Text(
                DateFormat('EEE, MMM d yyyy, hh:mm aaa').format(DateTime.parse(
                    shifittem.updatedAt != null
                        ? shifittem.updatedAt
                        : DateTime.now().toString())),
                textAlign: TextAlign.center,
                style: Styles.whiteSimpleSmall(),
              ),
              SizedBox(height: 30),
              shiftbtn(() {
                Navigator.of(context).pop();
                widget.onClose();
              })
            ],
          ),
        ),
      ),
    );
  }
}
