import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/styles.dart';

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
  String currentNumber = "00";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      title: Stack(
        // popup header
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
                Text(widget.ammountext.toString().toUpperCase(),
                    style: TextStyle(fontSize: 20, color: Colors.white)),
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
    if (currentNumber != "00" && currentNumber != "0") {
      var currentnumber = currentNumber;
      if (currentnumber != null && currentnumber.length > 0) {
        currentnumber = currentnumber.substring(0, currentnumber.length - 1);
        if (currentnumber.length == 0) {
          currentnumber = "00";
        }
        setState(() {
          currentNumber = currentnumber;
        });
      } else {
        currentNumber = "00";
      }
    }
  }

  numberClick(val) {
    // add  value in prev value
    if (currentNumber.length <= 8) {
      var currentnumber = currentNumber;
      if (currentnumber == "00") {
        currentnumber = "";
      }
      currentnumber += val;
      setState(() {
        currentNumber = currentnumber;
      });
    }
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

  Widget mainContent() {
    return SingleChildScrollView(
        child: Column(
      children: [
        getAmount(), // dynamic enter ammount
        SizedBox(
          height: 10,
        ),
        getNumbers(context), // numbers buttons
      ],
    ));
  }

  Widget _button(String number, Function() f) {
    var size = MediaQuery.of(context).size.width / 2.5;
    double resize = size / 6;
    return Container(
      width: (number == "00") ? (resize * 2) : resize,
      padding: EdgeInsets.all(5),
      height: (number == "Enter") ? (resize * 2) : resize,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(color: Colors.grey)),
        child: Text(number,
            textAlign: TextAlign.center, style: Styles.blackBoldLarge()),
        textColor: Colors.black,
        color: Colors.grey[100],
        onPressed: f,
      ),
    );
  }

  Widget _backbutton(Function() f) {
    var size = MediaQuery.of(context).size.width / 2.5;
    double resize = size / 6;
    return Container(
      width: resize,
      padding: EdgeInsets.all(5),
      height: resize,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(color: Colors.grey)),
        child: Icon(
          Icons.backspace,
          color: Colors.black,
          size: 30,
        ),
        textColor: Colors.black,
        color: Colors.grey[100],
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
          Text(
            currentNumber,
            style: Styles.blackBoldLarge(),
          ),
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
              _button("Enter", () {
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
