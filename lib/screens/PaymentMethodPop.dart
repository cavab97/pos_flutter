import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/OrderAttributes.dart';
import 'package:mcncashier/models/Table_order.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/Order_Modifire.dart';
import 'package:mcncashier/models/mst_sub_cart_details.dart';
import 'package:mcncashier/screens/OpningAmountPop.dart';
import 'package:mcncashier/services/CommunAPICall.dart';
import 'package:mcncashier/services/LocalAPIs.dart';

class PaymentMethodPop extends StatefulWidget {
  // Opning ammount popup
  PaymentMethodPop(
      {Key key, this.cartID, this.itemCount, this.subTotal, this.grandTotal})
      : super(key: key);
  final double grandTotal;
  final int cartID;
  final int itemCount;
  final double subTotal;

  @override
  PaymentMethodPopState createState() => PaymentMethodPopState();
}

class PaymentMethodPopState extends State<PaymentMethodPop> {
  List<Payments> paymenttyppeList = [];
  LocalAPI localAPI = LocalAPI();
  bool isLoading = false;
  var newAmmount;
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

  Future<Customer> getCustomer() async {
    Customer customer = new Customer();
    var customerData =
        await Preferences.getStringValuesSF(Constant.CUSTOMER_DATA);
    if (customerData != null) {
      var customers = json.decode(customerData);
      customer = Customer.fromJson(customers);
      return customer;
    } else {
      return customer;
    }
  }

  Future<Table_order> getTableData() async {
    Table_order tables = new Table_order();
    var tabledata = await Preferences.getStringValuesSF(Constant.TABLE_DATA);
    if (tabledata != null) {
      var table = json.decode(tabledata);
      tables = Table_order.fromJson(table);
      return tables;
    } else {
      return tables;
    }
  }

  Future<List<MSTCartdetails>> getcartDetails() async {
    List<MSTCartdetails> list = await localAPI.getCartItem(widget.cartID);
    print(list);
    return list;
  }

  Future<List<MSTSubCartdetails>> getmodifireList() async {
    List<MSTSubCartdetails> list =
        await localAPI.itemmodifireList(widget.cartID);
    print(list);
    return list;
  }

  clearCartAfterSuccess() async {
    Table_order tables = await getTableData();
    var result = await localAPI.removeCartItem(widget.cartID, tables.table_id);
    print(result);
    await Preferences.removeSinglePref(Constant.TABLE_DATA);
  }

