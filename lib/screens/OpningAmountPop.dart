import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';

class OpeningAmmountPage extends StatefulWidget {
  // Opning ammount popup
  OpeningAmmountPage({Key key, this.onEnter}) : super(key: key);
  Function onEnter;
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
                Text(Strings.title_opening_amount.toUpperCase(),
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
    // Creating a method of return type Widget with number and function f as a parameter
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(color: Colors.black, width: 3.0)),
        height: MediaQuery.of(context).size.height / 9.7,
        //minWidth: MediaQuery.of(context).size.width / 9.9,
        child: Text(number,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40.0)),
        textColor: Colors.black,
        color: Colors.white,
        onPressed: f,
      ),
    );
  }

  Widget _backbutton(Function() f) {
    // Creating a method of return type Widget with number and function f as a parameter
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(color: Colors.black, width: 3.0)),
        height: MediaQuery.of(context).size.height / 9.7,
        // minWidth: MediaQuery.of(context).size.width / 9.9,
        child: Icon(
          Icons.backspace,
          color: Colors.black,
          size: 40,
        ),
        textColor: Colors.black,
        color: Colors.white,
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
          Text(currentNumber,
              style: TextStyle(
                  fontSize: 60,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          /*Flexible(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              strutStyle:
                  StrutStyle(fontSize: 90.0, fontWeight: FontWeight.bold),
              text: TextSpan(
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 90,
                      fontWeight: FontWeight.bold),
                  text: currentNumber),
            ),*/
          // )
        ],
      ),
    );
  }

  Widget getNumbers(context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width / 2.5,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    //mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(left: 20, top: 10),
                              child: _button("7", () {
                                numberClick('7');
                              })),
                          // using custom widget button
                          Padding(
                              padding: EdgeInsets.only(left: 30, top: 10),
                              child: _button("8", () {
                                numberClick('8');
                              })),
                          Padding(
                              padding: EdgeInsets.only(left: 30, top: 10),
                              child: _button("9", () {
                                numberClick('9');
                              })),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(left: 20, top: 10),
                              child: _button("0", () {
                                numberClick('0');
                              })),
                          Padding(
                            padding: EdgeInsets.only(left: 25, top: 10),
                            child: MaterialButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(
                                      color: Colors.black, width: 3.0)),
                              height: MediaQuery.of(context).size.height / 9.5,
                              minWidth: MediaQuery.of(context).size.width / 6.1,
                              child: Text("00".toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 40.0)),
                              textColor: Colors.black,
                              color: Colors.white,
                              onPressed: () {
                                numberClick('00');
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.black, width: 3.0)),
                      height: MediaQuery.of(context).size.height / 4.2,
                      // minWidth: MediaQuery.of(context).size.width / 9.9
                      minWidth: 50,
                      child: Text("enter".toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0)),
                      textColor: Colors.black,
                      color: Colors.white,
                      onPressed: () {
                        widget.onEnter(currentNumber);
                        Navigator.of(context).pop();
                      },
                    ),
                  )
                ]),
          ],
        ),
      ),
    );
  }
}
