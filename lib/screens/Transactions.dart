import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/models/cancelOrder.dart';
import 'package:mcncashier/screens/PaymentMethodPop.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class TransactionsPage extends StatefulWidget {
  // Transactions list
  TransactionsPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  LocalAPI localAPI = LocalAPI();
  List<Orders> orderLists = [];
  List<Orders> filterList = [];
  Orders selectedOrder = new Orders();
  List taxJson = [];
  OrderPayment orderpayment = new OrderPayment();
  User paymemtUser = new User();
  List<ProductDetails> detailsList = [];
  List<OrderDetail> orderItemList = [];
  bool isFiltering = false;
  bool isRefunding = false;
  bool isWeborder = true;
  Customer customer = new Customer();
  Payments paumentMethod = new Payments();
  @override
  void initState() {
    super.initState();
    getTansactionList();
    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
  }

  getTansactionList() async {
    var terminalid = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    List<Orders> orderList = await localAPI.getOrdersList(branchid, terminalid);
    if (orderList.length > 0) {
      setState(() {
        orderLists = orderList;
      });
      getOrderDetails(orderLists[0]);
    }
  }

  getOrderDetails(order) async {
    setState(() {
      selectedOrder = order;
      isWeborder = order.order_source == 1 ? true : false;
      taxJson = json.decode(selectedOrder.tax_json);
    });

    List<OrderDetail> orderItem =
        await localAPI.getOrderDetailsList(order.app_id);
    List<ProductDetails> details = await localAPI.getOrderDetails(order.app_id);
    if (details.length > 0) {
      setState(() {
        detailsList = details;
        orderItemList = orderItem;
      });
    }
    //  if (order.order_source == 2) {
    OrderPayment orderpaymentdata =
        await localAPI.getOrderpaymentData(order.app_id);
    setState(() {
      orderpayment = orderpaymentdata;
    });
    Payments paument_method =
        await localAPI.getOrderpaymentmethod(orderpayment.op_method_id);
    setState(() {
      paumentMethod = paument_method;
    });
    User user = await localAPI.getPaymentUser(orderpayment.op_by);
    if (user != null) {
      setState(() {
        paymemtUser = user;
      });
    }
    //}
  }

  startFilter() {
    setState(() {
      filterList = orderLists;
      isFiltering = true;
    });
  }

  filterOrders(val) {
    var list = orderLists
        .where((x) =>
            x.invoice_no.toString().toLowerCase().contains(val.toLowerCase()))
        .toList();
    setState(() {
      filterList = list;
    });
  }

  refundProcessStart() {
    setState(() {
      isRefunding = true;
    });
  }

  cancleAlertpopOpne() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return TrancationCancleAlert(
            onClose: () {
              Navigator.of(context).pop();
              showReasontypePop();
            },
          );
        });
  }

  showReasontypePop() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ChooseReasonType(
            onClose: (reason) {
              Navigator.of(context).pop();
              if (reason == "Other") {
                otherReasonPop();
              } else {
                paymentMethodPop(reason);
              }
            },
          );
        });
  }

  otherReasonPop() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AddOtherReason(
            onClose: (otherText) {
              Navigator.of(context).pop();
              paymentMethodPop(otherText);
            },
          );
        });
  }

  paymentMethodPop(reason) {
    showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return PaymentMethodPop(
            subTotal: selectedOrder.sub_total,
            grandTotal: selectedOrder.grand_total,
            onClose: (mehtod) {
              cancleTransactionWithMethod(mehtod, reason);
            },
          );
        });
  }

  cancleTransactionWithMethod(paymehtod, reason) {
    print(paymehtod);
    cancleTransation(reason);
    Navigator.of(context).pop();
  }

  cancleTransation(reason) async {
    //TODO :Cancle Transation Pop // 1 for  cancle
    var orderid = await localAPI.updateOrderStatus(selectedOrder.app_id, 3);
    var payment = await localAPI.updatePaymentStatus(orderpayment.app_id, 3);
    var terID = await CommunFun.getTeminalKey();
    User userdata = await CommunFun.getuserDetails();
    CancelOrder order = new CancelOrder();
    order.id = selectedOrder.order_id;
    order.invoiceId = selectedOrder.app_id;
    order.localID = await CommunFun.getLocalID();
    order.reason = reason;
    order.status = 3;
    order.createdBy = userdata.id;
    order.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
    order.terminalId = int.parse(terID);
    order.invoiceTerminalId = int.parse(terID);
    var addTocancle = await localAPI.insertCancelOrder(order);
    // TODO update store inventory
    getTansactionList();
  }

  refundSelectedammout() {
    showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return PaymentMethodPop(
            subTotal: selectedOrder.sub_total,
            grandTotal: selectedOrder.grand_total,
            onClose: (mehtod) {
              returnPayment(mehtod);
            },
          );
        });
  }

  returnPayment(paymentMehtod) {
    // TODO : update payment tables

    CommunFun.showToast(context, "Refund table insert data.. work in progress");
  }

  deleteItemFormList(product) async {

    var result = await localAPI.deleteOrderItem(product.app_id);

    CommunFun.showToast(context, "Refund table insert data.. work in progress");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: transactionsDrawer(), // page Drawer
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Table(
            columnWidths: {
              0: FractionColumnWidth(.3),
              1: FractionColumnWidth(.6),
            },
            children: [
              TableRow(children: [
                TableCell(
                    // Part 1 white
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.white,
                        child: ListView(
                          padding: EdgeInsets.all(20),
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                IconButton(
                                  padding: EdgeInsets.all(0),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(
                                    Icons.keyboard_arrow_left,
                                    size: 50,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(Strings.transaction,
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800])),
                              ],
                            ),
                            transationsSearchBox(),
                            SizedBox(
                              height: 15,
                            ),
                            orderLists.length > 0
                                ? searchTransationList()
                                : Center(
                                    child: Text(Strings.no_order_found,
                                        style: Styles.darkBlue()))
                          ],
                        ))),
                TableCell(
                  // Part 2 transactions list
                  child: Center(
                    child: SingleChildScrollView(
                      child: Stack(children: <Widget>[
                        // Padding(
                        //     padding: EdgeInsets.only(right: 10, top: 10),
                        //     child: Row(
                        //       crossAxisAlignment: CrossAxisAlignment.center,
                        //       mainAxisAlignment: MainAxisAlignment.end,
                        //       children: <Widget>[
                        //         isWeborder
                        //             ? assingTableButton(() {
                        //                 assignTable();
                        //               })
                        //             : SizedBox()
                        //       ],
                        //     )),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          height: MediaQuery.of(context).size.height,
                          margin: EdgeInsets.only(top: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 15),
                              Text(
                                  DateFormat('EEE, MMM d yyyy, hh:mm aaa')
                                      .format(DateTime.parse(
                                          selectedOrder.order_date != null
                                              ? selectedOrder.order_date
                                              : DateTime.now().toString())),
                                  style: Styles.whiteSimpleSmall()),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                orderpayment.op_amount.toString(),
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).accentColor),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              selectedOrder != null &&
                                      paymemtUser.username != null
                                  ? Text(
                                      selectedOrder.invoice_no +
                                          " - Processed by " +
                                          paymemtUser.username,
                                      style: Styles.whiteBoldsmall(),
                                    )
                                  : SizedBox(),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                  child: Text(
                                    customer.firstName != null
                                        ? customer.firstName
                                        : "Walk-In Customer",
                                    style: TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).accentColor),
                                  ),
                                ),
                                color: Colors.grey[900].withOpacity(0.4),
                              ),
                              productList(),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 40,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 50),
                            child: Column(children: <Widget>[
                              Divider(),
                              totalAmountValues(),
                              Divider(),
                              isRefunding
                                  ? refundButtons(context)
                                  : transationsButton()
                            ]),
                          ),
                        ),
                      ]),
                    ),
                  ),
                )
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget assingTableButton(onPress) {
    return RaisedButton(
      padding: EdgeInsets.all(10),
      onPressed: onPress,
      child: Text("Assign Table", style: Styles.whiteSimpleSmall()),
      color: Colors.deepOrange,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  transactionsDrawer() {
    return Drawer(
      child: Container(color: Colors.white),
    );
  }

  Widget transationsSearchBox() {
    return Container(
      height: 70,
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(10),
      color: Colors.grey[400],
      child: TextField(
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 15),
            child: Icon(
              Icons.search,
              color: Colors.grey[400],
              size: 40,
            ),
          ),
          hintText: Strings.searchbox_hint,
          hintStyle: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
          filled: true,
          contentPadding: EdgeInsets.only(left: 20, top: 20, bottom: 20),
          fillColor: Colors.white,
        ),
        style: TextStyle(color: Colors.black, fontSize: 25.0),
        onTap: () {
          startFilter();
        },
        onChanged: (e) {
          print(e);
          if (e.length != 0) {
            filterOrders(e);
          }
        },
      ),
    );
  }

  Widget refundButtons(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        refundCancelButton(() {
          setState(() {
            isRefunding = false;
          });
        }),
        SizedBox(width: 10),
        refundNextButton(() {
          refundSelectedammout();
        }),
      ],
    );
  }

  refundCancelButton(_onPress) {
    return Expanded(
      child: RaisedButton(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
        onPressed: _onPress,
        child: Text(
          "Cancel",
          style: TextStyle(
              color:
                  orderpayment.op_status == 1 ? Colors.white : Colors.white38,
              fontSize: 20),
        ),
        color: Colors.deepOrange,
        textColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  refundNextButton(_onPress) {
    return Expanded(
      child: RaisedButton(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
        onPressed: _onPress,
        child: Text(
          "Next",
          style: TextStyle(
              color:
                  orderpayment.op_status == 1 ? Colors.white : Colors.white38,
              fontSize: 20),
        ),
        color: Colors.deepOrange,
        textColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  Widget transationsButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        refundButton(() {
          if (orderpayment.op_status == 1) {
            // refund ordr
            refundProcessStart();
          }
        }),
        SizedBox(width: 10),
        cancelButton(() {
          if (orderpayment.op_status == 1) {
            cancleAlertpopOpne();
          }
        }),
      ],
    );
  }

  Widget totalAmountValues() {
    return Table(defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        // border: TableBorder(
        //     horizontalInside: BorderSide(
        //         width: 1, color: Colors.grey, style: BorderStyle.solid)),
        children: [
          TableRow(children: [
            TableCell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    Strings.sub_total.toUpperCase(),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey),
                  ),
                  SizedBox(width: 70),
                  Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        selectedOrder.sub_total != null
                            ? selectedOrder.sub_total.toString()
                            : "00:00",
                        style: TextStyle(
                            fontWeight: FontWeight.w700, color: Colors.grey),
                      )),
                ],
              ),
            ),
          ]),
          TableRow(children: [
            TableCell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        Strings.discount.toUpperCase(),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).accentColor),
                      )),
                  SizedBox(width: 70),
                  Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        selectedOrder.voucher_amount.toString() != '0.0'
                            ? selectedOrder.voucher_amount.toString()
                            : "00.00",
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).accentColor),
                      )),
                ],
              ),
            ),
          ]),
          TableRow(children: [
            TableCell(
              child: taxJson.length != 0
                  ? Column(
                      children: taxJson.map((taxitem) {
                      return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              child: Text(
                                Strings.tax.toUpperCase() +
                                    " " +
                                    taxitem["taxCode"] +
                                    "(" +
                                    taxitem["rate"] +
                                    "%)",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey),
                              ),
                            ),
                            SizedBox(width: 70),
                            Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              child: Text(taxitem["taxAmount"].toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey)),
                            )
                          ]);
                    }).toList())
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Text(
                              Strings.tax.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey),
                            ),
                          ),
                          SizedBox(width: 70),
                          Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Text(selectedOrder.tax_amount.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey)),
                          )
                        ]),
            ),
          ]),
          TableRow(children: [
            TableCell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      top: 10,
                    ),
                    child: Text(
                      Strings.grand_total,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey),
                    ),
                  ),
                  SizedBox(width: 70),
                  Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                      ),
                      child: Text(
                        selectedOrder.grand_total != null
                            ? selectedOrder.grand_total.toString()
                            : "00:00",
                        style: TextStyle(
                            fontWeight: FontWeight.w700, color: Colors.grey),
                      )),
                ],
              ),
            ),
          ]),
          TableRow(children: [
            TableCell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      top: 10,
                    ),
                    child: Text(
                      paumentMethod.name,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey),
                    ),
                  ),
                  SizedBox(width: 70),
                  Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                      ),
                      child: Text(
                        selectedOrder.grand_total != null
                            ? selectedOrder.grand_total.toString()
                            : "00:00",
                        style: TextStyle(
                            fontWeight: FontWeight.w700, color: Colors.grey),
                      )),
                ],
              ),
            ),
          ]),
        ]);
  }

  Widget refundButton(Function _onPress) {
    return Expanded(
      child: RaisedButton(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
        onPressed: _onPress,
        child: Text(
          "Refund",
          style: TextStyle(
              color:
                  orderpayment.op_status == 1 ? Colors.white : Colors.white38,
              fontSize: 20),
        ),
        color: Colors.deepOrange,
        textColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  Widget cancelButton(Function _onPress) {
    return Expanded(
      child: RaisedButton(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
        onPressed: _onPress,
        child: Text(
          Strings.cancel_tansaction,
          style: TextStyle(
              color:
                  orderpayment.op_status == 1 ? Colors.white : Colors.white38,
              fontSize: 20),
        ),
        color: Colors.deepOrange,
        textColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  Widget productList() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 50),
      height: MediaQuery.of(context).size.height / 2.5,
      // width: MediaQuery.of(context).size.width / 1.7,
      child: SingleChildScrollView(
        child: Column(
            children: orderItemList.map((product) {
          var index = orderItemList.indexOf(product);
          var item = detailsList[index];
          var image_Arr = item.base64.split(" groupconcate_Image ");
          return InkWell(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Hero(
                      tag: product.product_id,
                      child: Container(
                        height: 80,
                        width: 100,
                        decoration: new BoxDecoration(
                          color: Colors.greenAccent,
                          // image: new DecorationImage(
                          //   image: new ExactAssetImage("assets/image1.jfif"),
                          //   fit: BoxFit.cover,
                          // ),
                        ),
                        child: image_Arr.length != 0 && image_Arr[0] != ""
                            ? CommonUtils.imageFromBase64String(image_Arr[0])
                            : new Image.asset(
                                Strings.no_imageAsset,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Flexible(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(item.name.toString().toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Theme.of(context).primaryColor)),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(product.detail_qty.toString(),
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).primaryColor)),
                          SizedBox(width: 80),
                          Text(product.product_price.toString(),
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).primaryColor)),
                          isRefunding
                              ? IconButton(
                                  padding:
                                      EdgeInsets.only(left: 10, bottom: 20),
                                  icon: Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                  onPressed: () {
                                    deleteItemFormList(product);
                                  })
                              : SizedBox(),
                        ],
                      ),
                    )
                  ],
                ),
              ));
        }).toList()),
      ),
    );
  }

  Widget searchTransationList() {
    if (isFiltering) {
      return ListView(
          shrinkWrap: true,
          children: filterList.map((item) {
            return Container(
                decoration: new BoxDecoration(
                    color: selectedOrder.app_id == item.app_id
                        ? Colors.grey[200]
                        : Colors.white),
                child: ListTile(
                  dense: false,
                  selected: selectedOrder.app_id == item.app_id,
                  onTap: () {
                    getOrderDetails(item);
                  },
                  title: Row(
                    children: <Widget>[
                      Text(
                          DateFormat('hh:mm aaa')
                              .format(DateTime.parse(item.order_date)),
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600])),
                      SizedBox(width: 10),
                      item.order_status == 3
                          ? Container(
                              padding: EdgeInsets.all(3),
                              color: Colors.red,
                              child: Text(
                                "Cancel",
                                style: Styles.whiteBoldsmall(),
                              ),
                            )
                          : SizedBox()
                    ],
                  ),
                  subtitle: Text(Strings.invoice + item.invoice_no.toString(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600])),
                  isThreeLine: true,
                  trailing: Text(item.grand_total.toString(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600])),
                ));
          }).toList());
    } else {
      return ListView(
          shrinkWrap: true,
          children: orderLists.map((item) {
            return Container(
                decoration: new BoxDecoration(
                    color: selectedOrder.app_id == item.app_id
                        ? Colors.grey[200]
                        : Colors.white),
                child: ListTile(
                  dense: false,
                  selected: selectedOrder.app_id == item.app_id,
                  onTap: () {
                    getOrderDetails(item);
                  },
                  title: Row(
                    children: <Widget>[
                      Text(
                          DateFormat('hh:mm aaa')
                              .format(DateTime.parse(item.order_date)),
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600])),
                      SizedBox(width: 10),
                      item.order_status == 3
                          ? Container(
                              padding: EdgeInsets.all(3),
                              color: Colors.red,
                              child: Text(
                                "Cancel",
                                style: Styles.whiteBoldsmall(),
                              ),
                            )
                          : SizedBox()
                    ],
                  ),
                  subtitle: Text(Strings.invoice + item.invoice_no.toString(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600])),
                  isThreeLine: true,
                  trailing: Text(item.grand_total.toString(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600])),
                ));
          }).toList());
    }
  }
}

