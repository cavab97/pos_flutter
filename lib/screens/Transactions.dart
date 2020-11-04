import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/colors.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/ProductStoreInventoryLog.dart';
import 'package:mcncashier/models/Product_Store_Inventory.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/models/cancelOrder.dart';
import 'package:mcncashier/screens/PaymentMethodPop.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:mcncashier/theme/Sized_Config.dart';

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
  List<OrderPayment> orderpayment = [];
  User paymemtUser = new User();
  List<ProductDetails> detailsList = [];
  List<OrderDetail> orderItemList = [];
  bool isFiltering = false;
  bool isRefunding = false;
  bool isWeborder = true;
  var permissions = "";
  var orderDate = "";
  Customer customer = new Customer();
  Payments paumentMethod = new Payments();

  @override
  void initState() {
    super.initState();
    getTansactionList();
    setPermissons();
    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
  }

  setPermissons() async {
    var permission = await CommunFun.getPemission();
    setState(() {
      permissions = permission;
    });
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
    var date = await CommunFun.getCurrentDateTime(DateTime.parse(
        order.order_date != null
            ? order.order_date
            : DateTime.now().toString()));
    var orderDateF =
        DateFormat('EEE, MMM d yyyy, hh:mm aaa').format(DateTime.parse(date));
    setState(() {
      selectedOrder = order;
      orderDate = orderDateF;
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
    List<OrderPayment> orderpaymentdata =
        await localAPI.getOrderpaymentData(order.app_id);
    setState(() {
      orderpayment = orderpaymentdata;
    });
    if (orderpayment.length > 0) {
      List<Payments> paument_method =
          await localAPI.getOrderpaymentmethod(orderpayment[0].op_method_id);
      setState(() {
        paumentMethod = paument_method[0];
      });
      User user = await localAPI.getPaymentUser(orderpayment[0].op_by);
      if (user != null) {
        setState(() {
          paymemtUser = user;
        });
      }
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
    cancleTransation(reason);
    Navigator.of(context).pop();
  }

  cancleTransation(reason) async {
    //TODO :Cancle Transation Pop // 1 for  cancle
    var orderid = await localAPI.updateOrderStatus(selectedOrder.app_id, 3);
    var payment = await localAPI.updatePaymentStatus(orderpayment[0].app_id, 3);
    var terminalId = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    var uuid = await CommunFun.getLocalID();
    var terID = await CommunFun.getTeminalKey();
    User userdata = await CommunFun.getuserDetails();
    CancelOrder order = new CancelOrder();
    order.id = selectedOrder.order_id;
    order.orderId = selectedOrder.app_id;
    order.localID = await CommunFun.getLocalID();
    order.reason = reason;
    order.status = 3;
    order.serverId = 0;
    order.createdBy = userdata.id;
    order.updatedBy = userdata.id;
    order.updatedAt = await CommunFun.getCurrentDateTime(DateTime.now());
    order.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
    order.terminalId = int.parse(terID);
    var addTocancle = await localAPI.insertCancelOrder(order);
    List<OrderDetail> orderItem = orderItemList;
    if (orderItem.length > 0) {
      for (var i = 0; i < orderItem.length; i++) {
        OrderDetail productDetail = orderItem[i];
        var productData = productDetail.product_detail;
        var jsonProduct = json.decode(productData);
        List<ProductStoreInventory> updatedInt = [];
        List<ProductStoreInventoryLog> updatedIntLog = [];
        if (jsonProduct["has_inventory"] == 1) {
          List<ProductStoreInventory> inventory =
              await localAPI.getStoreInventoryData(productDetail.product_id);
          if (inventory.length > 0) {
            ProductStoreInventory invData;
            invData = inventory[0];
            invData.qty = invData.qty + productDetail.detail_qty;
            invData.updatedAt =
                await CommunFun.getCurrentDateTime(DateTime.now());
            invData.updatedBy = userdata.id;
            updatedInt.add(invData);
            var ulog = await localAPI.updateInvetory(updatedInt);
            ProductStoreInventoryLog log = new ProductStoreInventoryLog();
            if (inventory.length > 0) {
              log.uuid = uuid;
              log.inventory_id = inventory[0].inventoryId;
              log.branch_id = int.parse(branchid);
              log.product_id = productDetail.product_id;
              log.employe_id = userdata.id;
              // log.il_type = '';
              log.qty = invData.qty;
              log.qty_before_change = invData.qty;
              log.qty_after_change = invData.qty + productDetail.detail_qty;
              log.updated_at =
                  await CommunFun.getCurrentDateTime(DateTime.now());
              log.updated_by = userdata.id;
              updatedIntLog.add(log);
              var ulog =
                  await localAPI.updateStoreInvetoryLogTable(updatedIntLog);
            }
          }
        }
      }
    }

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
              Navigator.of(context).pop();
              returnPayment(mehtod);
            },
          );
        });
  }

  returnPayment(paymentMehtod) async {
    // TODO : update payment tables
    var orderid = await localAPI.updateOrderStatus(selectedOrder.app_id, 5);
    var payment = await localAPI.updatePaymentStatus(orderpayment[0].app_id, 5);
    var terID = await CommunFun.getTeminalKey();
    // TODO update store inventory
    setState(() {
      isRefunding = false;
    });
    getTansactionList();
    //CommunFun.showToast(context, "Refund table insert data.. work in progress");
  }

  deleteItemFormList(product) async {
    Orders order = selectedOrder;
    if (order.order_item_count > 1) {
      OrderDetail details = product;
      var subtotal = order.sub_total - details.product_price;
      var qty = order.order_item_count - details.detail_qty;
      var grandtotal = subtotal;
      order.sub_total = subtotal;
      order.order_item_count = qty.toInt();
      order.grand_total = grandtotal;
      var result = await localAPI.deleteOrderItem(product.app_id);
      var result1 = await localAPI.updateInvoice(order);
      setState(() {
        isRefunding = false;
      });
      getTansactionList();
      // Updated ORder table data
      // CommunFun.showToast(
      //     context, "Refund table insert data.. work in progress");
    } else {
      setState(() {
        isRefunding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      // drawer: transactionsDrawer(), // page Drawer
      body: SafeArea(
          child: new GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
          setState(() {
            isFiltering = false;
          });
        },
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
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Container(
                      //    padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                      height: MediaQuery.of(context).size.height,
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 10),
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
                                  size: SizeConfig.safeBlockVertical * 7,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(Strings.transaction,
                                  style: Styles.drawerText()),
                            ],
                          ),
                          SizedBox(height: 10),
                          transationsSearchBox(),
                          SizedBox(height: 5),
                          orderLists.length > 0
                              ? searchTransationList()
                              : Center(
                                  child: Text(Strings.no_order_found,
                                      style: Styles.darkBlue()))
                        ],
                      ),
                    ),
                  ),
                ),
                TableCell(
                  // Part 2 transactions list
                  child: Center(
                      child: orderLists.length > 0
                          ? SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 50),
                                      // height:
                                      //     MediaQuery.of(context).size.height / 2,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(height: 10),
                                            Text(orderDate,
                                                style:
                                                    Styles.whiteMediumBold()),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              selectedOrder.grand_total != null
                                                  ? selectedOrder.grand_total
                                                      .toStringAsFixed(2)
                                                  : "",
                                              style: TextStyle(
                                                  fontSize: SizeConfig
                                                          .safeBlockVertical *
                                                      4,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .accentColor),
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
                                                    style:
                                                        Styles.whiteBoldsmall(),
                                                  )
                                                : SizedBox(),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              height:
                                                  SizeConfig.safeBlockVertical *
                                                      8,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Center(
                                                child: Text(
                                                  customer.firstName != null
                                                      ? customer.firstName
                                                      : "Walk-In Customer",
                                                  style: Styles.orangeSmall(),
                                                ),
                                              ),
                                              color: Colors.grey[900]
                                                  .withOpacity(0.4),
                                            ),
                                            productList(),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Positioned(
                                    //   bottom: 30,
                                    //   left: 0,
                                    //   right: 0,
                                    //   child:
                                    Container(
                                      // height:
                                      //     MediaQuery.of(context).size.height / 2,
                                      // color: StaticColor.backgroundColor,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 50),
                                      child: Column(children: <Widget>[
                                        Divider(),
                                        totalAmountValues(),
                                        Divider(),
                                        Column(
                                            children:
                                                orderpayment.map((payment) {
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: <Widget>[
                                              new Expanded(
                                                flex: 7,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    top: 0,
                                                  ),
                                                  child: Text(
                                                    paumentMethod.name != null
                                                        ? paumentMethod.name
                                                            .toUpperCase()
                                                        : "",
                                                    textAlign: TextAlign.end,
                                                    style: Styles.darkGray(),
                                                  ),
                                                ),
                                              ),
                                              new Expanded(
                                                flex: 3,
                                                child: Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 0,
                                                    ),
                                                    child: Text(
                                                      payment.op_amount != null
                                                          ? payment.op_amount
                                                              .toStringAsFixed(
                                                                  2)
                                                          : "00:00",
                                                      textAlign: TextAlign.end,
                                                      style: Styles.darkGray(),
                                                    )),
                                              )
                                            ],
                                          );
                                        }).toList()),
                                        isRefunding
                                            ? refundButtons(context)
                                            : permissions.contains(
                                                    Constant.DELETE_ORDER)
                                                ? transationsButton()
                                                : SizedBox()
                                      ]),
                                    ),
                                    // ),
                                  ])
                              // : Text(
                              //     "No Transations Found",
                              //     style: Styles.whiteBold(),
                              //   )
                              )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  height: 50,
                                ),
                                Text(
                                  Strings.no_order_found,
                                  style: Styles.whiteBold(),
                                ),
                              ],
                            )),
                )
              ]),
            ],
          ),
        ),
      )),
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
              size: SizeConfig.safeBlockVertical * 5,
            ),
          ),
          hintText: Strings.searchbox_hint,
          hintStyle: TextStyle(
              fontSize: SizeConfig.safeBlockVertical * 3,
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
          contentPadding: EdgeInsets.only(left: 20),
          fillColor: Colors.white,
        ),
        style: Styles.blackMediumBold(),
        onTap: () {
          startFilter();
        },
        onChanged: (e) {
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
              color: orderpayment[0].op_status == 1
                  ? Colors.white
                  : Colors.white38,
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
              color: orderpayment[0].op_status == 1
                  ? Colors.white
                  : Colors.white38,
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
          if (orderpayment[0].op_status == 1) {
            // refund ordr
            refundProcessStart();
          }
        }),
        SizedBox(width: 10),
        cancelButton(() {
          if (orderpayment[0].op_status == 1) {
            CommonUtils.showAlertDialog(context, () {
              Navigator.of(context).pop();
            }, () {
              Navigator.of(context).pop();
              showReasontypePop();
            },
                "Warning",
                "This action can not be undone. Do you want to avoid this transaction?",
                "Yes",
                "No",
                true);
          }
        }),
      ],
    );
  }

  Widget totalAmountValues() {
    return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            TableCell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new Expanded(
                    flex: 7,
                    child: Text(
                      Strings.sub_total.toUpperCase(),
                      textAlign: TextAlign.end,
                      style: Styles.darkGray(),
                    ),
                  ),
                  new Expanded(
                      flex: 3,
                      child: Padding(
                          padding: EdgeInsets.only(top: 0, bottom: 5),
                          child: Text(
                            selectedOrder.sub_total != null
                                ? selectedOrder.sub_total.toStringAsFixed(2)
                                : "00:00",
                            textAlign: TextAlign.end,
                            style: Styles.darkGray(),
                          ))),
                ],
              ),
            ),
          ]),
          TableRow(children: [
            TableCell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new Expanded(
                    flex: 7,
                    child: Text(
                      Strings.discount.toUpperCase(),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          fontSize: SizeConfig.safeBlockVertical * 2.8,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).accentColor),
                    ),
                  ),
                  new Expanded(
                      flex: 3,
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            selectedOrder.voucher_amount != null &&
                                    selectedOrder.voucher_amount.toString() !=
                                        '0.0'
                                ? selectedOrder.voucher_amount
                                    .toStringAsFixed(2)
                                : "00.00",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                fontSize: SizeConfig.safeBlockVertical * 2.8,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).accentColor),
                          ))),
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
                            new Expanded(
                              flex: 7,
                              child: Text(
                                Strings.tax.toUpperCase() +
                                    " " +
                                    taxitem["taxCode"] +
                                    "(" +
                                    taxitem["rate"] +
                                    "%)",
                                textAlign: TextAlign.end,
                                style: Styles.darkGray(),
                              ),
                            ),
                            new Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  child: Text(
                                      double.parse(taxitem["taxAmount"])
                                          .toStringAsFixed(2),
                                      textAlign: TextAlign.end,
                                      style: Styles.darkGray()),
                                ))
                          ]);
                    }).toList())
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                          new Expanded(
                            flex: 7,
                            child: Text(
                              Strings.tax.toUpperCase(),
                              textAlign: TextAlign.end,
                              style: Styles.darkGray(),
                            ),
                          ),
                          new Expanded(
                              flex: 3,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                    selectedOrder != null
                                        ? selectedOrder.tax_amount
                                            .toStringAsFixed(2)
                                        : 0.00,
                                    textAlign: TextAlign.end,
                                    style: Styles.darkGray()),
                              ))
                        ]),
            ),
          ]),
          TableRow(children: [
            TableCell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new Expanded(
                    flex: 7,
                    child: Text(
                      Strings.grand_total,
                      textAlign: TextAlign.end,
                      style: Styles.darkGray(),
                    ),
                  ),
                  new Expanded(
                      flex: 3,
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            selectedOrder.grand_total != null
                                ? selectedOrder.grand_total.toStringAsFixed(2)
                                : "00:00",
                            textAlign: TextAlign.end,
                            style: Styles.darkGray(),
                          ))),
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
              color: orderpayment.length > 0 && orderpayment[0].op_status == 1
                  ? Colors.white
                  : Colors.white38,
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
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: orderpayment.length > 0 && orderpayment[0].op_status == 1
                  ? Colors.white
                  : Colors.white38,
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
      //color: Colors.white,
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 0),
      // height: MediaQuery.of(context).size.height / 2,
      child: Column(
          children: orderItemList.map((product) {
        var index = orderItemList.indexOf(product);
        var item = orderItemList[index];
        print(item.product_detail);
        var producrdata = json.decode(item.product_detail);
        // print(producrdata);
        return InkWell(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Row(
                //  mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Hero(
                    tag: product.product_id,
                    child: Container(
                      height: SizeConfig.safeBlockVertical * 8,
                      width: SizeConfig.safeBlockVertical * 9,
                      decoration: new BoxDecoration(
                        color: Colors.greenAccent,
                      ),
                      child: producrdata["base64"] != ""
                          ? CommonUtils.imageFromBase64String(
                              producrdata["base64"])
                          : new Image.asset(
                              Strings.no_imageAsset,
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                            ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Flexible(
                    child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(producrdata["name"].toString().toUpperCase(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize:
                                          SizeConfig.safeBlockVertical * 2.8,
                                      color: Theme.of(context).primaryColor)),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(product.detail_qty.toString(),
                              style: TextStyle(
                                  fontSize: SizeConfig.safeBlockVertical * 2.8,
                                  color: Theme.of(context).primaryColor)),
                        ),
                        Expanded(
                            flex: 2,
                            child: Text(
                                product.product_price.toStringAsFixed(2),
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    fontSize:
                                        SizeConfig.safeBlockVertical * 2.8,
                                    color: Theme.of(context).primaryColor))),
                        // isRefunding
                        //     ? IconButton(
                        //         icon: Icon(
                        //           Icons.remove_circle_outline,
                        //           color: Colors.red,
                        //           size: SizeConfig.safeBlockVertical * 5,
                        //         ),
                        //         onPressed: () {
                        //           CommonUtils.showAlertDialog(context, () {
                        //             Navigator.of(context).pop();
                        //           }, () {
                        //             Navigator.of(context).pop();
                        //             deleteItemFormList(product);
                        //           },
                        //               "Alert",
                        //               "Are you sure you want to delete this item?",
                        //               "Yes",
                        //               "No",
                        //               true);
                        //           //deleteItemFormList(product);
                        //         })
                        //     : SizedBox(),
                      ],
                    ),
                  )
                ],
              ),
            ));
      }).toList()),
    );
  }

  Widget searchTransationList() {
    if (isFiltering) {
      return Expanded(
        child: ListView(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.only(left: 5, right: 5, bottom: 100),
          children: filterList.map((item) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              decoration: new BoxDecoration(
                  color: selectedOrder.app_id == item.app_id
                      ? Colors.grey[200]
                      : Colors.white),
              child: ListTile(
                contentPadding: EdgeInsets.all(0),
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
                        style: Styles.greysmall()),
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
                        : SizedBox(),
                    item.order_status == 5
                        ? Container(
                            padding: EdgeInsets.all(3),
                            color: Colors.red,
                            child: Text(
                              "Refunded",
                              style: Styles.whiteBoldsmall(),
                            ),
                          )
                        : SizedBox()
                  ],
                ),
                subtitle: Text(Strings.invoice + item.invoice_no.toString(),
                    style: Styles.greysmall()),
                isThreeLine: true,
                trailing: Text(
                  item.grand_total.toStringAsFixed(2),
                  style: Styles.greysmall(),
                ),
              ),
            );
          }).toList(),
        ),
      );
    } else {
      return Expanded(
        child: ListView(
          itemExtent: 65,
          padding: EdgeInsets.only(left: 5, right: 5, bottom: 100),
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          children: orderLists.map((item) {
            return Container(
                height: 100.0,
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                decoration: new BoxDecoration(
                    color: selectedOrder.app_id == item.app_id
                        ? Colors.grey[200]
                        : Colors.white),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
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
                          style: Styles.greysmall()),
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
                          : SizedBox(),
                      item.order_status == 5
                          ? Container(
                              padding: EdgeInsets.all(3),
                              color: Colors.red,
                              child: Text(
                                "Refunded",
                                style: Styles.whiteBoldsmall(),
                              ),
                            )
                          : SizedBox()
                    ],
                  ),
                  subtitle: Text(Strings.invoice + item.invoice_no.toString(),
                      style: Styles.greysmall()),
                  isThreeLine: true,
                  trailing: Text(item.grand_total.toStringAsFixed(2),
                      style: Styles.greysmall()),
                ));
          }).toList(),
        ),
      );
    }
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
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            ListTile(
                onTap: () {
                  widget.onClose("Incorrect Item");
                },
                title: Text(
                  "Incorrect Item",
                  style: Styles.communBlacksmall(),
                )),
            ListTile(
                onTap: () {
                  widget.onClose("Incorrect variant");
                },
                title: Text(
                  "Incorrect variant",
                  style: Styles.communBlacksmall(),
                )),
            ListTile(
                onTap: () {
                  widget.onClose("Incorrect payment type");
                },
                title: Text(
                  "Incorrect payment type",
                  style: Styles.communBlacksmall(),
                )),
            ListTile(
                onTap: () {
                  widget.onClose("Incorrect quantity");
                },
                title: Text(
                  "Incorrect quantity",
                  style: Styles.communBlacksmall(),
                )),
            ListTile(
                onTap: () {
                  widget.onClose("Other");
                },
                title: Text(
                  "Other",
                  style: Styles.communBlacksmall(),
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
        child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
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
      ),
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
