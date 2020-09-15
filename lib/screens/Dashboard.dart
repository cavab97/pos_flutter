import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/models/Category.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/models/TableDetails.dart';
import 'package:mcncashier/models/Table_order.dart';
import 'package:mcncashier/models/saveOrder.dart';
import 'package:mcncashier/screens/InvoiceReceipt.dart';
import 'package:mcncashier/screens/OpningAmountPop.dart';
import 'package:mcncashier/screens/ProductQuantityDailog.dart';
import 'package:mcncashier/screens/SearchCustomer.dart';
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
  List<ProductDetails> productList = new List<ProductDetails>();
  List<MSTCartdetails> cartList = new List<MSTCartdetails>();
  bool isDrawerOpen = false;
  bool isShiftOpen = false;
  bool isTableSelected = false;
  Table_order selectedTable;
  double subtotal = 0;
  double discount = 0;
  double tax = 0;
  double grandTotal = 0;
  int current_cart;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    checkisInit();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    checkshift();
    checkidTableSelected();
  }

  checkisInit() async {
    var isInit = await CommunFun.checkDatabaseExit();
    if (isInit == true) {
      await getCategoryList();
      await getCartItem();
    } else {
      await databaseHelper.initializeDatabase();
      await getCategoryList();
      await getCartItem();
    }
  }

  checkidTableSelected() async {
    var tableid = await Preferences.getStringValuesSF(Constant.TABLE_DATA);
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    if (tableid != null) {
      var tableddata = json.decode(tableid);
      Table_order table = Table_order.fromJson(tableddata);
      List<TablesDetails> tabledata =
          await localAPI.getTableData(branchid, table.table_id);
      table.save_order_id = tabledata[0].saveorderid;
      setState(() {
        isTableSelected = true;
        selectedTable = table;
      });
      if (selectedTable.save_order_id != null &&
          selectedTable.save_order_id != 0) {
        getCurrentCart();
      }
    }
  }

  getCurrentCart() async {
    List<SaveOrder> currentOrder =
        await localAPI.getSaveOrder(selectedTable.save_order_id);
    print(currentOrder);
    if (currentOrder.length != 0) {
      setState(() {
        current_cart = currentOrder[0].cartId;
      });
    }
  }

  checkshift() async {
    var isOpen = await Preferences.getStringValuesSF(Constant.IS_SHIFT_OPEN);
    setState(() {
      isShiftOpen = isOpen != null && isOpen == "true" ? true : false;
    });
    if (isShiftOpen) {
      getCartItem();
    }
  }

  getCartItem() async {
    List<MSTCartdetails> cartItem = await localAPI.getCartItem();
    if (cartItem.length > 0) {
      setState(() {
        cartList = cartItem;
      });
      countTotals();
    }
  }

  countTotals() {
    var subTotal = 0.0;
    var dis = 0.0;
    var taxval = 0.0;
    var grandtotal = 0.0;
    for (var i = 0; i < cartList.length; i++) {
      var cart = cartList[i];
      subTotal += cart.productPrice * cart.productQty;
      dis += cart.discount;
      taxval += cart.taxValue;
      grandtotal = (subtotal + tax) - discount;
    }
    setState(() {
      subtotal = subTotal;
      discount = dis;
      tax = taxval;
      grandTotal = grandtotal;
    });
  }

  void selectOption(choice) {
    // Causes the app to rebuild with the new _selectedChoice.

    switch (choice) {
      case 0:
        break;
    }
  }

  getCategoryList() async {
    List<Category> categorys = await localAPI.getAllCategory();
    print(categorys);
    setState(() {
      tabsList = categorys;
      _tabController = TabController(vsync: this, length: tabsList.length);
      _tabController.addListener(_handleTabSelection);
      getProductList(0);
    });
  }

  getProductList(int position) async {
    setState(() {
      isLoading = true;
    });
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    List<ProductDetails> product = await localAPI.getProduct(
        tabsList[position].categoryId.toString(), branchid);
    setState(() {
      productList.clear();
      productList = product;
      isLoading = false;
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
            sendOpenShft(ammount);
          });
        });
  }

  sendOpenShft(ammount) async {
    setState(() {
      isShiftOpen = true;
    });
    Preferences.setStringToSF(Constant.IS_SHIFT_OPEN, isShiftOpen.toString());
    Shift shift = new Shift();
    shift.appId = 1;
    shift.branchId = 1;
    shift.startAmount = int.parse(ammount);
    shift.endAmount = 0;
    shift.updatedAt = await CommunFun.getCurrentDateTime(DateTime.now());
    shift.updatedBy = 1;
    var result = await localAPI.insertShift(shift);
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

  showQuantityDailog(product) async {
    // Increase Decrease Quantity popup
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProductQuantityDailog(product: product, cartID: current_cart);
        });
  }

  openSendReceiptPop() {
    // Send receipt Popup
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return InvoiceReceiptDailog();
        });
  }

  opneShowAddCustomerDailog() {
    // Send receipt Popup
    showDialog(
        context: context,
        barrierDismissible: false,
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
          return new Tab(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  tabsList[index].name.toUpperCase(),
                  style: Styles.whiteBoldsmall(),
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
                          isLoading ? porductsListLoading() : porductsList(),
                        ],
                      ),
                    ),
                  ),
                  TableCell(
                      child: Stack(
                    fit: StackFit.loose,
                    children: <Widget>[
                      Container(
                        color: Colors.white,
                        child: cartITems(),
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

  Widget checkoutbtn() {
    return RaisedButton(
      padding: EdgeInsets.only(left: 10, right: 10),
      onPressed: () {
        Navigator.pushNamed(context, Constant.PINScreen);
        //  Preferences.removeSinglePref(Constant.TERMINAL_KEY);
      },
      child: Text(
        Strings.checkout,
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      color: Colors.deepOrange,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
    );
  }

  Widget nameBtn() {
    return RaisedButton(
      padding: EdgeInsets.only(left: 10, right: 10),
      onPressed: () {
        Navigator.pushNamed(context, Constant.PINScreen);
        //  Preferences.removeSinglePref(Constant.TERMINAL_KEY);
      },
      child: Text(
        "Admin",
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      color: Colors.deepOrange,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
    );
  }

  Widget drawerWidget() {
    return Drawer(
      child: Container(
          padding: EdgeInsets.only(top: 30),
          color: Colors.white,
          child: ListView(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[checkoutbtn(), nameBtn()],
              ),
              CommunFun.divider(),
              ListTile(
                  leading: Icon(
                    Icons.art_track,
                    color: Colors.black,
                    size: 30,
                  ),
                  title: Text("Transaction", style: Styles.communBlack())),
              ListTile(
                  leading: Icon(
                    Icons.open_in_new,
                    color: Colors.black,
                    size: 30,
                  ),
                  title: Text("Open Shift", style: Styles.communBlack())),
              ListTile(
                  leading: Icon(
                    Icons.filter_tilt_shift,
                    color: Colors.black,
                    size: 30,
                  ),
                  title: Text("Shift Report", style: Styles.communBlack())),
              ListTile(
                  leading: Icon(
                    Icons.transform,
                    color: Colors.black,
                    size: 40,
                  ),
                  title: Text("Sync", style: Styles.communBlack())),
              ListTile(
                  onTap: () async {
                    await Preferences.removeSinglePref(Constant.LastSync_Table);
                    await CommunFun.syncAfterSuccess(context);
                  },
                  leading: Icon(
                    Icons.sync,
                    color: Colors.black,
                    size: 30,
                  ),
                  title: Text("Attendce System", style: Styles.communBlack())),
              ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: Colors.black,
                    size: 30,
                  ),
                  title: Text("Settings", style: Styles.communBlack())),
            ],
          )),
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
            selectedTable != null
                ? Row(
                    children: <Widget>[
                      Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        selectedTable.number_of_pax.toString(),
                        style: Styles.whiteBoldsmall(),
                      ),
                    ],
                  )
                : SizedBox(),
            addCustomerBtn(context),
            menubutton(() {
              // opneMenuButton();
            })
          ],
        ));
  }

  Widget addCustomerBtn(context) {
    return RaisedButton(
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      onPressed: () {
        if (isShiftOpen) {
          opneShowAddCustomerDailog();
        } else {
          CommunFun.showToast(context, Strings.shift_open_message);
        }
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
    );
  }

  Widget menubutton(Function _onPress) {
    return PopupMenuButton(
        icon: Icon(
          Icons.more_horiz,
          color: Colors.pinkAccent,
        ),
        offset: Offset(0, 100),
        // onSelected: 0,
        onSelected: selectOption,
        itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 0,
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.save_alt,
                      color: Colors.white,
                      size: 30,
                    ),
                    Text("Save Order")
                  ],
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: 30,
                    ),
                    Text("Open Order"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: 30,
                    ),
                    Text("Split Order"),
                  ],
                ),
              ),
            ]);
  }

  Widget porductsListLoading() {
    // products List
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 1.6;
    final double itemWidth = size.width / 4.2;
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: 5),
      child: GridView.count(
          childAspectRatio: (itemWidth / itemHeight),
          crossAxisCount: 5,
          children: ['1', '2', '3', '4', '5'].map((i) {
            return InkWell(
              onTap: () {},
              child: Container(
                height: itemHeight,
                // padding: EdgeInsets.all(5),
                margin: EdgeInsets.all(5),
                child: Stack(
                  alignment: AlignmentDirectional.topCenter,
                  children: <Widget>[
                    Hero(
                        tag: i,
                        child: Container(
                          color: Colors.grey,
                          width: MediaQuery.of(context).size.width,
                          height: itemHeight / 2,
                          child: new Image.asset(
                            'assets/no_image.png',
                            fit: BoxFit.cover,
                          ),
                        )),
                    Container(
                      margin: EdgeInsets.only(top: itemHeight / 2.6),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "..",
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
                      top: itemHeight / 2.6 - 30,
                      left: 0,
                      child: Container(
                        height: 30,
                        width: 50,
                        padding: EdgeInsets.all(5),
                        color: Colors.deepOrange,
                        child: Center(
                          child: Text(
                            "...",
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
          }).toList()),
    );
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
          var image_Arr = product.base64.split(" groupconcate_Image ");
          return InkWell(
            onTap: () {
              if (isShiftOpen) {
                if (isTableSelected) {
                  showQuantityDailog(product);
                } else {
                  selectTable();
                }
              } else {
                CommunFun.showToast(context, Strings.shift_open_message);
              }
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
                        color: Colors.grey,
                        width: MediaQuery.of(context).size.width,
                        height: itemHeight / 2,
                        child: image_Arr.length != 0 && image_Arr[0] != ""
                            ? CommonUtils.imageFromBase64String(image_Arr[0])
                            : new Image.asset(
                                'assets/no_image.png',
                                fit: BoxFit.cover,
                              ),
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
                          style: Styles.whiteSimpleSmall(),
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
        height: 60,
        width: 300,
        child: RaisedButton(
          padding: EdgeInsets.only(top: 10, bottom: 5),
          onPressed: () {
            Navigator.pushNamed(context, Constant.TransactionScreen);
          },
          child: Text(
            Strings.title_pay,
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          color: Colors.deepOrange,
          textColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
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
                SizedBox(height: 20),
                Text(
                  Strings.closed,
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
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
      padding: EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 20),
      onPressed: onPress,
      child: Text(
        Strings.open_shift,
        style: TextStyle(color: Colors.deepOrange, fontSize: 25),
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(
            width: 1, style: BorderStyle.solid, color: Colors.deepOrange),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  Widget cartITems() {
    // selected item list and total price calculations
    final carttitle = Table(
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
          TableRow(children: [
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
              child: Text(Strings.header_name, style: Styles.darkBlue()),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Text(Strings.qty, style: Styles.darkBlue()),
            ),
            Padding(
              padding: EdgeInsets.only(right: 0, top: 10, bottom: 10),
              child: Text(Strings.amount, style: Styles.darkBlue()),
            ),
          ])
        ]);

    final cartTable = ListView(
      shrinkWrap: true,
      children: ListTile.divideTiles(
        context: context,
        tiles: cartList.map((cart) {
          return new SlideMenu(
            child: new ListTile(
              title: new Container(
                  child: new Row(children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                  child: Text(
                    cart.productName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      cart.productQty.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    )),
                Padding(
                    padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                    child: Text(
                      cart.productPrice.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    )),
              ])),
            ),
            menuItems: <Widget>[
              new Container(
                child: new IconButton(
                  icon: new Icon(Icons.delete),
                ),
              ),
              new Container(
                child: new IconButton(
                  icon: new Icon(Icons.info),
                ),
              ),
            ],
          );
        }),
      ).toList(),
    );
    /* Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: TableBorder(
                bottom: BorderSide(
                    width: 1,
                    color: Colors.grey[400],
                    style: BorderStyle.solid),
                horizontalInside: BorderSide(
                    width: 1,
                    color: Colors.grey[400],
                    style: BorderStyle.solid)),
            columnWidths: {
              0: FractionColumnWidth(.6),
              1: FractionColumnWidth(.2),
              2: FractionColumnWidth(.2),
            },
            children: cartList.map((cart) {
              return TableRow(children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                  child: Text(
                    cart.productName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      cart.productQty.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    )),
                Padding(
                    padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                    child: Text(
                      cart.productPrice.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    )),
              ]);
            }).toList());*/

    final totalPriceTable = Table(
        border: TableBorder(
            top: BorderSide(
                width: 1, color: Colors.grey[400], style: BorderStyle.solid),
            horizontalInside: BorderSide(
                width: 1, color: Colors.grey[400], style: BorderStyle.solid)),
        children: [
          TableRow(children: [
            TableCell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(Strings.sub_total.toUpperCase(),
                      style: Styles.darkBlue()),
                  Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child:
                          Text(subtotal.toString(), style: Styles.darkBlue())),
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
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      discount.toString(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).accentColor),
                    ),
                  ),
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
                      style: Styles.darkBlue(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(tax.toString(), style: Styles.darkBlue()),
                  ),
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
                    child: Text(Strings.grand_total, style: Styles.darkBlue()),
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                      ),
                      child: Text(grandTotal.toString(),
                          style: Styles.darkBlue())),
                ],
              ),
            ),
          ]),
        ]);

    return Column(
      children: <Widget>[
        Container(
            height: MediaQuery.of(context).size.height / 1.4,
            width: MediaQuery.of(context).size.width,
            color: Colors.grey[300],
            padding: EdgeInsets.all(10),
            child: Stack(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width / 1.2,
                  color: Colors.white,
                  child: carttitle,
                ),
                Container(
                    //color: Colors.white,
                    height: MediaQuery.of(context).size.height / 2.4,
                    margin: EdgeInsets.only(top: 50),
                    child: SingleChildScrollView(child: cartTable)),
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(child: totalPriceTable))
              ],
            )),
      ],
    );
  }
}

