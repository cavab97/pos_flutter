import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/Table_order.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class WebOrderPages extends StatefulWidget {
  // Transactions list
  WebOrderPages({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _WebOrderPagesState createState() => _WebOrderPagesState();
}

class _WebOrderPagesState extends State<WebOrderPages>
    with SingleTickerProviderStateMixin {
  LocalAPI localAPI = LocalAPI();
  List<MST_Cart> onlineList = [];
  List<MST_Cart> offlineList = [];
  TabController _tabController;
  var permissions = "";
  @override
  void initState() {
    super.initState();
    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
    _tabController = new TabController(length: 2, vsync: this);
    getCartList();
    setPermissons();
  }

  setPermissons() async {
    var permission = await CommunFun.getPemission();
    setState(() {
      permissions = permission;
    });
  }

  getCartList() async {
    var branchid = await CommunFun.getbranchId();
    List<MST_Cart> cart = await localAPI.getCartList(branchid);
    if (cart.length > 0) {
      var offlineListitem = cart.where((x) => x.source != 1).toList();
      var onlineListitem = cart.where((x) => x.source == 1).toList();
      setState(() {
        offlineList = offlineListitem;
        onlineList = onlineListitem;
      });
    }
  }

  assignTable(cart) {
    Navigator.pushNamed(context, Constant.SelectTableScreen,
        arguments: {'isAssign': true, 'orderID': cart.id});
  }

  checkTableAssigned(cart) async {
    if (cart.table_id == null) {
      assignTable(cart);
    } else {
      List<Table_order> tableorder =
          await localAPI.getTableOrders(cart.table_id);
      if (tableorder.length > 0) {
        await Preferences.setStringToSF(
            Constant.TABLE_DATA, json.encode(tableorder[0]));
        Navigator.pushNamed(context, Constant.DashboardScreen);
      } else {
        assignTable(cart);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(
            Icons.arrow_back,
            size: 30.0,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black, size: 60),
        elevation: 0.0,
        title: Text(
          "Cart",
          style: Styles.blackBoldsmall(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          unselectedLabelColor: Colors.black,
          unselectedLabelStyle: Styles.blackBoldsmall(),
          indicator: BoxDecoration(color: Colors.deepOrange),
          labelColor: Colors.white,
          labelStyle: Styles.whiteBoldsmall(),
          tabs: [
            Tab(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "Online Orders",
                ),
              ),
            ),
            Tab(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "Offline Orders",
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: onlineListwidget()),
            Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: offlineListwidget()),
          ],
        ),
      ),
    );
  }

  Widget offlineListwidget() {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2.4;
    final double itemWidth = size.width / 4.2;
    return GridView.count(
      padding: EdgeInsets.all(20),
      shrinkWrap: true,
      childAspectRatio: (itemWidth / itemHeight),
      crossAxisCount: 6,
      children: offlineList.map((cart) {
        return InkWell(
          onTap: () {
            checkTableAssigned(cart);
          },
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          child: Container(
            width: itemHeight,
            height: itemWidth,
            margin: EdgeInsets.all(5),
            child: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: <Widget>[
                Hero(
                  tag: cart.id,
                  child: Container(
                    decoration: new BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0))),
                    width: MediaQuery.of(context).size.width,
                    height: itemHeight / 2,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 30),
                          Text(
                            "Open Customer",
                            style: Styles.blackBoldsmall(),
                          ),
                        ]),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: itemHeight / 2.5),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Sub Total:" + cart.sub_total.toString(),
                          style: Styles.whiteSimpleSmall()),
                      Text("Grand Total:" + cart.grand_total.toStringAsFixed(2),
                          style: Styles.whiteSimpleSmall())
                    ],
                  ),
                ),
                Positioned(
                    top: 10,
                    left: 10,
                    child: Text("Cart :" + cart.id.toString(),
                        style: Styles.blackBoldsmall()))
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget onlineListwidget() {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2.4;
    final double itemWidth = size.width / 4.2;
    return GridView.count(
      padding: EdgeInsets.all(20),
      shrinkWrap: true,
      childAspectRatio: (itemWidth / itemHeight),
      crossAxisCount: 6,
      children: onlineList.map((cart) {
        // List<TablesDetails> cartTable;
        // if (cart.table_id != null) {
        //   var branchid = CommunFun.getbranchId();
        //   cartTable = localAPI.getTableData(branchid, cart.table_id)
        //       as List<TablesDetails>;
        // }

        return InkWell(
          onTap: () {
            checkTableAssigned(cart);
          },
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          child: Container(
            width: itemHeight,
            height: itemWidth,
            margin: EdgeInsets.all(5),
            child: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: <Widget>[
                Hero(
                  tag: cart.id,
                  child: Container(
                    decoration: new BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0))),
                    width: MediaQuery.of(context).size.width,
                    height: itemHeight / 2,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 30),
                          Text(
                            "Open Customer",
                            style: Styles.blackBoldsmall(),
                          ),
                        ]),
                  ),
                ),
                permissions.contains(Constant.EDIT_ORDER) &&
                        cart.table_id == null
                    ? GestureDetector(
                        onTap: () {
                          checkTableAssigned(cart);
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: itemHeight / 2.1),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: cart.table_id == null
                                  ? Colors.deepOrange
                                  : Colors.grey,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20.0),
                                  bottomRight: Radius.circular(20.0))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                  cart.table_id == null
                                      ? "Assing Table"
                                      : "Table id",
                                  style: Styles.whiteSimpleSmall())
                            ],
                          ),
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.only(top: itemHeight / 2.1),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Grand Total : " + cart.grand_total.toStringAsFixed(2),
                                style: Styles.whiteSimpleSmall())
                          ],
                        ),
                      ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Text(
                    "Cart :" + cart.id.toString(),
                    style: Styles.blackBoldsmall(),
                  ),
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
