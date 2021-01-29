import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/services/allTablesSync.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:mcncashier/components/colors.dart';

class OpeningAmmountPage extends StatefulWidget {
  // Opning ammount popup
  OpeningAmmountPage({Key key, this.ammountext, this.onEnter})
      : super(key: key);
  Function onEnter;
  final String ammountext;

  @override
  _OpeningAmmountPageState createState() => _OpeningAmmountPageState();
}

class _OpeningAmmountPageState extends State<OpeningAmmountPage> {
  String currentNumber = "0";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: Stack(
        // popup header
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(SizeConfig.safeBlockVertical * 3),
            height: SizeConfig.safeBlockVertical * 9,
            color: StaticColor.colorBlack,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(widget.ammountext.toString().toUpperCase(),
                    style: Styles.whiteBoldsmall()),
              ],
            ),
          ),
          closeButton(context), //popup close btn
        ],
      ),
      content: mainContent(), // Popup body contents
    );
  }

  backspaceClick() {
    String currentnumber = currentNumber;
    currentnumber = currentnumber.substring(0, currentnumber.length - 1);
    if (currentnumber != null &&
        currentnumber.length > 0 &&
        currentnumber.isNotEmpty) {
      setState(() {
        currentNumber = currentnumber;
      });
    } else if (this.mounted) {
      setState(() {
        currentNumber = "0";
      });
    }
  }

  numberClick(val) {
    String currentnumber = currentNumber.replaceAll("^0+", "");
    if (double.tryParse(currentnumber) == 0) {
      currentnumber = "";
    }
    if (currentnumber == "" && (val == "00" || val == "0")) {
      currentnumber = "0";
    } else {
      currentnumber += val;
    }
    setState(() {
      currentNumber = currentnumber;
    });
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

  Widget mainContent() {
    return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            getAmount(), // dynamic enter ammount
            getNumbers(context), // numbers buttons
          ],
        ));
  }

  Widget _button(String number, Function() f) {
    var size = MediaQuery.of(context).size.width / 2.3;
    double resize = size / 6;
    return Container(
      width: (number == "00") ? (resize * 2) : resize,
      padding: EdgeInsets.all(SizeConfig.safeBlockVertical * 1),
      height: (number == Strings.enter) ? (resize * 2) : resize,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: BorderSide(color: StaticColor.colorGrey)),
        child: number != Strings.enter
            ? Text(number,
                textAlign: TextAlign.center, style: Styles.blackMediumBold())
            : Icon(Icons.subdirectory_arrow_left, size: 35),
        textColor: StaticColor.colorBlack,
        color: StaticColor.lightGrey100,
        onPressed: f,
      ),
    );
  }

  Widget _backbutton(Function() f) {
    var size = MediaQuery.of(context).size.width / 2.3;
    double resize = size / 6;
    return Container(
      width: resize,
      padding: EdgeInsets.all(5),
      height: resize,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: BorderSide(color: StaticColor.colorGrey)),
        child: Icon(
          Icons.backspace,
          color: StaticColor.colorBlack,
          size: SizeConfig.safeBlockVertical * 4,
        ),
        textColor: StaticColor.colorBlack,
        color: StaticColor.lightGrey100,
        onPressed: f,
      ),
    );
  }

  Widget getAmount() {
    return Container(
      padding: EdgeInsets.only(left: 30, right: 30, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(currentNumber, style: Styles.blackBoldLarge()),
        ],
      ),
    );
  }

  Widget getNumbers(context) {
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _button("1", () {
                  numberClick('1');
                }), // using custom widget button
                _button("2", () {
                  numberClick('2');
                }),
                _button("3", () {
                  numberClick('3');
                }),
                _backbutton(() {
                  backspaceClick();
                }),
              ],
            ),
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _button("4", () {
                  numberClick('4');
                }), // using custom widget button
                _button("5", () {
                  numberClick('5');
                }),
                _button("6", () {
                  numberClick('6');
                }),
                _button(".", () {
                  if (!currentNumber.contains(".")) {
                    numberClick('.');
                  }
                }),
              ],
            ),
            Row(children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _button("7", () {
                        numberClick('7');
                      }),
                      _button("8", () {
                        numberClick('8');
                      }),
                      _button("9", () {
                        numberClick('9');
                      }),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      _button("0", () {
                        numberClick('0');
                      }),
                      _button("00", () {
                        numberClick('00');
                      }),
                    ],
                  ),
                ],
              ),
              _button(Strings.enter, () async {
                await SyncAPICalls.logActivity(
                    "shift",
                    "Added opning closing amount " + currentNumber.toString(),
                    "shift",
                    1);
                widget.onEnter(currentNumber);
                Navigator.of(context).pop();
              })
            ])
          ],
        ),
      ),
    );
  }
}
