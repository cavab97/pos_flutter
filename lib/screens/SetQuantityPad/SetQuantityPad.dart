import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/colors.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/services/LocalAPIs.dart';

class SetQuantityPad extends StatefulWidget {
  // Opning ammount popup
  SetQuantityPad(
      {Key key,
      this.selproduct,
      this.issetMeal,
      this.cartID,
      this.cartItem,
      this.onClose})
      : super(key: key);

  final bool issetMeal;
  final selproduct;
  final int cartID;
  final cartItem;
  Function onClose;

  @override
  _SetQuantityPadState createState() => _SetQuantityPadState();
}

class _SetQuantityPadState extends State<SetQuantityPad> {
  double paidAmount = 0;
  List<OrderPayment> totalPaymentList = [];
  OrderPayment currentPayment = new OrderPayment();
  String currentNumber = "0";
  String currentDiscountType = "RM";
  bool isSubPayment = false;
  bool isPaymented = false;
  List<Payments> mainPaymentList = [];
  LocalAPI localAPI = LocalAPI();
  Payments seletedPayment = new Payments();
  List<Widget> paymentListTile = [];
  List<Payments> subPaymenttyppeList = [];
  int totalQuantity = 0;
  TextEditingController extraNotes = new TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {});
    currentNumber = totalQuantity.toString();
  }

  // List<Widget> setPaymentListTile(List<Payments> listTilePaymentType) {
  //   var size = MediaQuery.of(context).size.width / 2.0;
  //   return listTilePaymentType.map((payment) {
  //     if (payment.name.toUpperCase() == "CASH") {
  //       if (this.mounted) {
  //         seletedPayment = payment;
  //       }
  //     }
  //     return MaterialButton(
  //         minWidth: (size / 3),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10.0),
  //           side: BorderSide(color: Colors.grey),
  //         ),
  //         child: Text(payment.name, style: Styles.blackMediumBold()),
  //         textColor: Colors.black,
  //         color:
  //             seletedPayment == payment ? Colors.orange[200] : Colors.grey[100],
  //         onPressed: () {
  //           seletedPayment = payment;
  //           List<Payments> subList = subPaymenttyppeList
  //               .where((i) => i.isParent == payment.paymentId)
  //               .toList();
  //           if (subList.length > 0) {
  //             openSubPaymentDialog(subList);
  //             //subPaymenttyppeList = subList;
  //             /* setState(() {
  //               isSubPayment = true;
  //             }); */
  //           } else if (this.mounted) {
  //             setState(() {
  //               seletedPayment = payment;
  //             });
  //             //insertPaymentOption(payment);
  //             //select payment
  //           }
  //         });
  //   }).toList();
  // }

  // openSubPaymentDialog(List<Payments> subList) {
  //   showDialog(
  //       // Opning Ammount Popup
  //       context: context,
  //       builder: (BuildContext context) {
  //         return SubPaymentMethodPop(
  //           subList: subList,
  //           subTotal: totalAmount,
  //           grandTotal: totalAmount,
  //           onClose: (mehtod) {
  //             Navigator.of(context).pop();
  //             // insertPaymentOption(mehtod);
  //           },
  //         );
  //       });
  // }

  // List<Widget> subPaymentListTile(List<Payments> listTilePaymentType) {
  //   List<Widget> returnList = [];
  //   returnList += [
  //     MaterialButton(
  //         shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10.0),
  //             side: BorderSide(color: Colors.grey)),
  //         child: Icon(Icons.arrow_back),
  //         textColor: Colors.black,
  //         color: Colors.grey[100],
  //         onPressed: () {
  //           setState(() {
  //             isSubPayment = false;
  //           });
  //         }),
  //   ];
  //   returnList += listTilePaymentType.map((payment) {
  //     if (payment.name.toUpperCase() == "CASH") return SizedBox();
  //     return MaterialButton(
  //         shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10.0),
  //             side: BorderSide(color: Colors.grey)),
  //         child: Text(payment.name, style: Styles.blackMediumBold()),
  //         textColor: Colors.black,
  //         color: Colors.grey[100],
  //         onPressed: () {
  //           seletedPayment = payment;
  //           List<Payments> subList = mainPaymentList
  //               .where((i) => i.isParent == payment.paymentId)
  //               .toList();
  //           if (subList.length > 0) {
  //             subPaymenttyppeList = subList;
  //           } else {
  //             seletedPayment = payment;
  //             //select payment
  //           }
  //         });
  //   }).toList();
  //   return returnList;
  // }

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
                    "Quantity" +
                        (seletedPayment.name != null
                            ? ' (' + seletedPayment.name + ')'
                            : ''),
                    style: Styles.communBlack()),
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

  clearClick() {
    setState(() {
      currentNumber = "0";
    });
  }

  numberClick(val) {
    // add  value in prev value
    int limit = currentDiscountType == "%" ? 3 : 8;

    if (currentNumber.length <= limit) {
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

  submitQuantity(val) {
    print(val);
  }

  // dicsountTypeClick(val) {
  //   // add  value in prev value

  //   if (val == "RM") {
  //     setState(() {
  //       currentDiscountType = val;
  //       currentNumber = "0";
  //     });
  //   } else if (val == "%") {
  //     setState(() {
  //       currentDiscountType = val;
  //       currentNumber = "0";
  //     });
  //   }
  // }

  Widget closeButton(context) {
    return Positioned(
      top: 10,
      right: 10,
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
      width: (number == "0") ? (resize * 3) : resize,
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
      width: MediaQuery.of(context).size.width * .4,
      child: SingleChildScrollView(
          child: Table(
        border: TableBorder.all(color: Colors.white, width: 0.6),
        columnWidths: {
          0: FractionColumnWidth(.0),
          1: FractionColumnWidth(.7),
        },
        children: [
          TableRow(children: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 1),
                child: Column(
                  children: [],
                )),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 00),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _totalbutton("x " + currentNumber, () {}),
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
                          ],
                        ),
                      ],
                    ),
                    _button(Strings.enter, () {
                      submitQuantity(currentNumber);
                    }),
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
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10)),
        height: 200,
        padding: EdgeInsets.all(10),
        child: TextField(
          controller: extraNotes,
          keyboardType: TextInputType.multiline,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
              fontSize: SizeConfig.safeBlockVertical * 3, height: 1.2),
          maxLines: 10,
          decoration: new InputDecoration(
            border: InputBorder.none,
          ),
          onChanged: (val) {},
        ),
      ),
    );
  }

  Widget inputNotesView() {
    return Container(
        padding: EdgeInsets.all(0),
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
        child: Text(number,
            textAlign: TextAlign.center, style: Styles.whiteMediumBold()),
        textColor: Colors.black,
        color: Colors.blue[900],
        onPressed: f,
      ),
    );
  }
}
