import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/services/allTablesSync.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:mcncashier/screens/SubPaymentMethodPop.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/BranchTax.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/screens/FinalPaymentScreen.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'ShowEnterCardDetailPop.dart';
import 'ShowEnterEwalletDetailPop.dart';
import 'package:mcncashier/models/Voucher.dart';
import 'package:mcncashier/widget/CloseButtonWidget.dart';

class PaymentAlertDialog extends StatefulWidget {
  // Opning ammount popup
  PaymentAlertDialog(
      {Key key,
      this.totalAmount,
      this.selectedVoucher,
      this.voucherFunction,
      this.removeVoucherFunction,
      this.applyDiscount,
      this.permissions,
      this.currentCartID,
      this.currentCartDetail,
      this.taxlists,
      this.onClose})
      : super(key: key);
  Function onClose;
  final Function voucherFunction;
  final Function removeVoucherFunction;
  final Function applyDiscount;
  final double totalAmount;
  final Voucher selectedVoucher;
  final int currentCartID;
  final List<MSTCartdetails> currentCartDetail;
  final List<BranchTax> taxlists;

  final permissions;

  @override
  _PaymentAlertDialogState createState() => _PaymentAlertDialogState();
}

class _PaymentAlertDialogState extends State<PaymentAlertDialog> {
  double totalNeedPaid = 0;
  double paidAmount = 0;
  List<OrderPayment> totalPaymentList = [];
  Voucher selectedvoucher;
  OrderPayment currentPayment = new OrderPayment();
  String currentNumber = "0";
  bool isSubPayment = false;
  bool isPaymented = false;
  bool isCounting = false;
  List<Payments> mainPaymentList = [];
  LocalAPI localAPI = LocalAPI();
  Payments seletedPayment = new Payments();
  List<Widget> paymentListTile = [];
  List<Payments> subPaymenttyppeList = [];
  bool isPausePrint = false;
  Payments initPayment;
  List walletList = [
    "ewallet",
    "e-wallet",
    "e wallet",
    "ipay88",
    "i-pay88",
    "i pay88",
    "i-pay 88",
    "i pay 88"
  ];
  @override
  void initState() {
    super.initState();
    setState(() {});
    getPaymentMethods();
    checkIsPausePrint();
    totalNeedPaid = widget.totalAmount;
    currentNumber = widget.totalAmount.toStringAsFixed(2);
  }

  checkIsPausePrint() async {
    String isOn = await Preferences.getStringValuesSF(Constant.isPausePrint);
    setState(() {
      isPausePrint = isOn != null ? false : true;
    });
  }

  setPausePrint(isOn) async {
    setState(() {
      isPausePrint = isOn;
    });
    if (isOn) {
      await Preferences.removeSinglePref(Constant.isPausePrint);
      await SyncAPICalls.logActivity(
          "Settings", "auto sync Enabled", "setting", 1);
    } else {
      await Preferences.setStringToSF(Constant.isPausePrint, isOn.toString());
      await SyncAPICalls.logActivity(
          "Settings", "auto sync disabled", "setting", 1);
    }
  }

  getPaymentMethods() async {
    var result = await localAPI.getPaymentMethods();
    if (result.length != 0) {
      setState(() {
        mainPaymentList = result.where((i) => i.isParent == 0).toList();
        subPaymenttyppeList = result.toList();
        Payments gotCash = mainPaymentList.firstWhere(
                (element) => element.name.toUpperCase() == "CASH",
                orElse: () => null) ??
            new Payments();
        if (gotCash.paymentId != null &&
            gotCash.paymentId > 0 &&
            this.mounted) {
          setState(() {
            seletedPayment = gotCash;
            initPayment = gotCash;
          });
        }
      });
    }
    await SyncAPICalls.logActivity(
        "payment", "Opened payment types popup for order place", "payment", 1);
  }

