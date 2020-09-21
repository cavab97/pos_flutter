import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';

class PrinterListDailog extends StatefulWidget {
  PrinterListDailog({Key key, this.onPress}) : super(key: key);
  Function onPress;
  @override
  _PrinterListDailogState createState() => _PrinterListDailogState();
}

class _PrinterListDailogState extends State<PrinterListDailog> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      title: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
            height: 70,
            color: Colors.black,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Select Printer",
                    style: TextStyle(fontSize: 30, color: Colors.white)),
              ],
            ),
          ),
          Positioned(
            right: 30,
            top: 10,
            child: Icon(
              Icons.print,
              color: Colors.white,
              size: 50,
            ),
          ),
          closeButton(context),
        ],
      ),
      content: mainContent(),
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
            child: Icon(
              Icons.clear,
              color: Colors.white,
              size: 30,
            ),
          ),
        ));
  }

  //widget.onPress;
  Widget mainContent() {
    return Container(
        width: MediaQuery.of(context).size.width / 2.5, child: ListView());
  }
}