  sendPaymentByCash(payment) async {
    setState(() {
      isLoading = true;
    });
    Orders order = new Orders();
    Customer customer = await getCustomer();
    Table_order tables = await getTableData();
    User userdata = await CommunFun.getuserDetails();
    var terminalId = await Preferences.getStringValuesSF(Constant.TERMINAL_KEY);
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    var uuid = await CommunFun.getLocalID();
    var datetime =
        await CommunFun.getCurrentDateTime(DateTime.now()).toString();
    order.uuid = uuid;
    order.branch_id = int.parse(branchid);
    order.terminal_id = int.parse(terminalId);
    order.app_id = int.parse(terminalId);
    order.table_no = tables.table_id;
    order.customer_id = customer.customerId;
    order.sub_total = widget.subTotal;
    order.sub_total_after_discount = widget.subTotal;
    order.grand_total = widget.grandTotal;
    order.order_item_count = widget.itemCount;
    order.order_date = datetime;
    order.order_by = userdata.id;

    var orderid = await localAPI.placeOrder(order);
    print(orderid);
    var orderDetailid;
    if (orderid > 0) {
      List<MSTCartdetails> cartList = await getcartDetails();
      if (cartList.length > 0) {
        var orderId = orderid;
        for (var i = 0; i < cartList.length; i++) {
          OrderDetail orderDetail = new OrderDetail();
          var cartItem = cartList[i];
          orderDetail.uuid = uuid;
          orderDetail.order_id = orderId;
          orderDetail.branch_id = int.parse(branchid);
          orderDetail.terminal_id = int.parse(terminalId);
          orderDetail.app_id = int.parse(terminalId);
          orderDetail.product_id = cartItem.productId;
          orderDetail.product_price = cartItem.productPrice;
          orderDetail.product_old_price = cartItem.productNetPrice;
          orderDetailid = await localAPI.sendOrderDetails(orderDetail);
          print(orderDetailid);
        }
      }
    }
    List<MSTSubCartdetails> modifireList = await getmodifireList();
    if (modifireList.length > 0) {
      var orderId = orderid;

      for (var i = 0; i < modifireList.length; i++) {
        OrderModifire modifireData = new OrderModifire();
        var modifire = modifireList[i];
        if (modifire.caId == null) {
          modifireData.uuid = uuid;
          modifireData.order_id = orderId;
          modifireData.detail_id = orderDetailid;
          modifireData.terminal_id = int.parse(terminalId);
          modifireData.app_id = int.parse(terminalId);
          modifireData.product_id = modifire.productId;
          modifireData.modifier_id = modifire.modifierId;
          modifireData.om_amount = modifire.modifirePrice;
          // modifireData.om_status = 1;
          // modifireData.om_datetime = 1;
          // modifireData.om_by = 1;
          modifireData.updated_at = datetime;
          modifireData.updated_by = userdata.id;
          var ordermodifreid = await localAPI.sendModifireData(modifireData);
          print(ordermodifreid);
        } else {
          OrderAttributes attributes = new OrderAttributes();
          attributes.uuid = uuid;
          attributes.order_id = orderId;
          attributes.detail_id = orderDetailid;
          attributes.terminal_id = int.parse(terminalId);
          attributes.app_id = int.parse(terminalId);
          attributes.product_id = modifire.productId;
          attributes.attribute_id = modifire.attributeId;
          attributes.attr_price = modifire.attrPrice;
          attributes.ca_id = modifire.caId;
          attributes.oa_datetime = datetime;
          attributes.oa_by = userdata.id;
          attributes.updated_at = datetime;
          attributes.updated_by = userdata.id;
          var orderAttri = await localAPI.sendAttrData(attributes);
          print(orderAttri);
        }
      }
    }

    OrderPayment orderpayment = new OrderPayment();

    orderpayment.uuid = uuid;
    orderpayment.order_id = orderid;
    orderpayment.branch_id = int.parse(branchid);
    orderpayment.terminal_id = int.parse(terminalId);
    orderpayment.app_id = int.parse(terminalId);
    orderpayment.op_method_id = payment.paymentId;
    orderpayment.op_amount = widget.grandTotal.toDouble();
    orderpayment.op_method_response = '';
    orderpayment.op_status = 1;
    orderpayment.op_datetime = datetime;
    orderpayment.op_by = userdata.id;
    var paymentid = await localAPI.sendtoOrderPayment(orderpayment);
    print(paymentid);
    await clearCartAfterSuccess();
    Navigator.pushNamed(context, Constant.DashboardScreen);
    setState(() {
      isLoading = false;
    });
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
            padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
            height: 70,
            color: Colors.black,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(widget.grandTotal.toString(), style: Styles.whiteBold()),
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
      height: 300,
      width: MediaQuery.of(context).size.width / 2.2,
      child: Column(
        children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(width: 15),
                    Container(
                        height: 70,
                        width: 70,
                        child: Image.asset("assets/bg.jpg")),
                    SizedBox(width: 15),
                    Text(
                      Strings.cash,
                      style: Styles.blackBoldLarge(),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    GestureDetector(
                        onTap: () {
                          openAmountPop();
                        },
                        child: Text(newAmmount.toString(),
                            style:
                                TextStyle(color: Colors.grey, fontSize: 20))),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        sendPaymentByCash("CASH");
                      },
                      child: Container(
                        height: 50,
                        width: 100,
                        decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Center(
                          child: Text(
                            Strings.btn_exect,
                            style: Styles.whiteBold(),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ]),
          ListView(
            shrinkWrap: true,
            children: paymenttyppeList.map((payment) {
              return ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: Container(
                      height: 70,
                      width: 70,
                      child: Image.asset("assets/bg.jpg")),
                  onTap: () {
                    sendPaymentByCash(payment);
                  },
                  title: Text(payment.name, style: Styles.blackBoldLarge()),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.black));
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
            child: Icon(
              Icons.clear,
              color: Colors.white,
              size: 30,
            ),
          ),
        ));
  }
}