  List<Widget> setPaymentListTile(List<Payments> listTilePaymentType) {
    var size = MediaQuery.of(context).size.width / 2.0;
    return listTilePaymentType.map((payment) {
      return MaterialButton(
          minWidth: (size / 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.grey),
          ),
          child: Text(
            payment.name,
            style: Styles.blackMediumBold(),
            textAlign: TextAlign.center,
          ),
          textColor: Colors.black,
          color: seletedPayment == payment ||
                  (seletedPayment.isParent != null &&
                      seletedPayment.isParent > 0 &&
                      seletedPayment.isParent == payment.paymentId)
              ? Colors.orange[200]
              : Colors.grey[100],
          onPressed: () async {
            if (this.mounted) {
              setState(() {
                seletedPayment = payment;
              });
            }
            List<Payments> subList = subPaymenttyppeList
                .where((i) => i.isParent == payment.paymentId)
                .toList();
            await SyncAPICalls.logActivity(
                "payment",
                "Cashier selected payment type " +
                    seletedPayment.name.toString(),
                "payment",
                1);
            if (subList.length > 0) {
              openSubPaymentDialog(subList);

              //subPaymenttyppeList = subList;
              /* setState(() {
                isSubPayment = true;
              }); */
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
            subTotal: totalNeedPaid,
            grandTotal: totalNeedPaid,
            onClose: (mehtod) {
              Navigator.of(context).pop();
              insertPaymentOption(mehtod);
            },
          );
        });
  }

  insertPaymentOption(Payments payment) async {
    /* insertPaymentOption(Payments payment) { */
    if (seletedPayment.name == null) return;
    if (walletList.contains(seletedPayment.name.toLowerCase())) {
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
    await SyncAPICalls.logActivity(
        "payment",
        "Cashier selected payment option " + seletedPayment.name.toString(),
        "payment",
        1);
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

  clearClick() {
    if (this.mounted) {
      setState(() {
        currentNumber = "0.00";
      });
    }
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
      titlePadding: EdgeInsets.zero,
      title: Stack(
        // popup header
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            /* padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.safeBlockVertical * 5), */
            height: SizeConfig.safeBlockVertical * 9,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.black),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          style: Styles.communBlack(),
                        ),
                        Text(
                          totalNeedPaid.toStringAsFixed(2),
                          style: TextStyle(fontSize: 30),
                        ),
                      ],
                    ),
                    color: Colors.yellow[200],
                  ),
                  flex: 3,
                ),
                Expanded(
                  child: Container(
                    height: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Text(
                          "Amount Paid" +
                              (seletedPayment.name != null
                                  ? ' (' +
                                      (seletedPayment.name.length > 17
                                          ? seletedPayment.name
                                                  .substring(0, 17) +
                                              '...'
                                          : seletedPayment.name) +
                                      ')'
                                  : ''),
                          style: Styles.communBlack(),
                        ),
                        Spacer(),
                        Text(
                          CommunFun.getDecimalFormat(currentNumber),
                          style: Styles.communBlack(),
                        ),
                        SizedBox(width: 20)
                      ],
                    ),
                    color: Colors.green[200],
                  ),
                  flex: 4,
                ),
                /* 
                SizedBox(width: 10),
                Text(
                  '|',
                  style: Styles.communBlack(),
                ),
                SizedBox(width: 10),
                Text(
                  "Paid" +
                      (seletedPayment.name != null
                          ? ' (' + seletedPayment.name + ')'
                          : ''),
                  style: Styles.communBlack(),
                ),
                Spacer(),
                Text(
                  CommunFun.getDecimalFormat(currentNumber),
                  style: Styles.communBlack(),
                ), */
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
      String currentnumber =
          currentNumber.replaceAll('.', '').replaceAll("^0+", "");
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

  numberClick(val) {
    // add  value in prev value

    String currentnumber =
        currentNumber.replaceAll('.', '').replaceAll("^0+", "");
    currentnumber = currentnumber == "0" ? "" : currentnumber;
    if (val.length > 3) {
      currentnumber = val;
    } else {
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
    }
    /* double totalAmount = totalNeedPaid ?? 0;
    if (double.tryParse(currentnumber) > totalAmount) {
      currentnumber = totalAmount.toString();
    } */
    if (this.mounted && currentNumber != currentnumber) {
      setState(() {
        currentNumber = currentnumber;
      });
    }
  }

  Widget closeButton(context) {
    return Positioned(
      top: -30,
      right: -20,
      child: CloseButtonWidget(
        inputContext: context,
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
        textColor: isCounting ? Colors.black : Colors.white,
        color: number == Strings.enter ? Colors.green[900] : Colors.grey[100],
        disabledColor: Colors.grey[100],
        onPressed: isCounting ? null : f,
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
            : Icon(
                Icons.subdirectory_arrow_left,
                size: 30,
                color: Colors.white,
              ),
        textColor: isCounting ? Colors.black : Colors.white,
        color: Colors.grey[100],
        disabledColor: Colors.grey[100],
        onPressed: isPaymented || isCounting ? null : f,
      ),
    );
  }

  Widget discountButton(String number, Icon iconInput, Function() f) {
    double unitHeightValue = MediaQuery.of(context).size.height * 0.01;
    double multiplier = 1.4 * unitHeightValue;
    return Container(
      padding: EdgeInsets.all(SizeConfig.safeBlockVertical * 1),
      height: MediaQuery.of(context).size.height * .1,
      width: MediaQuery.of(context).size.width * .128,
      child: RaisedButton.icon(
        icon: iconInput,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.grey)),
        label: Text(number, style: TextStyle(fontSize: multiplier)),
        textColor: Colors.black,
        color: Colors.grey[100],
        onPressed: f,
      ),
    );
  }

  Widget splshsButton(String number, Function() f) {
    var size = MediaQuery.of(context).size.width / 2.3;
    double resize = size / 6;
    return Container(
      padding: EdgeInsets.all(SizeConfig.safeBlockVertical * 1),
      height: resize,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.grey)),
        child: number != Strings.enter
            ? Text(number, style: Styles.blackMediumBold())
            : Icon(Icons.subdirectory_arrow_left, size: 30),
        textColor: Colors.black,
        color: Colors.grey[100],
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

  List<TableRow> paymentList() {
    return totalPaymentList.map(
      (payment) {
        Payments currentPayment = subPaymenttyppeList
            .firstWhere((ele) => ele.paymentId == payment.op_method_id);
        return TableRow(
          children: [
            Text(currentPayment.name),
            Text(payment.op_amount.toStringAsFixed(2),
                style: Styles.greenMediumBold()),
            Icon(
              Icons.close,
              color: Colors.red,
            ),
          ],
        );
      },
    ).toList();
  }

  Widget getNumbers(context) {
    return Stack(children: [
      Container(
        height: MediaQuery.of(context).size.height / 1.2,
        width: MediaQuery.of(context).size.width * .8,
        child: Center(
            child: Table(
          border: TableBorder.all(color: Colors.white, width: 0.6),
          columnWidths: {
            0: FractionColumnWidth(.3),
            1: FractionColumnWidth(.2),
            2: FractionColumnWidth(.11),
            3: FractionColumnWidth(.6),
          },
          children: [
            TableRow(children: [
              Container(
                height: MediaQuery.of(context).size.height / 1.5,
                padding: EdgeInsets.symmetric(horizontal: 1),
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 1.5 * .35,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width:
                                (MediaQuery.of(context).size.width * .8 * .27) *
                                    .4,
                            child: Column(
                              children: [
                                /* Container(
                                  width: double.infinity,
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Total",
                                      style: Styles.blueMediumBold(),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: "\n" +
                                                totalNeedPaid.toStringAsFixed(2),
                                            style: TextStyle(fontSize: 30))
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15), */
                                Container(
                                  width: double.infinity,
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Amount Paid",
                                      style: Styles.greenMediumBold(),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: "\n" +
                                                (paidAmount).toStringAsFixed(2),
                                            style: TextStyle(fontSize: 30))
                                      ],
                                    ),
                                  ),
                                ),
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
                                                (totalNeedPaid - paidAmount)
                                                    .toStringAsFixed(2),
                                            style: TextStyle(fontSize: 30))
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              discountButton(
                                Strings.totalDiscount,
                                Icon(
                                  FontAwesomeIcons.percentage,
                                  color: Colors.black,
                                ),
                                () async {
                                  setState(() {
                                    isCounting = true;
                                  });
                                  await SyncAPICalls.logActivity(
                                      "Order Payment",
                                      "Apply Discount click",
                                      "Payment Screen",
                                      1);
                                  Function discountAction = () =>
                                      widget.applyDiscount(
                                        ([MST_Cart updateCartData]) {
                                          if (updateCartData != null) {
                                            print(updateCartData.grand_total);
                                            setState(() {
                                              totalNeedPaid =
                                                  updateCartData.grand_total;
                                              currentNumber = updateCartData
                                                  .grand_total
                                                  .toStringAsFixed(2);
                                            });
                                          }
                                          setState(() {
                                            isCounting = false;
                                          });
                                        },
                                      );
                                  if (widget.permissions
                                      .contains(Constant.DISCOUNT_ORDER)) {
                                    discountAction();
                                  } else {
                                    CommonUtils.openPermissionPop(
                                        context, Constant.DISCOUNT_ORDER, () {
                                      discountAction();
                                    }, () {});
                                  }
                                },
                              ),
                              discountButton(
                                selectedvoucher == null
                                    ? Strings.applyPromocode
                                    : Strings.removePromocode,
                                Icon(selectedvoucher == null
                                    ? FontAwesomeIcons.gift
                                    : Icons.remove_circle_outline),
                                () {
                                  setState(() {
                                    isCounting = true;
                                  });
                                  if (selectedvoucher != null) {
                                    CommonUtils.showAlertDialog(
                                      context,
                                      () {
                                        Navigator.of(context).pop();
                                      },
                                      () {
                                        widget.removeVoucherFunction(
                                          selectedvoucher,
                                          (MST_Cart updateCartData) {
                                            setState(() {
                                              totalNeedPaid =
                                                  updateCartData.grand_total;
                                              currentNumber = updateCartData
                                                  .grand_total
                                                  .toStringAsFixed(2);
                                              selectedvoucher = null;
                                              isCounting = false;
                                            });
                                          },
                                        );
                                        Navigator.of(context).pop();
                                        // widget.onClose(true, totalPaymentList);
                                      },
                                      "Remove Voucher",
                                      "Are you sure you want to remove this promocode?",
                                      "Yes",
                                      "No",
                                      true,
                                    );
                                  } else {
                                    Function updateVoucher =
                                        ([MST_Cart updateCartData]) {
                                      if (updateCartData != null) {
                                        Voucher vaocher;
                                        if (updateCartData.voucher_id != null &&
                                            updateCartData.voucher_id != 0) {
                                          var voucherdetail = jsonDecode(
                                              updateCartData.voucher_detail);
                                          vaocher =
                                              Voucher.fromJson(voucherdetail);
                                        }
                                        setState(() {
                                          totalNeedPaid =
                                              updateCartData.grand_total;
                                          currentNumber = updateCartData
                                              .grand_total
                                              .toStringAsFixed(2);
                                          selectedvoucher = vaocher;
                                        });
                                      }
                                      setState(() {
                                        isCounting = false;
                                      });
                                    };
                                    /* totalNeedPaid = await localAPI
                                        .getCartTotal(widget.currentCartID);
                                    print('2');
                                    print(totalNeedPaid);
                                    getCartItem(widget.currentCartID);
                                    
                                    print('onclose call ' +
                                        DateTime.now().toString());
                                    widget.onClose(true, totalPaymentList);
                                    widget.onClose(true, totalPaymentList);
                                    print(
                                        'on close ' + DateTime.now().toString());
                                    Navigator.of(context).pop();
                                    print(
                                        'pop call ' + DateTime.now().toString()); */
                                    if (widget.permissions
                                        .contains(Constant.DISCOUNT_ORDER)) {
                                      widget.voucherFunction(updateVoucher);
                                    } else {
                                      CommonUtils.openPermissionPop(
                                          context, Constant.DISCOUNT_ORDER, () {
                                        widget.voucherFunction(updateVoucher);
                                      }, () {});
                                      setState(() {});
                                    }
                                  }
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    !isPaymented && totalPaymentList.length > 0
                        ? Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              border: Border.all(
                                color: Colors.black,
                              ),
                            ),
                            child: Column(
                              children: [
                                Table(
                                  /* border: TableBorder(
                                bottom:
                                    BorderSide(color: Colors.black, width: 0.6),
                              ), */
                                  columnWidths: {
                                    0: FixedColumnWidth(
                                        125), // fixed to 100 width
                                    1: FixedColumnWidth(125),
                                    2: FixedColumnWidth(
                                        20), //fixed to 100 width
                                  },
                                  children: [
                                    TableRow(
                                      children: [
                                        Text('Type',
                                            style: Styles.blackMediumBold()),
                                        Text('Amount',
                                            style: Styles.blackMediumBold()),
                                        Icon(Icons.delete_forever),
                                      ],
                                    ),
                                  ],
                                ),
                                Divider(
                                  thickness: 2,
                                  height: 15,
                                  color: Colors.black,
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height /
                                      1.5 *
                                      .5,
                                  child: SingleChildScrollView(
                                    child: Table(
                                      /* border: TableBorder(
                                top: BorderSide(color: Colors.black, width: 0.6),
                              ), */
                                      columnWidths: {
                                        0: FixedColumnWidth(
                                            125), // fixed to 100 width
                                        1: FixedColumnWidth(125),
                                        2: FixedColumnWidth(
                                            20), //fixed to 100 width
                                      },
                                      children: paymentList(),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
              Container(
                  height: MediaQuery.of(context).size.height / 1.2 * .8,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: mainPaymentList.length > 0
                          ? setPaymentListTile(mainPaymentList)
                          /* (isSubPayment
                              ? subPaymentListTile(subPaymenttyppeList)
                              : ) */
                          : [],
                    ),
                  )),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      splshsButton("10", () {
                        numberClick('10.00');
                      }),
                      splshsButton("20", () {
                        numberClick('20.00');
                      }),
                      splshsButton("50", () {
                        numberClick('50.00');
                      }),
                      splshsButton("100", () {
                        numberClick('100.00');
                      }),
                      splshsButton("150", () {
                        numberClick('150.00');
                      }),
                      SizedBox(
                        height: 10,
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
                        _button("7", () {
                          numberClick('7');
                        }), // using custom widget button
                        _button("8", () {
                          numberClick('8');
                        }),
                        _button("9", () {
                          numberClick('9');
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
                        }), /* 
                        _button(".", () {
                          if (!currentNumber.contains(".")) {
                            numberClick('.');
                          }
                        }), */
                      ],
                    ),
                    Row(children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _button("1", () {
                                numberClick('1');
                              }),
                              _button("2", () {
                                numberClick('2');
                              }),
                              _button("3", () {
                                numberClick('3');
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
                        /* setState(() {
                          currentPayment.op_amount = currentNumber == "0"
                              ? totalNeedPaid
                              : double.parse(currentNumber);
                          currentPayment.op_method_id = seletedPayment.paymentId;
                          totalPaymentList.add(currentPayment);
                          paidAmount = totalNeedPaid;
                          isPaymented = false;
                        });
                        finalPayment(); */
                        //paidAmount = totalNeedPaid;
                        double currentPaidAmount =
                            double.tryParse(currentNumber);
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
                            paidAmount += currentPaidAmount;
                            if (paidAmount > totalNeedPaid) {
                              currentPayment.op_amount_change =
                                  paidAmount - totalNeedPaid;
                            }
                            totalPaymentList.add(currentPayment);
                            seletedPayment = new Payments();
                            currentPayment = new OrderPayment();
                          });
                        }
                        if (paidAmount < (totalNeedPaid) && this.mounted) {
                          setState(() {
                            isPaymented = false;
                            currentNumber =
                                (totalNeedPaid - paidAmount).toStringAsFixed(2);
                            if (initPayment != null) {
                              seletedPayment = initPayment;
                            }
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
                            (totalNeedPaid - paidAmount).toStringAsFixed(2),
                            () {
                          if (!isPaymented && this.mounted) {
                            if (seletedPayment.paymentId == null) {
                              return CommunFun.showToast(
                                  context, Strings.selectPayment);
                            }
                            setState(() {
                              isPaymented = true;
                              currentPayment.op_amount = currentNumber == "0"
                                  ? totalNeedPaid
                                  : double.parse(currentNumber);
                              double currentPaidAmount =
                                  (totalNeedPaid - paidAmount);
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
                          //widget.onEnter(totalNeedPaid.toString());
                        }),
                      ],
                    ),
                  ],
                ),
              )
            ])
          ],
        )),
      ),
      Positioned(
        bottom: 30,
        right: 80,
        child: Align(
          alignment: FractionalOffset.centerRight,
          child: Row(
            children: [
              CupertinoSwitch(
                activeColor: Colors.deepOrange,
                value: isPausePrint,
                onChanged: (bool value) {
                  setPausePrint(value);
                },
              ),
              SizedBox(width: 15),
              Text(
                'Print Receipt',
                style: Styles.communBlack(),
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  finalPayment() async {
    //List<OrderPayment> totalPayment = [];
    double change = paidAmount - totalNeedPaid;
    if (!(paidAmount >= (totalNeedPaid)) &&
        (seletedPayment.paymentId == null ||
            totalPaymentList[0].op_amount == 0.00)) {
      return CommunFun.showToast(context, Strings.selectPayment);
    }
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return FinalEndScreen(
              total: totalNeedPaid,
              totalPaid: paidAmount,
              change: change,
              onClose: () {
                widget.onClose(false, totalPaymentList);
                Navigator.of(context).pop();
              });
        });
  }
}
