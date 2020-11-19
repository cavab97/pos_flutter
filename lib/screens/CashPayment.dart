import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/theme/Sized_Config.dart';

class CashPaymentPage extends StatefulWidget {
  // Opning ammount popup
  CashPaymentPage({Key key, this.paymentType, this.ammountext, this.onEnter})
      : super(key: key);
  Function onEnter;
  final Payments paymentType;
  final double ammountext;

  @override
  _CashPaymentState createState() => _CashPaymentState();
}

class _CashPaymentState extends State<CashPaymentPage> {
  String currentNumber = "0";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      title: Stack(
        // popup header
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.safeBlockVertical * 5),
            height: SizeConfig.safeBlockVertical * 9,
            decoration: BoxDecoration(
                color: Colors.white, border: Border.all(color: Colors.black)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(widget.paymentType.name, style: Styles.communBlack()),
                Text(currentNumber, style: Styles.communBlack()),
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
    if (currentNumber != "0") {
      var currentnumber = currentNumber;
      if (currentnumber != null && currentnumber.length > 0) {
        currentnumber = currentnumber.substring(0, currentnumber.length - 1);
        if (currentnumber.length == 0) {
          currentnumber = "0";
        }
        setState(() {
          currentNumber = currentnumber;
        });
      } else {
        currentNumber = "0";
      }
    }
  }

  numberClick(val) {
    // add  value in prev value
    if (currentNumber.length <= 8) {
      var currentnumber = currentNumber;
      if (currentnumber == "0") {
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

  Widget mainContent() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: getNumbers(context),
    );
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
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.grey)),
        child: number != Strings.enter
            ? Text(number,
                textAlign: TextAlign.center, style: Styles.blackMediumBold())
            : Icon(Icons.subdirectory_arrow_left, size: 30),
        textColor: Colors.black,
        color: Colors.grey[100],
        onPressed: f,
      ),
    );
  }

  Widget _totalbutton(String number, Function() f) {
    var size = MediaQuery.of(context).size.width / 2.3;
    double resize = size / 6;
    return Container(
      width: (resize * 4),
      padding: EdgeInsets.all(SizeConfig.safeBlockVertical * 1),
      height: (number == Strings.enter) ? (resize * 2) : resize,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.grey)),
        child: number != Strings.enter
            ? Text(number,
                textAlign: TextAlign.center, style: Styles.blackMediumBold())
            : Icon(Icons.subdirectory_arrow_left, size: 30),
        textColor: Colors.black,
        color: Colors.grey[100],
        onPressed: f,
      ),
    );
  }

  Widget splshsButton(String number, Function() f) {
    var size = MediaQuery.of(context).size.width / 2.3;
    double resize = size / 6;
    return Expanded(
      child: Container(
        width: (number == "00") ? (resize * 2) : resize,
        padding: EdgeInsets.all(SizeConfig.safeBlockVertical * 1),
        height: (number == Strings.enter) ? (resize * 2) : resize,
        child: MaterialButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(color: Colors.grey)),
          child: number != Strings.enter
              ? Text(number,
                  textAlign: TextAlign.center, style: Styles.blackMediumBold())
              : Icon(Icons.subdirectory_arrow_left, size: 30),
          textColor: Colors.black,
          color: Colors.grey[100],
          onPressed: f,
        ),
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
            side: BorderSide(color: Colors.grey)),
        child: Icon(
          Icons.backspace,
          color: Colors.black,
          size: SizeConfig.safeBlockVertical * 4,
        ),
        textColor: Colors.black,
        color: Colors.grey[100],
        onPressed: f,
      ),
    );
  }

  Widget getNumbers(context) {
    return Container(
      height: MediaQuery.of(context).size.height / 1.6,
      width: MediaQuery.of(context).size.width / 1.5,
      child: Center(
          child: Table(
        border: TableBorder.all(color: Colors.white, width: 0.6),
        columnWidths: {
          0: FractionColumnWidth(.4),
          1: FractionColumnWidth(.5),
        },
        children: [
          TableRow(children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        splshsButton("10", () {
                          numberClick('10');
                        }), // using custom widget button
                        splshsButton("20", () {
                          numberClick('20');
                        }),
                      ],
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        splshsButton("40", () {
                          numberClick('40');
                        }), // using custom widget button
                        splshsButton("50", () {
                          numberClick('50');
                        }),
                      ],
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        splshsButton("100", () {
                          numberClick('100');
                        }), // using custom widget button
                        splshsButton("150", () {
                          numberClick('150');
                        }),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Row(
                      children: <Widget>[
                        Transform.scale(
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
                        SizedBox(
                          width: 20,
                        ),
                        Text(Strings.print_reciept)
                      ],
                    )
                  ]),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    _button(Strings.enter, () {
                      widget.onEnter(currentNumber);
                    })
                  ]),
                  Row(
                    children: <Widget>[
                      _totalbutton(widget.ammountext.toStringAsFixed(2), () {
                        widget.onEnter(widget.ammountext.toString());
                      }),
                    ],
                  ),
                ],
              ),
            )
          ])
        ],
      )),
    );
  }
}
