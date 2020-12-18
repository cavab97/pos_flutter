import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/components/colors.dart';

class SelectPrinterDailog extends StatefulWidget {
  SelectPrinterDailog({Key key, this.onClose}) : super(key: key);
  Function onClose;

  @override
  SelectPrinterDailogState createState() => SelectPrinterDailogState();
}

class SelectPrinterDailogState extends State<SelectPrinterDailog> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  LocalAPI localAPI = LocalAPI();

  /*For printer */
  String localIp = '';
  List<String> devices = [];
  bool isDiscovering = false;
  int found = -1;

  // int portController = 1900;
  List<MSTCartdetails> itemList = [];

  @override
  void initState() {
    super.initState();
  }

  addPrinter(ip) {
    widget.onClose(ip);
    //TODO: save printer  apic call
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
            color: StaticColor.colorBlack,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(Strings.scanPrinter, style: Styles.whiteBold()),
              ],
            ),
          ),
          Positioned(
              right: 30,
              top: 10,
              child: FlatButton(
                  onPressed: () {},
                  child: Text(Strings.scan, style: Styles.whiteSimpleSmall()))),
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
              color: StaticColor.colorRed,
              borderRadius: BorderRadius.circular(30.0)),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.clear,
              color: StaticColor.colorWhite,
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
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(Strings.list, style: Styles.communBlack()),
          SizedBox(height: 10),
          Container(
            // height: MediaQuery.of(context).size.height / 2.2,
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: devices.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () => addPrinter(devices[index]),
                  child: Text(
                    '${devices[index]}:1900',
                    //${portController.text}',
                    style: Styles.communBlack(),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
