import 'package:flutter/material.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/screens/OpningAmountPop.dart';
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
  double ammount = 0.00;
  var selectedreason;
  List<String> reasonList = [
    "Deposit",
    "Other",
  ];
  @override
  void initState() {
    super.initState();
    // setState(() {
    //   ammount = widget.ammount;
    // });
  }

  openAmmountPop() {
    showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return OpeningAmmountPage(
              ammountext: "Pay In Amount",
              onEnter: (ammountext) {
                print(ammountext);
                setamount(ammountext);
              });
        });
  }

  setamount(ammountext) {
    if (ammountext is String) {
      setState(() {
        ammount = double.parse(ammountext);
      });
    }
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
                Text(widget.title, style: Styles.whiteMediumBold()),
              ],
            ),
          ),
          Positioned(left: 5, top: 10, child: addbutton(context)),
          closeButton(context),
        ],
      ),
      content: mainContent(),
    );
  }

  Widget addbutton(context) {
    return RaisedButton(
      padding: EdgeInsets.all(2),
      onPressed: () {
        widget.onClose(ammount, selectedreason);
      },
      child: Text(
        "Confirm",
        style: Styles.whiteSimpleSmall(),
      ),
      color: Colors.deepOrange,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
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
          GestureDetector(
              onTap: () {
                openAmmountPop();
              },
              child: Text(ammount.toStringAsFixed(2),
                  style: Styles.blackBoldLarge())),
          Text('reason', style: Styles.drawerText()),
          Container(
              width: MediaQuery.of(context).size.width / 4,
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(top: 5),
              height: 50,
              color: Colors.grey[300],
              child: Center(
                child: DropdownButton<String>(
                  underline: Container(
                    color: Colors.transparent,
                  ),
                  elevation: 5,
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                  ),
                  hint: Text("Please select reason"),
                  value: selectedreason,
                  isExpanded: true,
                  onChanged: (String string) {
                    setState(() {
                      selectedreason = string;
                    });
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return reasonList.map<Widget>((item) {
                      return Text(item, style: Styles.communBlacksmall());
                    }).toList();
                  },
                  items: reasonList.map((item) {
                    return DropdownMenuItem<String>(
                      child: Text(item, style: Styles.communBlacksmall()),
                      value: item,
                    );
                  }).toList(),
                ),
              )),
        ],
      ),
    );
  }
}
