import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/screens/OpningAmountPop.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:mcncashier/components/colors.dart';

class SubPaymentMethodPop extends StatefulWidget {
  // Opning ammount popup
  SubPaymentMethodPop(
      {Key key, this.subList, this.subTotal, this.grandTotal, this.onClose})
      : super(key: key);
  final double grandTotal;
  List<Payments> subList = [];
  final double subTotal;
  Function onClose;

  @override
  _SubPaymentMethodPop createState() => _SubPaymentMethodPop();
}

class _SubPaymentMethodPop extends State<SubPaymentMethodPop> {
  List<Payments> paymenttyppeList = [];
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
      paymenttyppeList = widget.subList;
    });
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
      titlePadding: EdgeInsets.zero,
      title: Stack(
        // popup header
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
            height: SizeConfig.safeBlockVertical * 9,
            color: StaticColor.colorBlack,
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
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        // height: MediaQuery.of(context).size.height / 3,
        width: MediaQuery.of(context).size.width / 3,
        child: Column(
          children: <Widget>[
            ListView(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              children: paymenttyppeList.map((payment) {
                return ListTile(
                    contentPadding: EdgeInsets.all(5),
                    leading: Icon(
                      payment.name.contains("Wallet")
                          ? Icons.account_balance_wallet
                          : Icons.credit_card,
                      color: StaticColor.colorBlack,
                      size: SizeConfig.safeBlockVertical * 7,
                    ),
                    // Container(
                    //     height: 70,
                    //     width: 70,
                    //     child: Image.asset("assets/bg.jpg")),
                    onTap: () {
                      /// sendPaymentByCash(payment);
                      widget.onClose(payment);
                    },
                    title: Text(payment.name, style: Styles.blackMediumBold()),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: StaticColor.colorBlack,
                      size: SizeConfig.safeBlockVertical * 4,
                    ));
              }).toList(),
            )
          ],
        ),
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
}
