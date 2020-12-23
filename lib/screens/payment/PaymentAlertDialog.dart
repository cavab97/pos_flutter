import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/colors.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:mcncashier/screens/SubPaymentMethodPop.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/screens/FinalPaymentScreen.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'ShowEnterCardDetailPop.dart';
import 'ShowEnterEwalletDetailPop.dart';

class PaymentAlertDialog extends StatefulWidget {
  // Opning ammount popup
  PaymentAlertDialog({Key key, this.totalAmount, this.onClose})
      : super(key: key);
  Function onClose;
  final double totalAmount;

  @override
  _PaymentAlertDialogState createState() => _PaymentAlertDialogState();
}

class _PaymentAlertDialogState extends State<PaymentAlertDialog> {
  double paidAmount = 0;
  List<OrderPayment> totalPaymentList = [];
  OrderPayment currentPayment = new OrderPayment();
  String currentNumber = "0";
  bool isSubPayment = false;
  bool isPaymented = false;
  List<Payments> mainPaymentList = [];
  LocalAPI localAPI = LocalAPI();
  Payments seletedPayment = new Payments();
  List<Widget> paymentListTile = [];
  List<Payments> subPaymenttyppeList = [];

  @override
  void initState() {
    super.initState();
    setState(() {});
    getPaymentMethods();
    currentNumber = widget.totalAmount.toStringAsFixed(2);
  }

  getPaymentMethods() async {
    var result = await localAPI.getPaymentMethods();

    if (result.length != 0) {
      setState(() {
        mainPaymentList = result.where((i) => i.isParent == 0).toList();
        subPaymenttyppeList = result.toList();
      });
    }
  }

