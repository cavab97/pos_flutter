import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/services/LocalAPIs.dart';

class InvoiceReceiptDailog extends StatefulWidget {
  InvoiceReceiptDailog({Key key, this.orderid}) : super(key: key);
  final int orderid;
  @override
  _InvoiceReceiptDailogState createState() => _InvoiceReceiptDailogState();
}

class _InvoiceReceiptDailogState extends State<InvoiceReceiptDailog> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  LocalAPI localAPI = LocalAPI();
  int orderid;
  @override
  void initState() {
    super.initState();
    setState(() {
      orderid = widget.orderid;
    });
    getOederData();
  }

  getOederData() async {
    var branchID = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    Branch branchAddress = await localAPI.getBranchData(branchID);
    OrderPayment orderpaymentdata = await localAPI.getOrderpaymentData(orderid);
    Payments paument_method =
        await localAPI.getOrderpaymentmethod(orderpaymentdata.op_method_id);
    User user = await localAPI.getPaymentUser(orderpaymentdata.op_by);
    List<OrderDetail> itemsList = await localAPI.getOrderDetailsList(orderid);
    Orders order = await localAPI.getcurrentOrders(orderid);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      title: Stack(
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
                Text(Strings.invoice_reciept.toUpperCase(),
                    style: TextStyle(fontSize: 30, color: Colors.white)),
              ],
            ),
          ),
          Positioned(
            right: 30,
            top: 10,
            child: Icon(
              Icons.print,
              color: Colors.white,
              size: 50,
            ),
          ),
          closeButton(context),
        ],
      ),
      content: mainContent(),
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
            child: Icon(
              Icons.clear,
              color: Colors.white,
              size: 30,
            ),
          ),
        ));
  }

  Widget mainContent() {
    return Container(
      width: MediaQuery.of(context).size.width / 2.5,
    );
  }
}
