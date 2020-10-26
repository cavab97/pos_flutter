import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/screens/OpningAmountPop.dart';
import 'package:mcncashier/screens/SubPaymentMethodPop.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/theme/Sized_Config.dart';

class PaymentMethodPop extends StatefulWidget {
  // Opning ammount popup
  PaymentMethodPop({Key key, this.subTotal, this.grandTotal, this.onClose})
      : super(key: key);
  final double grandTotal;
  final double subTotal;
  Function onClose;

  @override
  PaymentMethodPopState createState() => PaymentMethodPopState();
}

class PaymentMethodPopState extends State<PaymentMethodPop> {
  List<Payments> paymenttyppeList = [];
  List<Payments> allPaymentTypes = [];
  LocalAPI localAPI = LocalAPI();
  bool isLoading = false;
  var newAmmount;
  Branch branchdata;
  MST_Cart cartData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      newAmmount = widget.grandTotal;
    });
    getPaymentMethods();
  }

  getPaymentMethods() async {
    var result = await localAPI.getPaymentMethods();
    List<Payments> mainPaymentList =
        result.where((i) => i.isParent == 0).toList();

    if (result.length != 0) {
      setState(() {
        paymenttyppeList = mainPaymentList;
        allPaymentTypes = result;
      });
    }
  }

  openAmountPop() {
    showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return OpeningAmmountPage(
              ammountext: widget.grandTotal.toString(),
              onEnter: (ammountext) {
                setState(() {
                  newAmmount = ammountext;
                });
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      title: Stack(
        // popup header
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
            height: SizeConfig.safeBlockVertical * 9,
            color: Colors.black,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(widget.grandTotal.toStringAsFixed(2),
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

  Widget mainContent() {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      width: MediaQuery.of(context).size.width / 3,
      child: ListView(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        children: paymenttyppeList.map((payment) {
          return ListTile(
              contentPadding: EdgeInsets.all(5),
              leading: Hero(
                  tag: payment.paymentId != null ? payment.paymentId : 0,
                  child: Container(
                    color: Colors.grey,
                    width: MediaQuery.of(context).size.width,
                    height: 20.0,
                    child: payment.base64 != ""
                        ? CommonUtils.imageFromBase64String(
                            payment.base64)
                        : new Image.asset(
                            Strings.no_image,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          ),
                  )),
              /*Icon(
                payment.name.contains("Wallet")
                    ? Icons.account_balance_wallet
                    : Icons.credit_card,
                color: Colors.black,
                size: SizeConfig.safeBlockVertical * 7,
              ),*/
              // Container(
              //     height: 70,
              //     width: 70,
              //     child: Image.asset("assets/bg.jpg")),
              onTap: () {
                /// sendPaymentByCash(payment);
                ///
                List<Payments> subList = allPaymentTypes
                    .where((i) => i.isParent == payment.paymentId)
                    .toList();
                if (subList.length > 0) {
                  openSubPaymentDialog(subList);
                } else {
                  widget.onClose(payment);
                }
              },
              title: Text(payment.name, style: Styles.blackMediumBold()),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
                size: SizeConfig.safeBlockVertical * 4,
              ));
        }).toList(),
      ),
    );
  }

  openSubPaymentDialog(List<Payments> subList) {
    showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return SubPaymentMethodPop(
            subList: subList,
            subTotal: widget.subTotal,
            grandTotal: widget.grandTotal,
            onClose: (mehtod) {
              Navigator.of(context).pop();
              widget.onClose(mehtod);
            },
          );
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
}
