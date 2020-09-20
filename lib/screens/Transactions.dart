import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

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
  OrderPayment orderpayment = new OrderPayment();
  List<ProductDetails> detailsList = [];
  bool isFiltering = false;
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
    var terminalid = await Preferences.getStringValuesSF(Constant.TERMINAL_KEY);
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    List<Orders> orderList = await localAPI.getOrdersList(branchid, terminalid);
    if (orderList.length > 0) {
      setState(() {
        orderLists = orderList;
      });
    }
  }

  getOrderDetails(order) async {
    setState(() {
      selectedOrder = order;
    });
    List<ProductDetails> details = await localAPI.getOrderDetails(order.app_id);
    if (details.length > 0) {
      setState(() {
        detailsList = details;
      });
    }
    List<OrderPayment> orderpaymentdata =
        await localAPI.getOrderpaymentData(order.app_id);
    setState(() {
      orderpayment = orderpaymentdata[0];
    });
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
                              // Text("Wednesday, August 19",
                              //     style: TextStyle(
                              //         fontSize: 20,
                              //         fontWeight: FontWeight.bold,
                              //         color: Colors.blueGrey[900])),
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
                        child: orderLists.length > 0
                            ? Container(
                                width: MediaQuery.of(context).size.width / 2,
                                margin: EdgeInsets.only(top: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "Wen,August 19 09:53 PM",
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Text(
                                      orderpayment.op_amount.toString(),
                                      style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).accentColor),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Text(
                                      selectedOrder.invoice_no != null
                                          ? selectedOrder.invoice_no +
                                              " - Processed by OKDEE OKEY PROCESSED FORM"
                                          : " 0000000 - Processed by OKDEE OKEY PROCESSED FORM",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Container(
                                      height: 50,
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: Center(
                                        child: Text(
                                          "Aaron Young",
                                          style: TextStyle(
                                              fontSize: 23,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                      ),
                                      color: Colors.grey[900].withOpacity(0.4),
                                    ),
                                    productList(),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    totalAmountValues(),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    cancelButton(() {
                                      CommunFun.showToast(
                                          context, "Work in progress...");
                                      //Navigator.of(context).pop();
                                    }),
                                  ],
                                ),
                              )
                            : Container(
                                width: MediaQuery.of(context).size.width / 2,
                                margin: EdgeInsets.only(top: 5),
                                child: Center(
                                  child: Text(Strings.no_details_found,
                                      style: Styles.whiteBold()),
                                ),
                              ),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ));
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

  Widget totalAmountValues() {
    return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder(
            horizontalInside: BorderSide(
                width: 1, color: Colors.grey, style: BorderStyle.solid)),
        children: [
          TableRow(children: [
            TableCell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    Strings.sub_total.toUpperCase(),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey),
                  ),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        selectedOrder.voucher_amount.toString(),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        Strings.tax.toUpperCase(),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey),
                      )),
                  Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        selectedOrder.tax_amount != null
                            ? selectedOrder.tax_amount.toString()
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  Widget cancelButton(Function _onPress) {
    return RaisedButton(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
      onPressed: _onPress,
      child: Text(
        Strings.cancel_tansaction,
        style: TextStyle(color: Colors.white, fontSize: 25),
      ),
      color: Colors.deepOrange,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  Widget productList() {
    return Container(
      height: MediaQuery.of(context).size.height / 2.6,
      width: MediaQuery.of(context).size.width / 2,
      child: SingleChildScrollView(
        child: Column(
            children: detailsList.map((product) {
          var image_Arr = product.base64.split(" groupconcate_Image ");
          return InkWell(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Hero(
                      tag: product.productId,
                      child: Container(
                        height: 100,
                        width: 130,
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
                                Text(product.name.toString().toUpperCase(),
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
                          Text(product.qty.toString(),
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).primaryColor)),
                          SizedBox(width: 80),
                          Text(product.price.toString(),
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).primaryColor)),
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
    return ListView(
        shrinkWrap: true,
        children: orderLists.map((item) {
          return ListTile(
            onTap: () {
              getOrderDetails(item);
            },
            title: Text('09:34 PM',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600])),
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
          );
        }).toList());
  }
}
