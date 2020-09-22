import 'dart:convert';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
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
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/models/Voucher.dart';
import 'package:mcncashier/models/saveOrder.dart';
import 'package:mcncashier/screens/InvoiceReceipt.dart';
import 'package:mcncashier/screens/PrinterList.dart';
import 'package:mcncashier/screens/OpningAmountPop.dart';
import 'package:mcncashier/screens/PaymentMethodPop.dart';
import 'package:mcncashier/screens/ProductQuantityDailog.dart';
import 'package:mcncashier/screens/SearchCustomer.dart';
import 'package:mcncashier/screens/VoucherPop.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/services/allTablesSync.dart';

class DashboradPage extends StatefulWidget {
  // main Product list page
  DashboradPage({Key key}) : super(key: key);

  @override
  _DashboradPageState createState() => _DashboradPageState();
}

class _DashboradPageState extends State<DashboradPage>
    with TickerProviderStateMixin {
  GlobalKey<AutoCompleteTextFieldState<ProductDetails>> keyAutoSuggestion =
      new GlobalKey();
  AutoCompleteTextField searchTextField;
  TabController _tabController;
  TabController _subtabController;
  GlobalKey<ScaffoldState> scaffoldKey;
  LocalAPI localAPI = LocalAPI();
  List<Category> allCaterories = new List<Category>();
  List<Category> tabsList = new List<Category>();
  List<Category> subCatList = new List<Category>();
  List<ProductDetails> productList = new List<ProductDetails>();
  List<MSTCartdetails> cartList = new List<MSTCartdetails>();
  bool isDrawerOpen = false;
  bool isShiftOpen = false;
  var userDetails;
  bool isTableSelected = false;
  Table_order selectedTable;
  double subtotal = 0;
  double discount = 0;
  double tax = 0;
  List taxJson = [];
  double grandTotal = 0;
  MST_Cart allcartData;
  Voucher selectedvoucher;
  int currentCart;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    checkisInit();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    checkshift();
    checkidTableSelected();
    getUserData();
  }

  checkisInit() async {
    var isInit = await CommunFun.checkDatabaseExit();
    if (isInit == true) {
      await getCategoryList();
    } else {
      await databaseHelper.initializeDatabase();
      await getCategoryList();
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
    } else {
      clearCart();
    }
  }

  clearCart() {
    setState(() {
      cartList = [];
      selectedTable = null;
      grandTotal = 0.0;
      discount = 0.0;
      tax = 0.0;
      subtotal = 0.0;
      isTableSelected = false;
      currentCart = null;
    });
  }

  getCurrentCart() async {
    List<SaveOrder> currentOrder =
        await localAPI.getSaveOrder(selectedTable.save_order_id);
    print(currentOrder);
    if (currentOrder.length != 0) {
      setState(() {
        currentCart = currentOrder[0].cartId;
      });
      if (isShiftOpen) {
        getCartItem(currentCart);
      }
    }
  }

  syncOrdersTodatabase() async {
    await CommunFun.opneSyncPop(context);
    var res = await SyncAPICalls.syncOrderstoDatabase(context);
    print(res);
    await Navigator.of(context).pop();
  }

  checkshift() async {
    var isOpen = await Preferences.getStringValuesSF(Constant.IS_SHIFT_OPEN);
    setState(() {
      isShiftOpen = isOpen != null && isOpen == "true" ? true : false;
    });
  }

  getCartItem(cartId) async {
    List<MSTCartdetails> cartItem = await localAPI.getCartItem(cartId);
    if (cartItem.length > 0) {
      setState(() {
        cartList = cartItem;
      });
      countTotals(cartId);
    }
  }

  countTotals(cartId) async {
    MST_Cart cart = await localAPI.getCartData(cartId);
    // var subTotal = 0.0;
    // var dis = 0.0;
    // var taxval = 0.0;
    // var grandtotal = 0.0;
    // for (var i = 0; i < cartList.length; i++) {
    //   var cart = cartList[i];
    //   subTotal += cart.productPrice;
    //   dis += cart.discount;
    //   taxval = cart.taxValue;
    //   grandtotal = (subTotal + taxval) - dis;
    // }
    Voucher vaocher;
    if (cart.voucherId != null) {
      vaocher = await localAPI.getvoucher(cart.voucherId);
    }
    setState(() {
      allcartData = cart;
      subtotal = cart.sub_total;
      discount = cart.discount;
      tax = cart.tax;
      taxJson = json.decode(cart.tax_json);
      grandTotal = cart.grand_total;
      selectedvoucher = vaocher;
    });
  }

  getUserData() async {
    var user = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
    if (user != null) {
      user = json.decode(user);
      setState(() {
        userDetails = user;
      });
    }
  }

  closeTable() async {
    await Preferences.removeSinglePref(Constant.TABLE_DATA);
    checkidTableSelected();
    clearCart();
  }

  closeShift() {
    openOpningAmmountPop(Strings.title_closing_amount);
  }

  void selectOption(choice) {
    // Causes the app to rebuild with the new _selectedChoice.

    switch (choice) {
      case 0:
        closeTable();
        break;
      case 2:
        closeShift();
        break;
    }
  }

  getCategoryList() async {
    List<Category> categorys = await localAPI.getAllCategory();
    print(categorys);
    List<Category> catList = categorys.where((i) => i.parentId == 0).toList();
    setState(() {
      tabsList = catList;
      allCaterories = categorys;
    });
    _tabController = TabController(vsync: this, length: tabsList.length);
    _tabController.addListener(_handleTabSelection);

    getProductList(tabsList[0].categoryId);
  }

  _backtoMainCat() {
    setState(() {
      subCatList = [];
    });
    var cat = tabsList[_tabController.index].categoryId;
    getProductList(cat);
  }

  getProductList(categoryId) async {
    setState(() {
      isLoading = true;
    });
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    List<ProductDetails> product =
        await localAPI.getProduct(categoryId.toString(), branchid);

    setState(() {
      productList.clear();
      productList =
          product.length != 0 && product[0].productId != null ? product : [];
      isLoading = false;
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      var cat = tabsList[_tabController.index].categoryId;
      List<Category> subList =
          allCaterories.where((i) => i.parentId == cat).toList();
      setState(() {
        subCatList = subList;
      });
      _subtabController =
          new TabController(vsync: this, length: subCatList.length);
      _subtabController.addListener(_handleSubTabSelection);
      if (subCatList.length > 0) {
        cat = subCatList[_subtabController.index].categoryId;
      }
      getProductList(cat);
    }
  }

  void _handleSubTabSelection() {
    if (_subtabController.indexIsChanging) {
      var cat = subCatList[_subtabController.index].categoryId;
      getProductList(cat);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subtabController.dispose();
    super.dispose();
  }

  openOpningAmmountPop(isopning) {
    showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return OpeningAmmountPage(
              ammountext: isopning,
              onEnter: (ammountext) {
                sendOpenShft(ammountext);
              });
        });
  }

  openVoucherPop() {
    showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return VoucherPop(
            cartList: cartList,
            subTotal: subtotal,
            onEnter: (voucher) {
              if (voucher != null) {
                setState(() {
                  selectedvoucher = voucher;
                });
              }
              getCartItem(currentCart);
            },
          );
        });
  }

  // opneVoucherPop() async {
  //   // var customerData =
  //   //     await Preferences.getStringValuesSF(Constant.CUSTOMER_DATA);
  //   // if (customerData != null) {
  //   showDialog(
  //       // Opning Ammount Popup
  //       context: context,
  //       builder: (BuildContext context) {
  //         return VoucherApplyconfirmPop(
  //           onEnter: () {
  //             openVoucherPopFinal();
  //           },
  //           onCancel: () {
  //             sendPayment();
  //           },
  //         );
  //       });
  //   // } else {
  //   //   sendPayment();
  //   // }
  // }
  opnePrinterPop() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return PrinterListDailog(
              cartList: cartList,
              onPress: () {
                // TOTO : pring reicipt code
              });
        });
  }

  sendPayment() {
    if (cartList.length != 0) {
      opnePaymentMethod();
    } else {
      CommunFun.showToast(context, Strings.cart_empty);
    }
  }

  sendOpenShft(ammount) async {
    setState(() {
      isShiftOpen = true;
    });
    Preferences.setStringToSF(Constant.IS_SHIFT_OPEN, isShiftOpen.toString());
    var shiftid = await Preferences.getStringValuesSF(Constant.DASH_SHIFT);
    var terminalId = await Preferences.getStringValuesSF(Constant.TERMINAL_KEY);
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    User userdata = await CommunFun.getuserDetails();
    Shift shift = new Shift();
    shift.appId = int.parse(terminalId);
    shift.terminalId = int.parse(terminalId);
    shift.branchId = int.parse(branchid);
    shift.userId = userdata.id;
    shift.uuid = await CommunFun.getLocalID();
    shift.status = 1;
    if (shiftid == null) {
      shift.startAmount = int.parse(ammount);
    } else {
      shift.shiftId = int.parse(shiftid);
      shift.endAmount = int.parse(ammount);
    }
    shift.updatedAt = await CommunFun.getCurrentDateTime(DateTime.now());
    shift.updatedBy = userdata.id;
    var result = await localAPI.insertShift(shift);
    if (shiftid == null) {
      await Preferences.setStringToSF(Constant.DASH_SHIFT, result.toString());
    } else {
      await Preferences.removeSinglePref(Constant.DASH_SHIFT);
      await Preferences.removeSinglePref(Constant.IS_SHIFT_OPEN);
      checkshift();
      clearCart();
    }
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
          return ProductQuantityDailog(product: product, cartID: currentCart);
        });
  }

  openSendReceiptPop(orderID) {
    // Send receipt Popup
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return InvoiceReceiptDailog(orderid: orderID);
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

  opnePaymentMethod() {
    showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return PaymentMethodPop(
            cartID: currentCart,
            itemCount: cartList.length,
            subTotal: subtotal,
            grandTotal: grandTotal,
            onClose: (orderID) {
              openSendReceiptPop(orderID);
            },
          );
        });
  }

  itememovefromCart(cartitem) async {
    MST_Cart cart = new MST_Cart();
    MSTCartdetails cartitemdata = cartitem;
    cart = allcartData;
    cart.sub_total = allcartData.sub_total - cartitemdata.productPrice;
    cart.discount = allcartData.discount - cartitemdata.discount;
    cart.total_qty = allcartData.total_qty - cartitemdata.productQty;
    cart.grand_total = allcartData.grand_total - cartitemdata.productPrice;
    await localAPI.deleteCartItem(
        cartitem, currentCart, cart, cartList.length == 1);

    if (cartList.length > 1) {
      await getCartItem(currentCart);
    } else {
      setState(() {
        currentCart = null;
        cartList = [];
        grandTotal = 0.0;
        discount = 0.0;
        tax = 0.0;
        subtotal = 0.0;
      });
    }
  }

  editCartItem(cart) async {
    ProductDetails product;
    for (int i = 0; i < productList.length; i++) {
      if (productList[i].productId == cart.productId) {
        product = productList[i];
        await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return ProductQuantityDailog(
                  product: product, cartID: currentCart, iscartItem: cart);
            });
        return false;
      }
    }
  }

  selectTable() {
    Navigator.pushNamed(context, Constant.SelectTableScreen);
  }

  gotoTansactionPage() {
    Navigator.of(context).pop();
    Navigator.pushNamed(context, Constant.TransactionScreen);
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _willPopCallback() async {
      return false;
    }

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
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  tabsList[index].name.toUpperCase(),
                  style: Styles.whiteBoldsmall(),
                )),
          );
        }));
    final _subtabs = TabBar(
        controller: _subtabController,
        indicatorSize: TabBarIndicatorSize.label,
        unselectedLabelColor: Colors.white,
        labelColor: Colors.white,
        isScrollable: true,
        indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(30), color: Colors.deepOrange),
        labelStyle: TextStyle(fontSize: 16),
        tabs: List<Widget>.generate(subCatList.length, (int index) {
          return new Tab(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  subCatList[index].name.toUpperCase(),
                  style: Styles.whiteSimpleSmall(),
                )),
          );
        }));

    return WillPopScope(
      child: Scaffold(
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
                            subCatList.length == 0
                                ? Container(
                                    margin: EdgeInsets.only(left: 5, right: 5),
                                    width: MediaQuery.of(context).size.width,
                                    height: 65,
                                    color: Colors.black26,
                                    padding: EdgeInsets.all(10),
                                    child: DefaultTabController(
                                        initialIndex: 0,
                                        length: tabsList.length,
                                        child: _tabs),
                                  )
                                : Container(
                                    margin: EdgeInsets.only(left: 5, right: 5),
                                    width: MediaQuery.of(context).size.width,
                                    height: 65,
                                    color: Colors.black26,
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      children: <Widget>[
                                        IconButton(
                                            onPressed: _backtoMainCat,
                                            icon: Icon(
                                              Icons.arrow_back,
                                              color: Colors.white,
                                              size: 30,
                                            )),
                                        DefaultTabController(
                                            initialIndex: 0,
                                            length: subCatList.length,
                                            child: _subtabs),
                                      ],
                                    ),
                                  ),

                            // porductsListLoading() :
                            isLoading
                                ? CommunFun.loader(context)
                                : porductsList(),
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
          )),
      onWillPop: _willPopCallback,
    );
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
        userDetails != null ? userDetails["name"] : "",
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
                  onTap: () {
                    if (isShiftOpen) {
                      gotoTansactionPage();
                    } else {
                      CommunFun.showToast(context, Strings.shift_closed);
                    }
                  },
                  leading: Icon(
                    Icons.art_track,
                    color: Colors.black,
                    size: 30,
                  ),
                  title: Text("Transaction", style: Styles.communBlack())),
              ListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    if (isShiftOpen) {
                      closeShift();
                    } else {
                      openOpningAmmountPop(Strings.title_opening_amount);
                    }
                  },
                  leading: Icon(
                    Icons.open_in_new,
                    color: Colors.black,
                    size: 30,
                  ),
                  title: Text(isShiftOpen ? "Close Shift" : "Open Shift",
                      style: Styles.communBlack())),
              ListTile(
                  leading: Icon(
                    Icons.filter_tilt_shift,
                    color: Colors.black,
                    size: 30,
                  ),
                  title: Text("Shift Report", style: Styles.communBlack())),
              ListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    syncOrdersTodatabase();
                  },
                  leading: Icon(
                    Icons.transform,
                    color: Colors.black,
                    size: 40,
                  ),
                  title: Text("Sync Orders", style: Styles.communBlack())),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                  onPressed: () {
                    openDrawer();
                  },
                  icon: Icon(
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
              height: 70,
              margin: EdgeInsets.only(top: 15),
              width: MediaQuery.of(context).size.width / 3.8,
              child: new Column(
                children: <Widget>[
                  SimpleAutoCompleteTextField(
                    key: null,
                    suggestions: ["Apple", "Pizza", "mini Pizza"],
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(right: 25),
                        child: Icon(
                          Icons.search,
                          color: Colors.deepOrange,
                          size: 30,
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
                      contentPadding:
                          EdgeInsets.only(left: 20, top: 0, bottom: 0),
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(color: Colors.black, fontSize: 20.0),
                    // key: keyAutoSuggestion,
                  ),
                ],
              )

              //For single suggestion
              /*SimpleAutoCompleteTextField(
              suggestions: [
                "Apple",
                "Armidillo",
                "Actual",
                "Actuary",
                "America",
                "Apple",
                "Armidillo",
                "Actual",
                "Actuary",
                "America",
                "Argentina",
                "Australia",
                "Antarctica",
                "Blueberry",
              ],
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: 25),
                  child: Icon(
                    Icons.search,
                    color: Colors.deepOrange,
                    size: 30,
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
              style: TextStyle(color: Colors.black, fontSize: 20.0),
              key: keyAutoSuggestion,

            ),*/

              //Old one
              /*TextField(
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
            ),*/
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
          crossAxisAlignment: CrossAxisAlignment.center,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                addCustomerBtn(context),
                Padding(
                    padding: EdgeInsets.only(bottom: 15),
                    child: menubutton(() {
                      // opneMenuButton();
                    }))
              ],
            )
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
        icon: Icon(Icons.more_vert, color: Colors.white, size: 50),
        offset: Offset(0, 100),
        // onSelected: 0,
        onSelected: selectOption,
        itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 0,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 30,
                      ),
                      SizedBox(width: 20),
                      Text(Strings.close_table, style: Styles.communBlack())
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.call_split,
                        color: Colors.black,
                        size: 30,
                      ),
                      SizedBox(width: 20),
                      Text(Strings.split_order, style: Styles.communBlack()),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.call_split,
                        color: Colors.black,
                        size: 30,
                      ),
                      SizedBox(width: 20),
                      Text(Strings.close_shift, style: Styles.communBlack()),
                    ],
                  ),
                ),
              ),
            ]);
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
                      tag: product.productId != null ? product.productId : 0,
                      child: Container(
                        color: Colors.grey,
                        width: MediaQuery.of(context).size.width,
                        height: itemHeight / 2,
                        child: image_Arr.length != 0 && image_Arr[0] != ""
                            ? CommonUtils.imageFromBase64String(image_Arr[0])
                            : new Image.asset(
                                Strings.no_image,
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
                      // width: 50,
                      padding: EdgeInsets.all(5),
                      color: Colors.deepOrange,
                      child: Center(
                        child: Text(
                            product.hasInventory == 1 && product.qty == 0
                                ? Strings.out_of_stoke
                                : product.priceTypeName +
                                    ' ' +
                                    product.price.toString(),
                            style: Styles.whiteSimpleSmall()),
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
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 1.3 + 10),
            height: 50,
            width: 200,
            child: RaisedButton(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              onPressed: () {
                opnePrinterPop();
              },
              child: Text(
                "SEND",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              color: Colors.deepOrange,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 1.3 + 10),
            height: 50,
            width: 200,
            child: RaisedButton(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              onPressed: () {
                sendPayment();
              },
              child: Text(
                Strings.title_pay,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              color: Colors.deepOrange,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
          ),
        ]);
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
                  openOpningAmmountPop(Strings.title_opening_amount);
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
                  child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        cart.productName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Container(
                        // color: Colors.red,
                        width: MediaQuery.of(context).size.width / 8.2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
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
                                padding: EdgeInsets.only(
                                    right: 10, top: 10, bottom: 10),
                                child: Text(
                                  cart.productPrice.toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                )),
                          ],
                        ))
                  ])),
            ),
            menuItems: <Widget>[
              new Container(
                child: new IconButton(
                  onPressed: () {
                    itememovefromCart(cart);
                  },
                  icon: new Icon(Icons.delete, size: 30, color: Colors.red),
                ),
              ),
              new Container(
                child: new IconButton(
                  onPressed: () {
                    editCartItem(cart);
                  },
                  icon:
                      new Icon(Icons.edit, size: 30, color: Colors.deepOrange),
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
                      padding: EdgeInsets.only(right: 20, top: 10, bottom: 10),
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
                    padding: EdgeInsets.only(right: 20, top: 10, bottom: 10),
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
              child: taxJson.length != 0
                  ? Column(
                      children: taxJson.map((taxitem) {
                      return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              child: Text(
                                Strings.tax.toUpperCase() + " "+
                                    taxitem["taxName"] +
                                    "(" +
                                    taxitem["rate"] +
                                    "%)",
                                style: Styles.darkBlue(),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  right: 20, top: 10, bottom: 10),
                              child: Text(taxitem["taxAmount"].toString(),
                                  style: Styles.darkBlue()),
                            )
                          ]);
                    }).toList())
                  : Row(
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
                            padding:
                                EdgeInsets.only(right: 20, top: 10, bottom: 10),
                            child:
                                Text(tax.toString(), style: Styles.darkBlue()),
                          )
                        ]),
            ),
          ]),
          TableRow(children: [
            TableCell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(Strings.grand_total, style: Styles.darkBlue()),
                  ),
                  Padding(
                      padding: EdgeInsets.only(right: 20, top: 10, bottom: 10),
                      child: Text(grandTotal.toString(),
                          style: Styles.darkBlue())),
                ],
              ),
            ),
          ]),
          TableRow(children: [
            TableCell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  selectedvoucher != null
                      ? Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Chip(
                            backgroundColor: Colors.grey,
                            avatar: CircleAvatar(
                              backgroundColor: Colors.grey.shade800,
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            label: Text(
                              selectedvoucher.voucherName,
                              style: Styles.whiteBoldsmall(),
                            ),
                          ))
                      : SizedBox(),
                  Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: RaisedButton(
                        padding: EdgeInsets.only(
                            left: 10, right: 10, top: 5, bottom: 5),
                        onPressed: () {
                          openVoucherPop();
                        },
                        child: Row(
                          children: <Widget>[
                            Text(Strings.apply_promocode,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                )),
                          ],
                        ),
                        color: Colors.deepOrange,
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ))
                ],
              ),
            ),
          ]),
        ]);

    return Column(
      children: <Widget>[
        Container(
            height: MediaQuery.of(context).size.height / 1.3,
            width: MediaQuery.of(context).size.width,
            color: Colors.grey[300],
            padding: EdgeInsets.all(10),
            child: Stack(
              children: <Widget>[
                cartList.length != 0
                    ? Container(
                        width: MediaQuery.of(context).size.width / 1.2,
                        color: Colors.white,
                        child: carttitle,
                      )
                    : SizedBox(),
                Container(
                    //color: Colors.white,
                    height: MediaQuery.of(context).size.height / 3.2,
                    margin: EdgeInsets.only(top: 50),
                    child: cartTable),
                cartList.length != 0
                    ? Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(child: totalPriceTable),
                      )
                    : Center(
                        child: Text(Strings.item_not_available,
                            style: Styles.communBlack()))
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
