import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/colors.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';

class DiscountPad extends StatefulWidget {
  // Opning ammount popup
  DiscountPad(
      {Key key,
      this.seletedProduct,
      this.issetMeal,
      this.cartID,
      this.cartItem,
      this.onClose})
      : super(key: key);

  final bool issetMeal;
  final MSTCartdetails seletedProduct;
  final int cartID;
  final cartItem;
  Function onClose;

  @override
  _DiscountPadState createState() => _DiscountPadState();
}

class _DiscountPadState extends State<DiscountPad> {
  double paidAmount = 0;
  String currentNumber = "0";
  String currentDiscountType = "RM";
  LocalAPI localAPI = LocalAPI();
  double totalAmount = 0;
  TextEditingController extraNotes = new TextEditingController();
  FocusNode myFocusNode = FocusNode();
  bool validNotes = false;
  bool isEnter = false;
  @override
  void initState() {
    super.initState();
    setState(() {});
    currentNumber = totalAmount.toStringAsFixed(2);
    extraNotes.text = widget.seletedProduct.discountRemark ?? "";
    extraNotes.addListener(() {
      if (!isEnter) isEnter = true;
      if (!validNotes && extraNotes.text.trim().isNotEmpty && this.mounted) {
        setState(() {
          validNotes = true;
        });
      } else if (this.mounted &&
          extraNotes.text.trim().isEmpty &&
          extraNotes.text.length > 0) {
        setState(() {
          validNotes = false;
        });
      }
    });
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    if (myFocusNode != null) myFocusNode.dispose();

    super.dispose();
  }

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
                Text(
                  "Discount" + '',
                  style: Styles.communBlack(),
                ),
                // Text(
                //     currentDiscountType == "RM"
                //         ? currentDiscountType +
                //             CommunFun.getDecimalFormat(currentNumber)
                //         : CommunFun.getDecimalFormat(currentNumber) +
                //             currentDiscountType,
                //     style: Styles.communBlack()),
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
      String currentnumber = currentNumber
          .replaceAll('.', '')
          .replaceAll(new RegExp(r'^0+(?=.)'), '');
      currentnumber = currentnumber.substring(0, currentnumber.length - 1);
      if (currentnumber.length == 0 && this.mounted) {
        setState(() {
          currentNumber = "0.00";
        });
      } else if (currentnumber != null && currentnumber.length > 0) {
        switch (currentnumber.length) {
          case 1:
            currentnumber = "0.0" + currentnumber;
            break;
          case 2:
            currentnumber = "0." + currentnumber;
            break;
          default:
            String output = [
              currentnumber.substring(0, currentnumber.length - 2),
              ".",
              currentnumber.substring(currentnumber.length - 2)
            ].join("");
            currentnumber = output;
            break;
        }
        setState(() {
          currentNumber = currentnumber;
        });
      }
    }
  }

  clearClick() {
    if (this.mounted) {
      setState(() {
        currentNumber = "0.00";
      });
    }
  }

  numberClick(val) {
    // add  value in prev value

    String currentnumber = currentNumber
        .replaceAll('.', '')
        .replaceAll(new RegExp(r'^0+(?=.)'), '');
    currentnumber = currentnumber == "0" ? "" : currentnumber;
    switch (currentnumber.length + val.length) {
      case 1:
        if (currentnumber == "0" || currentnumber == "") {
          currentnumber = "0.0" + val;
        } else {
          currentnumber = "0." + currentnumber + val;
        }
        break;
      default:
        currentnumber += val;
        String output = [
          currentnumber.substring(0, currentnumber.length - 2),
          ".",
          currentnumber.substring(currentnumber.length - 2)
        ].join("");
        currentnumber = output;
        break;
    }
    double totalAmount = 0;
    if (widget.seletedProduct.discountType == 1) {
      totalAmount = widget.seletedProduct.productDetailAmount /
          (1 - (widget.seletedProduct.discountAmount / 100));
    } else {
      totalAmount = widget.seletedProduct.discountAmount +
          widget.seletedProduct.productDetailAmount;
    }
    if (currentDiscountType == "RM" &&
        double.tryParse(currentnumber) > totalAmount) {
      currentnumber = totalAmount.toString();
    } else if (currentDiscountType == "%" &&
        double.tryParse(currentnumber) > 100) {
      currentnumber = "100.00";
    }
    if (this.mounted && currentNumber != currentnumber) {
      setState(() {
        currentNumber = currentnumber;
      });
    }
  }

  setItemDiscount() async {
    if (extraNotes.text.isEmpty && this.mounted) {
      setState(() {
        isEnter = true;
      });
      if (myFocusNode != null) {
        myFocusNode.requestFocus();
      }
    } else {
      await localAPI.updateItemDiscount(widget.seletedProduct, widget.cartID,
          currentNumber, currentDiscountType, extraNotes.text.trim());
      Navigator.of(context).pop();
      widget.onClose();
    }
  }

  bool validateTextField(String userInput) {
    if (userInput == null || (userInput.isEmpty)) {
      return false;
    }
    return true;
  }

  dicsountTypeClick(val) {
    // add  value in prev value

    if (val == "RM") {
      setState(() {
        currentDiscountType = val;
        currentNumber = "0";
      });
    } else if (val == "%") {
      setState(() {
        currentDiscountType = val;
        currentNumber = "0";
      });
    }
  }

  Widget closeButton(context) {
    return Positioned(
      top: 0,
      right: 0,
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
    return getNumbers(context);
  }

  Widget _button(String number, Function() f) {
    var size = MediaQuery.of(context).size.width / 2.3;
    double resize = size / 6;
    return Container(
      width: (number == "00") || (number == "%") || (number == "Cash")
          ? (resize * 2)
          : resize,
      padding: EdgeInsets.all(SizeConfig.safeBlockVertical * 1),
      height: (number == Strings.enter) ? (resize * 2) : resize,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.grey)),
        child: number != Strings.enter
            ? Text(number,
                textAlign: TextAlign.center, style: Styles.blackMediumBold())
            : Icon(Icons.save, size: 30),
        textColor: Colors.white,
        color: number == Strings.enter
            ? Colors.green[900]
            : number == "Cash" && currentDiscountType == "RM"
                ? Colors.orange[200]
                : number == "%" && currentDiscountType == "%"
                    ? Colors.orange[200]
                    : Colors.grey[100],
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
                textAlign: TextAlign.center, style: Styles.whiteMediumBold())
            : Icon(
                Icons.subdirectory_arrow_left,
                size: 30,
                color: Colors.white,
              ),
        textColor: Colors.black,
        color: Colors.blue[900],
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

  Widget _clearbutton(String number, Function() f) {
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
        // child: Icon(
        //   Icons.highlight_remove_sharp,
        //   color: Colors.black,
        //   size: SizeConfig.safeBlockVertical * 4,
        // ),
        child: Text(number),
        textColor: Colors.black,
        color: Colors.grey[100],
        onPressed: f,
      ),
    );
  }

  Widget getNumbers(context) {
    return Container(
      // height: MediaQuery.of(context).size.height / 1.2,
      width: MediaQuery.of(context).size.width * .6,
      child: SingleChildScrollView(
          child: Table(
        border: TableBorder.all(color: Colors.white, width: 0.6),
        columnWidths: {
          0: FractionColumnWidth(.4),
          1: FractionColumnWidth(.5),
        },
        children: [
          TableRow(children: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 1),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: RichText(
                          maxLines: 4,
                          text: TextSpan(
                              text: "Amount",
                              style: TextStyle(
                                  color: Color(0xFF000000),
                                  fontSize: SizeConfig.safeBlockVertical * 3,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: Strings.fontFamily),
                              children: <TextSpan>[
                                TextSpan(
                                  text: currentDiscountType == "RM"
                                      ? "\n" +
                                          currentDiscountType +
                                          double.parse(currentNumber)
                                              .toStringAsFixed(2)
                                      : "\n" +
                                          double.parse(currentNumber)
                                              .toStringAsFixed(2) +
                                          currentDiscountType,
                                  style: TextStyle(
                                      color: Color(0xFF0D47A1),
                                      fontSize:
                                          SizeConfig.safeBlockVertical * 4,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: Strings.fontFamily),
                                )
                              ])),
                    ),
                    SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _extraNotesTitle(),
                    ),
                    SizedBox(height: 5),
                    inputNotesView()
                  ],
                )),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          _button("Cash", () {
                            dicsountTypeClick('RM');
                          }), // using custom widget button
                          _button("%", () {
                            dicsountTypeClick('%');
                          }),
                        ],
                      ),
                    ],
                  ),
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
                      _clearbutton("CLR", () {
                        clearClick();
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
                    _button(Strings.enter, setItemDiscount),
                  ]),
                ],
              ),
            )
          ])
        ],
      )),
    );
  }

  Widget notesInput() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
            border: isEnter && !validNotes
                ? Border.all(color: Colors.red)
                : Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10)),
        height: 200,
        padding: EdgeInsets.all(10),
        child: TextField(
          focusNode: myFocusNode,
          controller: extraNotes,
          keyboardType: TextInputType.multiline,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
              fontSize: SizeConfig.safeBlockVertical * 3, height: 1.2),
          maxLines: 10,
          // decoration: new InputDecoration(
          //   border: OutlineInputBorder(
          //     borderSide: BorderSide(color: Colors.greenAccent, width: 100.0),
          //   ),
          //   // hintText: product_qty.toDouble().toString(),
          // ),
          decoration: new InputDecoration(
              border: InputBorder.none,
              errorText: isEnter && !validNotes
                  ? "Please enter notes for this discount"
                  : null
              // hintText: product_qty.toDouble().toString(),
              ),
          onChanged: (val) {},
        ),
      ),
    );
  }

  Widget inputNotesView() {
    return Container(
        padding: EdgeInsets.all(0),
        //height: 170, // MediaQuery.of(context).size.height / 4,
        width: MediaQuery.of(context).size.width,
        child: Card(
          color: StaticColor.lightGrey100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[notesInput()],
          ),
        ));
  }

  Widget _extraNotesTitle() {
    return Text(
      Strings.notesAndQty,
      style: TextStyle(
          fontSize: SizeConfig.safeBlockVertical * 3,
          fontWeight: FontWeight.w400,
          color: StaticColor.colorGrey800),
    );
  }
}