  List<Widget> setPaymentListTile(List<Payments> listTilePaymentType) {
    var size = MediaQuery.of(context).size.width / 2.0;
    return listTilePaymentType.map((payment) {
      if (payment.name.toUpperCase() == "CASH") {
        if (this.mounted) {
          seletedPayment = payment;
        }
      }
      return MaterialButton(
          minWidth: (size / 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.grey),
          ),
          child: Text(payment.name, style: Styles.blackMediumBold()),
          textColor: Colors.black,
          color:
              seletedPayment == payment ? Colors.orange[200] : Colors.grey[100],
          onPressed: () {
            seletedPayment = payment;
            List<Payments> subList = subPaymenttyppeList
                .where((i) => i.isParent == payment.paymentId)
                .toList();
            if (subList.length > 0) {
              openSubPaymentDialog(subList);
              //subPaymenttyppeList = subList;
              /* setState(() {
                isSubPayment = true;
              }); */
            } else if (this.mounted) {
              setState(() {
                seletedPayment = payment;
              });
              //insertPaymentOption(payment);
              //select payment
            }
          });
    }).toList();
  }

  openSubPaymentDialog(List<Payments> subList) {
    showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return SubPaymentMethodPop(
            subList: subList,
            subTotal: widget.totalAmount,
            grandTotal: widget.totalAmount,
            onClose: (mehtod) {
              Navigator.of(context).pop();
              insertPaymentOption(mehtod);
            },
          );
        });
  }

  insertPaymentOption(Payments payment) {
    if (seletedPayment.name == null) return;
    if (seletedPayment.name.toLowerCase().contains("wallet")) {
      setState(() {
        seletedPayment = payment;
      });
      showEwalletOptionPop();
    } else if (seletedPayment.name.toLowerCase().contains("card")) {
      setState(() {
        seletedPayment = payment;
      });
      showCardOptionPop();
    } else {
      //cashPayment(payment);
    }
  }

  showEwalletOptionPop() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return ShowEnterEwalletDetailPop(currentPayment: currentPayment);
      },
    );
  }

  showCardOptionPop() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return ShowEnterCardDetailPop(currentPayment: currentPayment);
      },
    );
  }

  List<Widget> subPaymentListTile(List<Payments> listTilePaymentType) {
    List<Widget> returnList = [];
    returnList += [
      MaterialButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(color: Colors.grey)),
          child: Icon(Icons.arrow_back),
          textColor: Colors.black,
          color: Colors.grey[100],
          onPressed: () {
            setState(() {
              isSubPayment = false;
            });
          }),
    ];
    returnList += listTilePaymentType.map((payment) {
      if (payment.name.toUpperCase() == "CASH") return SizedBox();
      return MaterialButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(color: Colors.grey)),
          child: Text(payment.name, style: Styles.blackMediumBold()),
          textColor: Colors.black,
          color: Colors.grey[100],
          onPressed: () {
            seletedPayment = payment;
            List<Payments> subList = mainPaymentList
                .where((i) => i.isParent == payment.paymentId)
                .toList();
            if (subList.length > 0) {
              subPaymenttyppeList = subList;
            } else {
              seletedPayment = payment;
              //select payment
            }
          });
    }).toList();
    return returnList;
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
                    "Paid" +
                        (seletedPayment.name != null
                            ? ' (' + seletedPayment.name + ')'
                            : ''),
                    style: Styles.communBlack()),
                Text(CommunFun.getDecimalFormat(currentNumber),
                    style: Styles.communBlack()),
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
    return getNumbers(context);
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
        textColor: Colors.white,
        color: number == Strings.enter ? Colors.green[900] : Colors.grey[100],
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

  Widget getNumbers(context) {
    return Container(
      height: MediaQuery.of(context).size.height / 1.2,
      width: MediaQuery.of(context).size.width * .8,
      child: Center(
          child: Table(
        border: TableBorder.all(color: Colors.white, width: 0.6),
        columnWidths: {
          0: FractionColumnWidth(.15),
          1: FractionColumnWidth(.2),
          2: FractionColumnWidth(.2),
          3: FractionColumnWidth(.6),
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
                        text: TextSpan(
                            text: "Total",
                            style: Styles.blueMediumBold(),
                            children: <TextSpan>[
                          TextSpan(
                              text:
                                  "\n" + widget.totalAmount.toStringAsFixed(2),
                              style: TextStyle(fontSize: 30))
                        ])),
                  ),
                  // Text(
                  //   widget.totalAmount.toStringAsFixed(2),
                  //   style: Styles.blackLarge(),
                  // ),
                  SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    child: RichText(
                        text: TextSpan(
                            text: "Amount Paid",
                            style: Styles.greenMediumBold(),
                            children: <TextSpan>[
                          TextSpan(
                              text: "\n" + (paidAmount).toStringAsFixed(2),
                              style: TextStyle(fontSize: 30))
                        ])),
                  ),
                  // Text(
                  //   (paidAmount).toStringAsFixed(2),
                  //   style: Styles.blackLarge(),
                  // ),
                  SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    child: RichText(
                        text: TextSpan(
                            text: "Remaining",
                            style: Styles.redMediumBold(),
                            children: <TextSpan>[
                          TextSpan(
                              text: "\n" +
                                  (widget.totalAmount - paidAmount)
                                      .toStringAsFixed(2),
                              style: TextStyle(fontSize: 30))
                        ])),
                  ),
                  // Text(
                  //   (widget.totalAmount - paidAmount).toStringAsFixed(2),
                  //   style: Styles.blackLarge(),
                  // ),
                  /* SizedBox(height: 15),
                  Text('PaymentList :', style: Styles.blackMediumBold()),
                  Text(
                    widget.totalAmount.toStringAsFixed(2),
                    style: Styles.blackMediumBold(),
                  ), */
                ],
              ),
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: mainPaymentList.length > 0
                      ? (isSubPayment
                          ? subPaymentListTile(subPaymenttyppeList)
                          : setPaymentListTile(mainPaymentList))
                      : [],
                )),
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
                      ],
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        splshsButton("20", () {
                          numberClick('20');
                        }), // using custom widget button
                      ],
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        // using custom widget button
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
                          }), //
                        ]),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        // using custom widget button
                        splshsButton("150", () {
                          numberClick('150');
                        }),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
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
                      //paidAmount = widget.totalAmount;
                      double currentPaidAmount =
                          CommunFun.getDecimalFormat(currentNumber);
                      if (currentPaidAmount < 0.01) return;
                      if (seletedPayment.paymentId == null) {
                        return CommunFun.showToast(
                            context, Strings.selectPayment);
                      }
                      if (!isPaymented && this.mounted) {
                        setState(() {
                          currentPayment.op_amount = currentPaidAmount;
                          currentPayment.op_method_id =
                              seletedPayment.paymentId;
                          totalPaymentList.add(currentPayment);
                          paidAmount += currentPaidAmount;
                          seletedPayment = new Payments();
                          currentPayment = new OrderPayment();
                        });
                      }
                      if (paidAmount < (widget.totalAmount) && this.mounted) {
                        setState(() {
                          isPaymented = false;
                          currentNumber = "0";
                        });
                      } else {
                        isPaymented = true;
                        finalPayment();
                      }
                      //widget.onEnter(currentNumber);
                    })
                  ]),
                  Row(
                    children: <Widget>[
                      _totalbutton(
                          (widget.totalAmount - paidAmount).toStringAsFixed(2),
                          () {
                        if (!isPaymented && this.mounted) {
                          setState(() {
                            double currentPaidAmount =
                                (widget.totalAmount - paidAmount);
                            currentPayment.op_amount = currentPaidAmount;
                            currentPayment.op_method_id =
                                seletedPayment.paymentId;
                            totalPaymentList.add(currentPayment);
                            paidAmount += currentPaidAmount;
                            seletedPayment = new Payments();
                            currentPayment = new OrderPayment();
                          });
                        }
                        finalPayment();
                        //widget.onEnter(widget.totalAmount.toString());
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

  finalPayment() async {
    //List<OrderPayment> totalPayment = [];
    double change = paidAmount - widget.totalAmount;
    if (!(paidAmount >= (widget.totalAmount)) &&
        (seletedPayment.paymentId == null ||
            totalPaymentList[0].op_amount == 0.00)) {
      return CommunFun.showToast(context, Strings.selectPayment);
    }
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return FinalEndScreen(
              total: widget.totalAmount,
              totalPaid: paidAmount,
              change: change,
              onClose: () {
                Navigator.of(context).pop();
                widget.onClose(totalPaymentList);
              });
        });
  }
}
