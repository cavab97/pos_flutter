import 'package:flutter/material.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/services/LocalAPIs.dart';

class PayInOutDailog extends StatefulWidget {
  PayInOutDailog({Key key, this.title, this.ammount, this.onClose})
      : super(key: key);
  Function onClose;
  final title;
  final ammount;
  @override
  PayInOutDailogstate createState() => PayInOutDailogstate();
}

class PayInOutDailogstate extends State<PayInOutDailog> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  LocalAPI localAPI = LocalAPI();

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
            padding: EdgeInsets.only(left: 50, right: 30, top: 10, bottom: 10),
            height: 70,
            color: Colors.black,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(widget.title, style: Styles.whiteBold()),
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 10,
            child: FlatButton(
              onPressed: () {},
              child: Text(
                "Confirm",
                style: Styles.whiteSimpleSmall(),
              ),
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

  //widget.onPress;
  Widget mainContent() {
    return Container(
      height: MediaQuery.of(context).size.height / 2.4,
      width: MediaQuery.of(context).size.width / 3,
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(widget.title, style: Styles.drawerText()),
          Text(widget.ammount, style: Styles.blackBoldLarge()),
          Text('reason', style: Styles.drawerText()),
          Container(
            width: MediaQuery.of(context).size.width / 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("Add change", style: Styles.drawerText()),
                Icon(Icons.keyboard_arrow_down)
              ],
            ),
          )
        ],
      ),
    );
  }
}
