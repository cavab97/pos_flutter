import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/screens/OpningAmountPop.dart';
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
    // getcartData();
    // getbranch();
  }

  getPaymentMethods() async {
    var result = await localAPI.getPaymentMethods();
    if (result.length != 0) {
      setState(() {
        paymenttyppeList = result;
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
                Text(widget.grandTotal.toString(),
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
      child: Column(
        children: <Widget>[
          // Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: <Widget>[
          //       Row(
          //         children: <Widget>[
          //           SizedBox(width: 10),
          //           // Container(
          //           //     height: 70,
          //           //     width: 70,
          //           //     child: Image.asset("assets/bg.jpg")),
          //           Icon(
          //             Icons.credit_card,
          //             color: Colors.black,
          //             size: 50,
          //           ),
          //           SizedBox(width: 15),
          //           Text(
          //             Strings.cash,
          //             style: Styles.blackBoldLarge(),
          //           ),
          //         ],
          //       ),
          //       Row(
          //         children: <Widget>[
          //           GestureDetector(
          //               onTap: () {
          //                 openAmountPop();
          //               },
          //               child: Text(newAmmount.toString(),
          //                   style:
          //                       TextStyle(color: Colors.grey, fontSize: 20))),
          //           SizedBox(width: 10),
          //           GestureDetector(
          //             onTap: () {
          //               // sendPaymentByCash("");
          //             },
          //             child: Container(
          //               height: 50,
          //               width: 100,
          //               decoration: BoxDecoration(
          //                   color: Colors.deepOrange,
          //                   borderRadius: BorderRadius.circular(10.0)),
          //               child: Center(
          //                 child: Text(
          //                   Strings.btn_exect,
          //                   style: Styles.whiteBold(),
          //                 ),
          //               ),
          //             ),
          //           )
          //         ],
          //       ),
          //     ]),

          ListView(
            shrinkWrap: true,
            children: paymenttyppeList.map((payment) {
              return ListTile(
                  contentPadding: EdgeInsets.all(5),
                  leading: Icon(
                    Icons.credit_card,
                    color: Colors.black,
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
                    color: Colors.black,
                    size: SizeConfig.safeBlockVertical * 4,
                  ));
            }).toList(),
          )
        ],
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
