import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/services/LocalAPIs.dart';

class ChoosePrinterDailog extends StatefulWidget {
  ChoosePrinterDailog({Key key, this.selectedIP, this.onClose})
      : super(key: key);
  final selectedIP;
  Function onClose;
  @override
  ChoosePrinterDailogState createState() => ChoosePrinterDailogState();
}

class ChoosePrinterDailogState extends State<ChoosePrinterDailog> {
  @override
  void initState() {
    super.initState();
  }

  selecttype() {}
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
                Text("Printer Type", style: Styles.whiteBold()),
              ],
            ),
          ),
          Positioned(
              left: 20,
              top: 10,
              child: FlatButton(
                  onPressed: () {
                    widget.onClose(1);
                  },
                  child: Text("Done", style: Styles.whiteSimpleSmall()))),
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
      height: MediaQuery.of(context).size.height / 2,
      width: MediaQuery.of(context).size.width / 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
              child: ListView(
            padding: EdgeInsets.all(0),
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                  title: Text(
                    "Receipt Printer",
                    style: Styles.communBlack(),
                  ),
                  trailing: Transform.scale(
                    scale: 1,
                    child: CupertinoSwitch(
                      value: false,
                      onChanged: (bool value) {
                        // setState(() {
                        //   _switchValue = value;
                        // });
                      },
                    ),
                  )),
              ListTile(
                title: Text(
                  "Kitchen Printer",
                  style: Styles.communBlack(),
                ),
                trailing: Transform.scale(
                  scale: 1,
                  child: CupertinoSwitch(
                    value: false,
                    onChanged: (bool value) {
                      // setState(() {
                      //   _switchValue = value;
                      // });
                    },
                  ),
                ),
              ),
            ],
          ))
        ],
      ),
    );
  }
}
