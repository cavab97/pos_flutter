import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/models/Category.dart';
import 'package:mcncashier/models/Product.dart';
import 'package:mcncashier/models/Product_Categroy.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/screens/InvoiceReceipt.dart';
import 'package:mcncashier/screens/OpningAmountPop.dart';
import 'package:mcncashier/screens/ProductQuantityDailog.dart';
import 'package:mcncashier/screens/SearchCustomer.dart';
import 'package:mcncashier/screens/SelectTable.dart';
import 'package:mcncashier/services/CommunAPICall.dart';
import 'package:mcncashier/services/LocalAPIs.dart';

class DashboradPage extends StatefulWidget {
  // main Product list page
  DashboradPage({Key key}) : super(key: key);

  @override
  _DashboradPageState createState() => _DashboradPageState();
}

class _DashboradPageState extends State<DashboradPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  GlobalKey<ScaffoldState> scaffoldKey;
  LocalAPI localAPI = LocalAPI();
  List<Category> tabsList = new List<Category>();
  List<Product> productList = new List<Product>();
  bool isDrawerOpen = false;
  bool isShiftOpen = false;
  @override
  void initState() {
    super.initState();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    checkshift();
    getCategoryList();
  }

  checkshift() async {
    // var isOpen = await Preferences.getBoolValuesSF(Constant.IS_SHIFT_OPEN);
    // setState(() {
    //   isShiftOpen = isOpen != null ? isOpen : false;
    // });
  }

  getCategoryList() async {
    List<Category> categorys = await localAPI.getAllCategory();
    setState(() {
      tabsList = categorys;
      _tabController = TabController(vsync: this, length: tabsList.length);
      _tabController.addListener(_handleTabSelection);
      getProductList(0);
    });
  }

  getProductList(int position) async {
    List<Product> product =
        await localAPI.getProduct(tabsList[position].categoryId.toString());

    print(product.length);

    setState(() {
      productList.clear();
      productList = product;

      //if (productList.length > 0) {
      /* productList.forEach((element) {
          print("product");
          print(localAPI.getProductImage(element.productId.toString()));
        });*/
      //}
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      getProductList(_tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  openOpningAmmountPop() {
    showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return OpeningAmmountPage(onEnter: (ammount) {
            print(ammount);
            sendOpenShft(ammount);
          });
        });
  }

  sendOpenShft(ammount) async {
    setState(() {
      isShiftOpen = true;
    });
    //g Preferences.setBoolToSF(Constant.IS_SHIFT_OPEN, isShiftOpen);
    Shift shift = new Shift();
    shift.appId = 1;
    shift.branchId = 1;
    shift.startAmount = ammount;
    shift.endAmount = 0;
    shift.updatedAt = "2020-09-09 06:43:09";
    shift.updatedBy = 1;
    var result = await localAPI.insertShift(shift);
    print(result);
    //if (result == 1) {

    //}
  }

  openDrawer() {
    // Drawer Open close event
    if (isDrawerOpen) {
      // Navigator.of(context).pop();
    } else {
      scaffoldKey.currentState.openDrawer();
    }
    setState(() {
      isDrawerOpen = !isDrawerOpen;
    });
  }

  showQuantityDailog() async {
    // Increase Decrease Quantity popup
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ProductQuantityDailog();
        });
  }

  openSendReceiptPop() {
    // Send receipt Popup
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return InvoiceReceiptDailog();
        });
  }

  opneShowAddCustomerDailog() {
    // Send receipt Popup
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SearchCustomerPage();
        });
  }

  selectTable() {
    Navigator.pushNamed(context, Constant.SelectTableScreen);
  }

  @override
  Widget build(BuildContext context) {
    // Categrory Tabs
    final _tabs = TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.label,
        unselectedLabelColor: Colors.white,
        labelColor: Colors.white,
        isScrollable: true,
        indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: Colors.deepOrange),
        labelStyle: TextStyle(fontSize: 16),
        tabs: List<Widget>.generate(tabsList.length, (int index) {
          print(tabsList[0].name);
          return new Tab(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  tabsList[index].name.toUpperCase(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
          );
        }));
    return Scaffold(
        key: scaffoldKey,
        drawer: drawerWidget(),
        body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Table(
              border: TableBorder.all(color: Colors.white, width: 0.6),
              columnWidths: {
                0: FractionColumnWidth(.6),
                1: FractionColumnWidth(.3),
              },
              children: [
                TableRow(children: [
                  TableCell(child: tableHeader1()),
                  TableCell(child: tableHeader2()),
                ]),
                TableRow(children: [
                  TableCell(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 5, right: 5),
                            width: MediaQuery.of(context).size.width,
                            height: 65,
                            color: Colors.black26,
                            padding: EdgeInsets.all(10),
                            child: DefaultTabController(
                                initialIndex: 0,
                                length: tabsList.length,
                                child: _tabs),
                          ),
                          porductsList(),
                        ],
                      ),
                    ),
                  ),
                  TableCell(
                      child: Stack(
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      cartITems(),
                      SizedBox(
                        height: 10,
                      ),
                      paybutton(context),
                      !isShiftOpen ? openShiftButton(context) : SizedBox()
                    ],
                  )),
                ]),
              ],
            ),
          ),
        ));
  }

  Widget drawerWidget() {
    return Drawer(
      child: Container(
        padding: EdgeInsets.only(top: 30),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            RaisedButton(
              padding:
                  EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
              onPressed: () {
                Navigator.pushNamed(context, Constant.TerminalScreen);
                Preferences.removeSinglePref(Constant.TERMINAL_KEY);
              },
              child: Text(
                Strings.logout,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              color: Colors.deepOrange,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tableHeader1() {
    // products Header part 1
    return Container(
      height: 80,
      padding: EdgeInsets.only(left: 10, right: 10),
      width: MediaQuery.of(context).size.width / 3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              GestureDetector(
                  onTap: () {
                    openDrawer();
                  },
                  child: Icon(
                    Icons.dehaze,
                    color: Colors.white,
                    size: 40,
                  )),
              SizedBox(width: 20),
              SizedBox(
                height: 50.0,
                child: Image.asset(
                  "assets/headerlogo.png",
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width / 3.8,
            child: TextField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: 25),
                  child: Icon(
                    Icons.search,
                    color: Colors.deepOrange,
                    size: 40,
                  ),
                ),
                hintText: Strings.search_bar_text,
                hintStyle: TextStyle(fontSize: 18.0, color: Colors.black),
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
              onChanged: (e) {
                print(e);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget tableHeader2() {
    // products Header part 2
    return Container(
        padding: EdgeInsets.only(left: 10, right: 20),
        height: 80,
        // color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 40,
            ),
            RaisedButton(
              padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              onPressed: () {
                opneShowAddCustomerDailog(); //  Navigator.pushNamed(context, Constant.TransactionScreen);
              },
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 30,
                  ),
                  SizedBox(width: 5),
                  Text(Strings.btn_Add_customer,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      )),
                ],
              ),
              color: Colors.deepOrange,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
            )
          ],
        ));
  }

  Widget porductsList() {
    // products List
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 4.2;
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: 5),
      child: GridView.count(
        childAspectRatio: (itemWidth / itemHeight),
        crossAxisCount: 4,
        children: productList.map((product) {
          return InkWell(
            onTap: () {
              selectTable();
              //showQuantityDailog();
            },
            child: Container(
              height: itemHeight,
              // padding: EdgeInsets.all(5),
              margin: EdgeInsets.all(5),
              child: Stack(
                alignment: AlignmentDirectional.topCenter,
                children: <Widget>[
                  Hero(
                      tag: product.productId,
                      child: Container(
                        decoration: new BoxDecoration(
                          color: Colors.grey,
                          image: DecorationImage(
                              image: AssetImage("assets/image1.jfif"),
                              fit: BoxFit.cover),
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: itemHeight / 2,
                        child: Center(),
                      )),
                  Container(
                    margin: EdgeInsets.only(top: itemHeight / 2),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          product.name.toString().toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: itemHeight / 2 - 30,
                    left: 0,
                    child: Container(
                      height: 30,
                      width: 50,
                      padding: EdgeInsets.all(5),
                      color: Colors.deepOrange,
                      child: Center(
                        child: Text(
                          product.price.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              fontSize: 15),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget paybutton(context) {
    // Payment button
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 1.3),
        height: 70,
        width: 320,
        child: CommunFun.roundedButton(
          Strings.title_pay,
          () {
            //  openOpningAmmountPop();
            Navigator.pushNamed(context, Constant.TransactionScreen);
          },
        ),
      ),
    );
  }

  Widget openShiftButton(context) {
    // Payment button
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: Center(
        child: Container(
            color: Colors.white.withOpacity(0.7),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  Strings.shiftTextLable,
                  style: TextStyle(fontSize: 30),
                ),
                SizedBox(height: 40),
                shiftbtn(() {
                  openOpningAmmountPop();
                })
              ],
            )),
      ),
    );
  }

  Widget shiftbtn(Function onPress) {
    return RaisedButton(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
      onPressed: onPress,
      child: Text(
        Strings.open_shift,
        style: TextStyle(color: Colors.white, fontSize: 25),
      ),
      color: Colors.deepOrange,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  Widget cartITems() {
    // selected item list and total price calculations
    final cartTable = Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder(
            horizontalInside: BorderSide(
                width: 1, color: Colors.grey, style: BorderStyle.solid)),
        columnWidths: {
          0: FractionColumnWidth(.6),
          1: FractionColumnWidth(.2),
          2: FractionColumnWidth(.2),
        },
        children: [
          TableRow(decoration: BoxDecoration(color: Colors.white), children: [
            Padding(
                padding: EdgeInsets.only(left: 10, top: 20, bottom: 20),
                child: Text(
                  Strings.header_name,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff100c56)),
                )),
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Text(
                Strings.qty,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff100c56)),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 10, top: 20, bottom: 20),
              child: Text(
                Strings.amount,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff100c56)),
              ),
            )
          ]),
          TableRow(children: [
            Padding(
                padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                child: Text("PIZZA")),
            Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text("5.00")),
            Padding(
                padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                child: Text("20.00")),
          ]),
          TableRow(children: [
            Padding(
                padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                child: Text("APPLE")),
            Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text("5.00")),
            Padding(
                padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                child: Text("10.00")),
          ]),
        ]);
    final totalPriceTable = Table(
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
                        color: Color(0xff100c56)),
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        "150:00",
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xff100c56)),
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
                        "00:00",
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
                            color: Color(0xff100c56)),
                      )),
                  Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        "100:00",
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xff100c56)),
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
                          color: Color(0xff100c56)),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                      ),
                      child: Text(
                        "150.00",
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xff100c56)),
                      )),
                ],
              ),
            ),
          ]),
        ]);

    // final totalPriceTable = Table(
    //     defaultVerticalAlignment: TableCellVerticalAlignment.middle,
    //     border: TableBorder(
    //         horizontalInside: BorderSide(
    //             width: 1, color: Colors.grey, style: BorderStyle.solid)),
    //     children: [

    //       TableRow(children: [
    //         TableCell(
    //           child: Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceAround,
    //             children: <Widget>[
    //               new Text('ID'),
    //               new Text('Value'),
    //             ],
    //           ),
    //         ),
    //       ]),
    //       // TableRow(children: [
    //       //   TableCell(
    //       //       child: Row(
    //       //     children: <Widget>[
    //       //       Padding(
    //       //         padding: EdgeInsets.only(top: 10, bottom: 10),
    //       //         child: Text(
    //       //           Strings.sub_total.toUpperCase(),
    //       //           style: TextStyle(
    //       //               fontSize: 18,
    //       //               fontWeight: FontWeight.w700,
    //       //               color: Color(0xff100c56)),
    //       //         ),
    //       //       ),
    //       //       Padding(
    //       //           padding: EdgeInsets.only(top: 10, bottom: 10),
    //       //           child: Text(
    //       //             "00:00",
    //       //             style: TextStyle(
    //       //                 fontWeight: FontWeight.w700, color: Color(0xff100c56)),
    //       //           )),
    //       //     ],
    //       //   ))
    //       // ]),
    //       TableRow(children: [
    //         Padding(
    //             padding: EdgeInsets.only(top: 10, bottom: 10),
    //             child: Text(
    //               Strings.discount.toUpperCase(),
    //               style: TextStyle(
    //                   fontSize: 18,
    //                   fontWeight: FontWeight.w700,
    //                   color: Theme.of(context).accentColor),
    //             )),
    //         Padding(
    //             padding: EdgeInsets.only(top: 10, bottom: 10),
    //             child: Text(
    //               "00:00",
    //               style: TextStyle(
    //                   fontWeight: FontWeight.w700,
    //                   color: Theme.of(context).accentColor),
    //             )),
    //       ]),
    //       TableRow(children: [
    //         Padding(
    //             padding: EdgeInsets.only(top: 10, bottom: 10),
    //             child: Text(
    //               Strings.tax.toUpperCase(),
    //               style: TextStyle(
    //                   fontSize: 18,
    //                   fontWeight: FontWeight.w700,
    //                   color: Color(0xff100c56)),
    //             )),
    //         Padding(
    //             padding: EdgeInsets.only(top: 10, bottom: 10),
    //             child: Text(
    //               "00:00",
    //               style: TextStyle(
    //                   fontWeight: FontWeight.w700, color: Color(0xff100c56)),
    //             )),
    //       ]),
    //       TableRow(children: [
    //         Padding(
    //           padding: EdgeInsets.only(top: 10, bottom: 10),
    //           child: Text(
    //             Strings.grand_total,
    //             style: TextStyle(
    //                 fontSize: 18,
    //                 fontWeight: FontWeight.w700,
    //                 color: Color(0xff100c56)),
    //           ),
    //         ),
    //         Padding(
    //             padding: EdgeInsets.only(top: 10, bottom: 10),
    //             child: Text(
    //               "150.00",
    //               style: TextStyle(
    //                   fontWeight: FontWeight.w700, color: Color(0xff100c56)),
    //             )),
    //       ]),
    //     ]);

    return Container(
        //height: MediaQuery.of(context).size.height / 1.3,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            Container(
                height: MediaQuery.of(context).size.height / 1.4,
                color: Colors.grey[300],
                padding: EdgeInsets.all(10),
                child: Stack(
                  children: <Widget>[
                    cartTable,
                    Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(child: totalPriceTable))
                  ],
                )),
          ],
        ));
  }
}