class TrancationCancleAlert extends StatefulWidget {
  TrancationCancleAlert({Key key, this.onClose}) : super(key: key);
  Function onClose;
  @override
  TrancationCancleAlertState createState() => TrancationCancleAlertState();
}

class TrancationCancleAlertState extends State<TrancationCancleAlert> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      titlePadding: EdgeInsets.all(20),
      title: Center(child: Text("Warning")),
      content: Container(
          width: MediaQuery.of(context).size.width / 3.4,
          child: Text(
              "This action can not be undone.Do you want to void the trancation?")),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            widget.onClose();
          },
          child: Text("Yes", style: Styles.orangeSmall()),
        ),
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("No", style: Styles.orangeSmall()),
        )
      ],
    );
  }
}

class ChooseReasonType extends StatefulWidget {
  ChooseReasonType({Key key, this.onClose}) : super(key: key);
  Function onClose;
  @override
  ChooseReasonTypeState createState() => ChooseReasonTypeState();
}

class ChooseReasonTypeState extends State<ChooseReasonType> {
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Choose Reason", style: Styles.whiteBold()),
              ],
            ),
          ),
          Positioned(left: 10, top: 15, child: confirmBtn(context)),
          closeButton(context), // close button
        ],
      ),
      content: Container(
        width: MediaQuery.of(context).size.width / 2.4,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            ListTile(
                onTap: () {
                  widget.onClose("Incorrect Item");
                },
                title: Text(
                  "Incorrect Item",
                  style: Styles.communBlack(),
                )),
            ListTile(
                onTap: () {
                  widget.onClose("Incorrect variant");
                },
                title: Text(
                  "Incorrect variant",
                  style: Styles.communBlack(),
                )),
            ListTile(
                onTap: () {
                  widget.onClose("Incorrect payment type");
                },
                title: Text(
                  "Incorrect payment type",
                  style: Styles.communBlack(),
                )),
            ListTile(
                onTap: () {
                  widget.onClose("Incorrect quantity");
                },
                title: Text(
                  "Incorrect quantity",
                  style: Styles.communBlack(),
                )),
            ListTile(
                onTap: () {
                  widget.onClose("Other");
                },
                title: Text(
                  "Other",
                  style: Styles.communBlack(),
                )),
          ],
        ),
      ),
    );
  }

  Widget confirmBtn(context) {
    // Add button header rounded
    return FlatButton(
      // padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      onPressed: () {
        widget.onClose();
      },
      child: Text("Confirm",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          )),
      textColor: Colors.white,
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

class AddOtherReason extends StatefulWidget {
  AddOtherReason({Key key, this.onClose}) : super(key: key);
  Function onClose;
  @override
  AddOtherReasonState createState() => AddOtherReasonState();
}

class AddOtherReasonState extends State<AddOtherReason> {
  TextEditingController reasonController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      content: Container(
          height: MediaQuery.of(context).size.height / 4,
          width: MediaQuery.of(context).size.width / 3.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                "Reason",
                style: Styles.communBlack(),
              ),
              SizedBox(height: 10),
              TextField(
                controller: reasonController,
                maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(width: 1, color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(width: 1, color: Colors.grey),
                  ),
                ),
              ),
            ],
          )),
      actions: <Widget>[canclebutton(context), confirmBtn(context)],
    );
  }

  Widget confirmBtn(context) {
    // Add button header rounded
    return FlatButton(
      onPressed: () {
        widget.onClose(reasonController.text);
      },
      child: Text("Confirm", style: Styles.orangeSmall()),
      textColor: Colors.white,
    );
  }

  Widget canclebutton(context) {
    return FlatButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text("Cancel", style: Styles.orangeSmall()),
      textColor: Colors.white,
    );
  }
}