class SlideMenu extends StatefulWidget {
  final Widget child;
  final List<Widget> menuItems;

  SlideMenu({this.child, this.menuItems});

  @override
  _SlideMenuState createState() => new _SlideMenuState();
}

class _SlideMenuState extends State<SlideMenu>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  initState() {
    super.initState();
    _controller = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = new Tween(
            begin: const Offset(0.0, 0.0), end: const Offset(-0.2, 0.0))
        .animate(new CurveTween(curve: Curves.decelerate).animate(_controller));

    return new GestureDetector(
      onHorizontalDragUpdate: (data) {
        // we can access context.size here
        setState(() {
          _controller.value -= data.primaryDelta / context.size.width;
        });
      },
      onHorizontalDragEnd: (data) {
        if (data.primaryVelocity > 2500)
          _controller
              .animateTo(.0); //close menu on fast swipe in the right direction
        else if (_controller.value >= .5 ||
            data.primaryVelocity <
                -2500) // fully open if dragged a lot to left or on fast swipe to left
          _controller.animateTo(1.0);
        else // close if none of above
          _controller.animateTo(.0);
      },
      child: new Stack(
        children: <Widget>[
          new SlideTransition(position: animation, child: widget.child),
          new Positioned.fill(
            child: new LayoutBuilder(
              builder: (context, constraint) {
                return new AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return new Stack(
                      children: <Widget>[
                        new Positioned(
                          right: .0,
                          top: .0,
                          bottom: .0,
                          width: constraint.maxWidth * animation.value.dx * -1,
                          child: new Container(
                            color: Colors.black26,
                            child: new Row(
                              children: widget.menuItems.map((child) {
                                return new Expanded(
                                  child: child,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
