import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:mcncashier/components/DrawerWidget.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/colors.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/helpers/LocalAPI/Branch.dart';
import 'package:mcncashier/helpers/LocalAPI/Cart.dart';
import 'package:mcncashier/helpers/LocalAPI/CategoriesList.dart';
import 'package:mcncashier/helpers/LocalAPI/OrdersList.dart';
import 'package:mcncashier/helpers/LocalAPI/PaymentList.dart';
import 'package:mcncashier/helpers/LocalAPI/PrinterList.dart';
import 'package:mcncashier/helpers/LocalAPI/ProductList.dart';
import 'package:mcncashier/helpers/LocalAPI/ShiftList.dart';
import 'package:mcncashier/helpers/LocalAPI/TablesList.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/models/BranchTax.dart';
import 'package:mcncashier/models/Category.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/Drawer.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/OrderAttributes.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/Order_Modifire.dart';
import 'package:mcncashier/models/Lastids.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/Printer.dart';
import 'package:mcncashier/models/SetMeal.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/models/ShiftInvoice.dart';
import 'package:mcncashier/models/TableDetails.dart';
import 'package:mcncashier/models/Table_order.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/models/Voucher.dart';
import 'package:mcncashier/models/Voucher_History.dart';
import 'package:mcncashier/models/mst_sub_cart_details.dart';
import 'package:mcncashier/models/saveOrder.dart';
import 'package:mcncashier/printer/printerconfig.dart';
import 'package:mcncashier/screens/CloseShiftPage.dart';
import 'package:mcncashier/screens/OpningAmountPop.dart';
import 'package:mcncashier/screens/PaymentMethodPop.dart';
import 'package:mcncashier/screens/ProductQuantityDailog.dart';
import 'package:mcncashier/screens/SearchCustomer.dart';
import 'package:mcncashier/screens/ChangeQtyDailog.dart';
import 'package:mcncashier/screens/SplitOrder.dart';
import 'package:mcncashier/screens/VoucherPop.dart';
import 'package:mcncashier/screens/ReprintPopup.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mcncashier/theme/Sized_Config.dart';

import '../components/communText.dart';
import '../models/ProductStoreInventoryLog.dart';
import '../models/Product_Store_Inventory.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:expandable/expandable.dart';

class DashboradPage extends StatefulWidget {
  // main Product list page
  DashboradPage({Key key}) : super(key: key);

  @override
  _DashboradPageState createState() => _DashboradPageState();
}

class _DashboradPageState extends State<DashboradPage>
    with TickerProviderStateMixin {
  TabController _tabController;
  TabController _secondTabController;
  TabController _subtabController;
  var _textController = TextEditingController();
  GlobalKey<ScaffoldState> scaffoldKey;
  LocalAPI localAPI = LocalAPI();
  ShiftList shiftAPI = new ShiftList();
  Cartlist cartlistAPI = new Cartlist();
  PrinterList printerAPI = new PrinterList();
  OrdersList orderApi = new OrdersList();
  TablesList tableListAPI = new TablesList();
  PaymentList paymentAPI = new PaymentList();
  BranchList branchAPI = new BranchList();
  ProductsList prodList = new ProductsList();
  PrintReceipt printKOT = PrintReceipt();
  List<Category> allCaterories = new List<Category>();
  List<Category> tabsList = new List<Category>();
  List<Printer> printerList = new List<Printer>();
  List<Printer> printerreceiptList = new List<Printer>();
  List<Category> subCatList = new List<Category>();
  List<ProductDetails> productList = new List<ProductDetails>();
  List<ProductDetails> SearchProductList = new List<ProductDetails>();
  List<MSTCartdetails> cartList = new List<MSTCartdetails>();
  List<SetMeal> mealsList = new List<SetMeal>();
  SlidableController slidableController = SlidableController();
  List<BranchTax> taxlist = [];
  double taxvalues = 0.00;
  bool isDrawerOpen = false;
  bool isShiftOpen = true;
  var userDetails;
  bool isTableSelected = false;
  Branch branchData;
  Table_order selectedTable;
  double subtotal = 0;
  double serviceCharge = 0;
  double serviceChargePer = 0;
  Customer customer;
  String tableName = "";
  bool isWebOrder = false;
  double discount = 0;
  double tax = 0;
  List taxJson = [];
  double grandTotal = 0;
  MST_Cart allcartData = new MST_Cart();
  Voucher selectedvoucher;
  int currentCart;
  bool isLoading = false;
  User checkInUser;
  var permissions = "";
  var currency = "RM";
  bool isScreenLoad = false;
  Timer timer;
  List quantity = [2, 3, 4, 5, 6, 7, 8, 9];
  List categoryFirstRow = [];
  List categorySecondRow = [];
  var selectedCategory;
  var expandableController;
  MSTCartdetails itemSelectedIndex = new MSTCartdetails();

  @override
  void initState() {
    super.initState();
    setState(() {
      isScreenLoad = true;
    });
    checkisInit();
    checkISlogin();
  }

  refreshAfterAction(bool isClearCart) {
    if (isClearCart) {
      clearCart();
    }
    checkidTableSelected();
    checkCustomerSelected();
  }

  checkISlogin() async {
    var loginUser = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
    if (loginUser == null) {
      Navigator.pushNamed(context, Constant.PINScreen);
    } else {
      User userdata = User.fromJson(json.decode(loginUser));
      setState(() {
        checkInUser = userdata;
      });
    }
  }

  checkisInit() async {
    await setPermissons();
    var isInit = await CommunFun.checkDatabaseExit();
    if (isInit == true) {
      await getCategoryList();
      await checkidTableSelected();
      await getAllPrinter();
    } else {
      await databaseHelper.initializeDatabase();
      await getCategoryList();
      await checkidTableSelected();
    }
    var curre = await Preferences.getStringValuesSF(Constant.CURRENCY);
    setState(() {
      currency = curre;
    });
    await checkshift();
    await checkidTableSelected();
    setState(() {
      isScreenLoad = false;
    });
    await getUserData();
    await setPermissons();
    await getTaxs();
    await getbranch();
    _textController.addListener(() {
      getSearchList(_textController.text.toString());
    });

    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
  }

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {}

  void handleSlideIsOpenChanged(bool isOpen) {}

  setPermissons() async {
    var permission = await CommunFun.getPemission();
    setState(() {
      permissions = permission;
    });
  }

  checkCustomerSelected() async {
    Customer customerData = await CommunFun.getCustomer();
    setState(() {
      customer = customerData;
    });
  }

  checkidTableSelected() async {
    var tableid = await Preferences.getStringValuesSF(Constant.TABLE_DATA);
    var branchid = await CommunFun.getbranchId();
    if (tableid != null) {
      var tableddata = json.decode(tableid);
      Table_order table = Table_order.fromJson(tableddata);
      List<TablesDetails> tabledata =
          await tableListAPI.getTableDetails(branchid, table.table_id);
      table.save_order_id = tabledata[0].saveorderid;
      setState(() {
        isTableSelected = true;
        selectedTable = table;
        tableName = tabledata[0].tableName;
      });
      if (selectedTable.save_order_id != null &&
          selectedTable.save_order_id != 0) {
        getCurrentCart();
      }
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, Constant.SelectTableScreen, (Route<dynamic> route) => false,
          arguments: {"isAssign": false});
    }
  }

  clearCart() {
    setState(() {
      cartList = [];
      selectedTable = null;
      grandTotal = 0.0;
      isWebOrder = false;
      discount = 0.0;
      tax = 0.0;
      subtotal = 0.0;
      serviceCharge = 0.0;
      serviceChargePer = 0;
      isTableSelected = false;
      currentCart = null;
      allcartData = null;
    });
  }

  getCurrentCart() async {
    List<SaveOrder> currentOrder =
        await cartlistAPI.getSaveOrder(selectedTable.save_order_id);
    if (currentOrder.length != 0) {
      setState(() {
        currentCart = currentOrder[0].cartId;
      });
      if (isShiftOpen) {
        getCartItem(currentCart);
      }
    }
  }

  checkshift() async {
    var isOpen = await Preferences.getStringValuesSF(Constant.IS_SHIFT_OPEN);
    setState(() {
      isShiftOpen = isOpen != null && isOpen == "true" ? true : false;
    });
  }

  getCartItem(cartId) async {
    List<MSTCartdetails> cartItem = await CommunFun.getcartDetails(cartId);
    if (cartItem.length > 0) {
      setState(() {
        cartList = cartItem;
      });
      countTotals(cartId);
    }
  }

  countTotals(cartId) async {
    MST_Cart cart = await CommunFun.getCartData(cartId);
    Voucher vaocher;

    if (cart.voucher_id != null) {
      var voucherdetail = jsonDecode(cart.voucher_detail);
      vaocher = Voucher.fromJson(voucherdetail);
    }
    setState(() {
      allcartData = cart;
      subtotal = cart.sub_total;
      serviceCharge = cart.serviceCharge == null ? 0.00 : cart.serviceCharge;
      serviceChargePer =
          cart.serviceChargePercent == null ? 0 : cart.serviceChargePercent;
      discount = cart.discount;
      tax = cart.tax;
      isWebOrder = cart.source == 1 ? true : false;
      taxJson = json.decode(cart.tax_json);
      grandTotal = cart.grand_total;
      selectedvoucher = vaocher;
    });
  }

  removeCutomer() async {
    await Preferences.removeSinglePref(Constant.CUSTOMER_DATA);
    setState(() {
      customer = null;
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
    await Preferences.removeSinglePref(Constant.CUSTOMER_DATA);
    checkidTableSelected();
    clearCart();
  }

  closeShift() {
    showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return CloseShiftPage(onClose: () {
            printKOT.testReceiptPrint(
                printerreceiptList[0].printerIp.toString(),
                context,
                "",
                "OpenDrawer");
            openOpningAmmountPop(Strings.title_closing_amount);
          });
        });
  }

  deleteCurrentCart() async {
    // Delete current order
    Table_order tables = await getTableData();
    await cartapi.clearCartItem(currentCart, tables.table_id);

    await refreshAfterAction(true);
  }

  void selectOption(choice) async {
    // Causes the app to rebuild with the new _selectedChoice.

    switch (choice) {
      case 0:
        selectTable();
        break;
      case 1:
        closeTable();
        break;
      case 2:
        showDialog(
            // Opning Ammount Popup
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return SplitBillDialog(
                onSelectedRemove: (cart) {
                  itememovefromCart(cart);
                },
                onClose: (String isFor) {
                  Navigator.of(context).pop();
                  if (isFor == "clear") {
                    clearCart();
                  }
                },
                currentCartID: currentCart,
                customer: customer != null ? customer.name : "",
                printerIP: printerreceiptList.length > 0
                    ? printerreceiptList[0].printerIp
                    : "",
              );
            });
        break;
      case 3:
        closeShift();
        break;
      case 4:
        printCheckList();
        break;
      case 5:
        draftreciptPrint();
        break;
      case 6:
        deleteCurrentCart();
        break;
      case 7:
        resendToKitchen();
        break;
    }
  }

  resendToKitchen() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ReprintKitchenPirntPop(
              cartList: cartList,
              onClose: (resendList) {
                if (resendList.length > 0 && printerreceiptList.length > 0) {
                  Navigator.of(context).pop();
                  if (permissions.contains(Constant.PRINT_RECIEPT)) {
                    openPrinterPop(resendList, true);
                  } else {
                    CommonUtils.openPermissionPop(
                        context, Constant.PRINT_RECIEPT, () {
                      openPrinterPop(resendList, true);
                    }, () {});
                  }
                } else {
                  CommunFun.showToast(context, Strings.printer_not_available);
                }
              });
        });
  }

  draftreciptPrint() async {
    if (cartList.length > 0) {
      if (printerreceiptList.length > 0) {
        if (permissions.contains(Constant.PRINT_RECIEPT)) {
          printKOT.checkDraftPrint(
              taxJson,
              printerreceiptList[0].printerIp.toString(),
              context,
              cartList,
              tableName,
              subtotal,
              serviceChargePer,
              serviceCharge,
              grandTotal,
              tax,
              branchData,
              currency,
              customer != null ? customer.name : Strings.walkin_customer);
        } else {
          await CommonUtils.openPermissionPop(context, Constant.PRINT_RECIEPT,
              () {
            printKOT.checkDraftPrint(
                taxJson,
                printerreceiptList[0].printerIp.toString(),
                context,
                cartList,
                tableName,
                subtotal,
                serviceChargePer,
                serviceCharge,
                grandTotal,
                tax,
                branchData,
                currency,
                customer != null ? customer.name : Strings.walkin_customer);
          }, () {});
        }
      } else {
        CommunFun.showToast(context, Strings.printer_not_available);
      }
    } else {
      CommunFun.showToast(context, Strings.cart_empty);
    }
  }

  printCheckList() async {
    if (cartList.length > 0) {
      if (printerreceiptList.length > 0) {
        if (permissions.contains(Constant.PRINT_RECIEPT)) {
          printKOT.checkListReceiptPrint(
              printerreceiptList[0].printerIp.toString(),
              context,
              cartList,
              tableName,
              branchData,
              customer != null ? customer.name : Strings.walkin_customer);
        } else {
          await CommonUtils.openPermissionPop(context, Constant.PRINT_RECIEPT,
              () {
            printKOT.checkListReceiptPrint(
                printerreceiptList[0].printerIp.toString(),
                context,
                cartList,
                tableName,
                branchData,
                customer != null ? customer.name : Strings.walkin_customer);
          }, () {});
        }
      } else {
        CommunFun.showToast(context, Strings.printer_not_available);
      }
    } else {
      CommunFun.showToast(context, Strings.cart_empty);
    }
  }

/*this function used for remove promocode from cart*/
  removePromoCode(voucherdata) async {
    List<MSTCartdetails> cartListUpdate = [];
    for (int i = 0; i < cartList.length; i++) {
      var cartitem = cartList[i];
      cartitem.discount = 0.0;
      cartitem.discountType = 0;
      cartListUpdate.add(cartitem);
    }
    allcartData.grand_total = allcartData.grand_total + allcartData.discount;
    allcartData.voucher_detail = "";
    allcartData.discount = 0.0;
    allcartData.discount_type = 0;
    allcartData.voucher_id = null;
    await cartapi.addVoucherInOrder(allcartData, cartListUpdate);
    await countTotals(currentCart);
  }

  getCategoryList() async {
    var branchid = await CommunFun.getbranchId();
    CategoriesList category = new CategoriesList();
    List<Category> categorys = await category.getCategories(context, branchid);
    List<Category> catList = categorys.where((i) => i.parentId == 0).toList();
    setState(() {
      tabsList = catList;
      allCaterories = categorys;
    });

    for (var i = 0; i < tabsList.length; i++) {
      if (i % 2 == 0) {
        categoryFirstRow.add(tabsList[i]);
      } else {
        categorySecondRow.add(tabsList[i]);
      }
    }

    _tabController =
        TabController(vsync: this, length: categoryFirstRow.length);
    _secondTabController =
        TabController(vsync: this, length: categorySecondRow.length);
    _tabController.addListener(_handleTabSelection);
    _secondTabController.addListener(_handleSecondTabSelection);

    if (tabsList[0].isSetmeal == 1) {
      getMeals();
    } else {
      getProductList(tabsList[0].categoryId);
    }
  }

  getMeals() async {
    var branchid = await CommunFun.getbranchId();
    List<SetMeal> setmeals = await prodList.getMealsData(branchid);
    setState(() {
      mealsList = setmeals;
      productList = [];
    });
  }

  getAllPrinter() async {
    List<Printer> printer = await printerAPI.getAllPrinterList(context, "0");
    List<Printer> printerDraft =
        await printerAPI.getAllPrinterList(context, "1");
    setState(() {
      printerList = printer;
      printerreceiptList = printerDraft;
    });
  }

  _backtoMainCat() {
    setState(() {
      subCatList = [];
    });
    var cat = tabsList[_tabController.index].categoryId;
    if (tabsList[_tabController.index].isSetmeal == 1) {
      getMeals();
    }
    //  else {
    //   getProductList(cat);
    // }
  }

  getProductList(categoryId) async {
    setState(() {
      isLoading = true;
    });
    var branchid = await CommunFun.getbranchId();
    List<ProductDetails> product =
        await prodList.getProduct(context, categoryId, branchid);
    if (product.length > 0) {
      setState(() {
        // productList = [];
        productList = product;
        isLoading = false;
        mealsList = [];
      });
    } else {
      setState(() {
        productList = [];
        isLoading = false;
        mealsList = [];
      });
    }
  }

  getSearchList(seachText) async {
    if (seachText != "") {
      var branchid = await CommunFun.getbranchId();
      List<ProductDetails> product =
          await prodList.getSeachProduct(context, seachText);
      List<SetMeal> setMeal =
          await prodList.getSearchSetMealsData(seachText.toString(), branchid);

      setMeal.forEach((element) {
        ProductDetails cartItemproduct = new ProductDetails();
        cartItemproduct.price = double.parse(element.price.toStringAsFixed(2));
        cartItemproduct.status = element.status;
        cartItemproduct.productId = element.setmealId;
        cartItemproduct.base64 = element.base64;
        cartItemproduct.name = element.name;
        cartItemproduct.uuid = element.uuid;
        cartItemproduct.isSetMeal = true;
        product.add(cartItemproduct);
      });
      setState(() {
        SearchProductList = product.length > 0 ? product : [];
      });
    } else {
      setState(() {
        SearchProductList = [];
      });
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      var cat = categoryFirstRow[_tabController.index].categoryId;
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
      if (categoryFirstRow[_tabController.index].isSetmeal == 1) {
        getMeals();
      } else {
        getProductList(cat);
      }
    }
  }

  void _handleSecondTabSelection() {
    if (_secondTabController.indexIsChanging) {
      var cat = categorySecondRow[_secondTabController.index].categoryId;
      print(cat);
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
      if (categorySecondRow[_secondTabController.index].isSetmeal == 1) {
        getMeals();
      } else {
        getProductList(cat);
      }
    }
  }

  void _handleSubTabSelection() {
    if (_subtabController.indexIsChanging) {
      var cat = subCatList[_subtabController.index].categoryId;
      if (subCatList[_subtabController.index].isSetmeal == 1) {
        getMeals();
      } else {
        getProductList(cat);
      }
    }
  }

  void _selectedCategory(int index, String row) {
    var selected =
        row == 'first' ? categoryFirstRow[index] : categorySecondRow[index];

    setState(() {
      selectedCategory = selected;
    });

    if ((row == 'first'
            ? categoryFirstRow[index].isSetmeal
            : categorySecondRow[index].isSetmeal) ==
        1) {
      getMeals();
    } else {
      getProductList(row == 'first'
          ? categoryFirstRow[index].categoryId
          : categorySecondRow[index].categoryId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _secondTabController.dispose();
    if (_subtabController != null) _subtabController.dispose();
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
                if (isopning == Strings.title_opening_amount) {
                  if (printerreceiptList.length > 0) {
                    printKOT.testReceiptPrint(
                        printerreceiptList[0].printerIp.toString(),
                        context,
                        "",
                        Strings.openDrawer);
                  } else {
                    CommunFun.showToast(context, Strings.printer_not_available);
                  }
                }
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
            cartData: allcartData,
            cartId: currentCart,
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

/*This method used for print KOT receipt print*/
  openPrinterPop(cartLists, isReprint) {
    for (int i = 0; i < printerList.length; i++) {
      List<MSTCartdetails> tempCart = new List<MSTCartdetails>();
      tempCart.clear();
      for (int j = 0; j < cartLists.length; j++) {
        MSTCartdetails temp = MSTCartdetails();

        if (printerList[i].printerId == cartLists[j].printer_id) {
          temp = cartLists[j];
          tempCart.add(temp);
        }
      }
      if (tempCart.length > 0) {
        printKOT.checkKOTPrint(
            printerList[i].printerIp.toString(),
            tableName,
            context,
            tempCart,
            selectedTable.number_of_pax.toString(),
            isReprint);
      }
    }
  }

  sendTokitched(itemList) async {
    String ids = "";
    var list = [];
    for (var i = 0; i < itemList.length; i++) {
      if (itemList[i].isSendKichen == null || itemList[i].isSendKichen == 0) {
        if (ids == "") {
          ids = itemList[i].id.toString();
        } else {
          ids = ids + "," + itemList[i].id.toString();
        }
        list.add(itemList[i]);
      }
      if (i == itemList.length - 1) {
        if (list.length > 0) {
          dynamic send = await cartapi.sendToKitched(ids);
          openPrinterPop(list, false);
          getCartItem(currentCart);
        }
        return false;
      }
    }
  }

  sendPayment() {
    if (cartList.length != 0) {
      opnePaymentMethod();
    } else {
      CommunFun.showToast(context, Strings.cart_empty);
    }
  }

  checkoutWebOrder() async {
    if (cartList.length != 0) {
      await CommunFun.processingPopup(context);
      List<OrderPayment> payment = [];
      sendPaymentByCash(payment);
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
    var terminalId = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    User userdata = await CommunFun.getuserDetails();
    Shift shift = new Shift();
    int appid = await shiftAPI.getLastShiftAppID(terminalId);
    if (shiftid == null && appid != 0) {
      shift.appId = appid + 1;
    } else {
      shift.appId = shiftid == null ? 1 : int.parse(shiftid);
    }
    shift.terminalId = int.parse(terminalId);
    shift.branchId = int.parse(branchid);
    shift.userId = userdata.id;
    shift.uuid = await CommunFun.getLocalID();
    shift.status = 1;
    shift.serverId = 0;
    if (shiftid == null) {
      shift.startAmount = int.parse(ammount);
      shift.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
    } else {
      shift.endAmount = int.parse(ammount);
      shift.updatedAt = await CommunFun.getCurrentDateTime(DateTime.now());
    }
    shift.updatedBy = userdata.id;
    var result = await shiftAPI.insertShift(context, shift, shiftid);
    if (shiftid == null) {
      await Preferences.setStringToSF(Constant.DASH_SHIFT, result.toString());
    } else {
      await CommunFun.printShiftReportData(
          printerreceiptList[0].printerIp.toString(), context, shiftid);
      await Preferences.removeSinglePref(Constant.DASH_SHIFT);
      await Preferences.removeSinglePref(Constant.IS_SHIFT_OPEN);
      await Preferences.removeSinglePref(Constant.CUSTOMER_DATA);
      checkshift();
    }
    Navigator.pushNamedAndRemoveUntil(
        context, Constant.SelectTableScreen, (Route<dynamic> route) => false,
        arguments: {"isAssign": false});
  }

  openDrawer() {
    scaffoldKey.currentState.openDrawer();
  }

  checkshiftopne(product) {
    if (isShiftOpen) {
      if (isTableSelected && !isWebOrder) {
        showQuantityDailog(product, false);
      } else {
        if (!isWebOrder) {
          selectTable();
        }
      }
    } else {
      CommunFun.showToast(context, Strings.shift_open_message);
    }
  }

  showQuantityDailog(product, isSetMeal) async {
    var selectedProduct = product;
    if (!isSetMeal) {
      if (selectedProduct.isSetMeal != null) {
        isSetMeal = true;
        SetMeal cartItemproduct = new SetMeal();
        cartItemproduct.price =
            double.parse(selectedProduct.price.toStringAsFixed(2));
        cartItemproduct.status = selectedProduct.status;
        cartItemproduct.setmealId = selectedProduct.productId;
        cartItemproduct.base64 = selectedProduct.base64;
        cartItemproduct.name = selectedProduct.name;
        cartItemproduct.uuid = selectedProduct.uuid;
        selectedProduct = cartItemproduct;
      }
    }
    if (isSetMeal ||
        selectedProduct.attrCat != null ||
        selectedProduct.modifireName != null) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ProductQuantityDailog(
                selproduct: selectedProduct,
                issetMeal: isSetMeal,
                cartID: currentCart,
                onClose: () {
                  refreshAfterAction(false);
                });
          });
    } else {
      setState(() {
        isScreenLoad = true;
      });
      await addTocartItem(selectedProduct);
    }
  }

  addTocartItem(selectedProduct) async {
    await CommunFun.addItemToCart(selectedProduct, cartList, allcartData, () {
      if (selectedTable.save_order_id != null &&
          selectedTable.save_order_id != 0) {
        getCurrentCart();
      } else {
        checkidTableSelected();
      }
      setState(() {
        isScreenLoad = false;
      });
    }, context);
  }

  opneShowAddCustomerDailog() {
    // Send receipt Popup
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SearchCustomerPage(
              onClose: () {
                //refreshAfterAction();
                checkCustomerSelected();
              },
              isFor: Constant.dashboard);
        });
  }

  opnePaymentMethod() {
    showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return PaymentMethodPop(
            subTotal: subtotal,
            grandTotal: grandTotal,
            onClose: (mehtod) {
              CommunFun.processingPopup(context);
              paymentWithMethod(mehtod);
            },
          );
        });
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

  Future<List<MSTSubCartdetails>> getmodifireList(detailid) async {
    List<MSTSubCartdetails> list = await cartapi.getItemModifire(detailid);
    return list;
  }

  Future<List<MSTCartdetails>> getcartDetails(cartid) async {
    List<MSTCartdetails> list = await CommunFun.getcartDetails(cartid);
    return list;
  }

  getbranch() async {
    var branchid = await CommunFun.getbranchId();
    var branch = await branchAPI.getbranchData(branchid);
    setState(() {
      branchData = branch;
    });
    return branch;
  }

  getcartData() async {
    var cartDatalist = await CommunFun.getCartData(currentCart);
    return cartDatalist;
  }

  paymentWithMethod(mehtod) async {
    sendPaymentByCash(mehtod);
  }

  sendPaymentByCash(List<OrderPayment> payment) async {
    var cartData = await getcartData();
    var shiftid = await Preferences.getStringValuesSF(Constant.DASH_SHIFT);
    Orders order = new Orders();
    VoucherHistory history = new VoucherHistory();
    List<OrderModifire> orderModifires = new List<OrderModifire>();
    List<OrderAttributes> orderAttributes = new List<OrderAttributes>();
    List<OrderPayment> orderPaymentList = new List<OrderPayment>();
    ShiftInvoice shiftinvoice = new ShiftInvoice();
    Table_order tables = await getTableData();
    User userdata = await CommunFun.getuserDetails();
    List<MSTCartdetails> cartList = await getcartDetails(currentCart);
    var terminalId = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    var uuid = await CommunFun.getLocalID();
    LastAppids lastappid = await orderApi.getLastids(terminalId);
    int length = branchData.invoiceStart.length;
    var invoiceNo;
    if (lastappid.app_id != null) {
      order.app_id = lastappid.app_id + 1;
      invoiceNo =
          branchData.orderPrefix + order.app_id.toString().padLeft(length, "0");
    } else {
      order.app_id = 1;
      invoiceNo =
          branchData.orderPrefix + order.app_id.toString().padLeft(length, "0");
    }
    var convertGrand =
        await CommunFun.checkRoundData(cartData.grand_total.toStringAsFixed(2));
    double newGtotal = double.parse(convertGrand);
    var roundingVal =
        await CommunFun.calRounded(newGtotal, cartData.grand_total);
    double rounding = double.parse(roundingVal.toStringAsFixed(2));
    order.uuid = uuid;
    order.branch_id = int.parse(branchid);
    order.terminal_id = int.parse(terminalId);
    order.table_id = tables.table_id;
    order.invoice_no = invoiceNo;
    order.customer_id = cartData.user_id;
    order.sub_total = cartData.sub_total;
    order.serviceCharge = cartData.serviceCharge;
    order.serviceChargePercent = cartData.serviceChargePercent;
    order.sub_total_after_discount = cartData.sub_total;
    order.grand_total = newGtotal;
    order.rounding_amount = rounding;
    order.order_item_count = cartData.total_qty.toInt();
    order.tax_amount = cartData.tax;
    order.tax_json = cartData.tax_json;
    order.order_date = await CommunFun.getCurrentDateTime(DateTime.now());
    order.order_status = 1;
    order.server_id = 0;
    order.order_source = cartData.source;
    order.order_by = userdata.id;
    order.voucher_detail = cartData.voucher_detail;
    order.voucher_id = cartData.voucher_id;
    order.voucher_amount = cartData.discount;
    order.updated_at = await CommunFun.getCurrentDateTime(DateTime.now());
    order.updated_by = userdata.id;
    List<OrderDetail> detaislist = [];
    if (cartList.length > 0) {
      var lstappid =
          lastappid.order_detail_id != null ? lastappid.order_detail_id + 1 : 1;
      for (var i = 0; i < cartList.length; i++) {
        OrderDetail orderDetail = new OrderDetail();
        var cartItem = cartList[i];
        var productdata = cartItem.cart_detail != null
            ? json.decode(cartItem.cart_detail)
            : "";
        List<ProductStoreInventory> cartval =
            await orderApi.checkItemAvailableinStore(cartItem.productId);
        if (productdata["has_inventory"] == 1 && cartval.length > 0) {
          double storeqty = cartval[0].qty;
          if (storeqty < cartItem.productQty) {
            CommunFun.showToast(
                context,
                productdata["name"] +
                    " Product is out of stock.Please check store.");
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            return false;
          }
        }
        orderDetail.app_id = lstappid;
        orderDetail.uuid = uuid;
        orderDetail.branch_id = int.parse(branchid);
        orderDetail.terminal_id = int.parse(terminalId);
        orderDetail.product_id = cartItem.productId;
        orderDetail.product_price = cartItem.productPrice;
        orderDetail.product_old_price = cartItem.productNetPrice;
        orderDetail.detail_qty = cartItem.productQty;
        orderDetail.product_discount = cartItem.discount;
        orderDetail.product_detail = json.encode(productdata);
        orderDetail.updated_at =
            await CommunFun.getCurrentDateTime(DateTime.now());
        orderDetail.detail_amount =
            (cartItem.productPrice * cartItem.productQty);
        orderDetail.detail_datetime =
            await CommunFun.getCurrentDateTime(DateTime.now());
        orderDetail.updated_by = userdata.id;
        orderDetail.detail_status = 1;
        orderDetail.detail_by = userdata.id;
        orderDetail.issetMeal = cartItem.issetMeal;
        orderDetail.hasRacManagemant = cartItem.hasRacManagemant;
        if (cartItem.issetMeal == 1) {
          orderDetail.setmeal_product_detail = cartItem.setmeal_product_detail;
        }
        detaislist.add(orderDetail);
        lstappid += 1;
        List<MSTSubCartdetails> modifireList =
            await getmodifireList(cartItem.id);
        if (modifireList.length > 0) {
          var modiApp = lastappid.order_modifier_id != null
              ? lastappid.order_modifier_id + 1
              : 1;
          var attApp =
              lastappid.order_attr_id != null ? lastappid.order_attr_id + 1 : 1;
          for (var i = 0; i < modifireList.length; i++) {
            OrderModifire modifireData = new OrderModifire();
            var modifire = modifireList[i];
            if (modifire.caId == null) {
              modifireData.app_id = modiApp;
              modifireData.uuid = uuid;
              modifireData.terminal_id = int.parse(terminalId);
              modifireData.product_id = modifire.productId;
              modifireData.modifier_id = modifire.modifierId;
              modifireData.om_amount = modifire.modifirePrice;
              modifireData.om_by = userdata.id;
              modifireData.om_datetime =
                  await CommunFun.getCurrentDateTime(DateTime.now());
              modifireData.om_status = 1;
              modifireData.updated_at =
                  await CommunFun.getCurrentDateTime(DateTime.now());
              modifireData.updated_by = userdata.id;
              orderModifires.add(modifireData);
              modiApp += 1;
            } else {
              OrderAttributes attributes = new OrderAttributes();
              attributes.app_id = attApp;
              attributes.uuid = uuid;
              attributes.terminal_id = int.parse(terminalId);
              attributes.product_id = modifire.productId;
              attributes.attribute_id = modifire.attributeId;
              attributes.attr_price = modifire.attrPrice;
              attributes.ca_id = modifire.caId;
              attributes.oa_datetime =
                  await CommunFun.getCurrentDateTime(DateTime.now());
              attributes.oa_by = userdata.id;
              attributes.oa_status = 1;
              attributes.updated_at =
                  await CommunFun.getCurrentDateTime(DateTime.now());
              attributes.updated_by = userdata.id;
              orderAttributes.add(attributes);
              attApp += 1;
            }
          }
        }
      }
    }
    var laPaID =
        lastappid.order_payment_id != null ? lastappid.order_payment_id + 1 : 1;
    if (payment.length > 0) {
      for (var i = 0; i < payment.length; i++) {
        OrderPayment orderpayment = payment[i];
        orderpayment.app_id = laPaID;
        orderpayment.uuid = uuid;
        orderpayment.branch_id = int.parse(branchid);
        orderpayment.terminal_id = int.parse(terminalId);
        orderpayment.op_method_id = payment[i].op_method_id;
        orderpayment.op_amount = payment[i].op_amount.toDouble();
        orderpayment.op_amount_change = payment[i].op_amount_change;
        orderpayment.remark = payment[i].remark;
        orderpayment.last_digits = payment[i].last_digits;
        orderpayment.reference_number = payment[i].reference_number;
        orderpayment.approval_code = payment[i].approval_code;
        orderpayment.isCash = payment[i].isCash;
        orderpayment.op_method_response = '';
        orderpayment.op_status = 1;
        orderpayment.op_datetime =
            await CommunFun.getCurrentDateTime(DateTime.now());
        orderpayment.op_by = userdata.id;
        orderpayment.updated_at =
            await CommunFun.getCurrentDateTime(DateTime.now());
        orderpayment.updated_by = userdata.id;
        orderPaymentList.add(orderpayment);
        laPaID += 1;
        if (payment[i].isCash == 1) {
          Drawerdata drawer = new Drawerdata();
          drawer.shiftId = int.parse(shiftid);
          drawer.amount = payment[i].op_amount;
          drawer.isAmountIn = 1;
          drawer.reason = "placeOrder";
          drawer.status = 1;
          drawer.createdBy = userdata.id;
          drawer.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
          drawer.localID = uuid;
          drawer.terminalid = int.parse(terminalId);
          var result = await shiftAPI.saveInOutDrawerData(drawer);
        }
      }
    } else if (isWebOrder) {
      OrderPayment orderpayment = new OrderPayment();
      orderpayment.app_id = laPaID;
      orderpayment.uuid = uuid;
      orderpayment.branch_id = int.parse(branchid);
      orderpayment.terminal_id = int.parse(terminalId);
      orderpayment.op_method_id = cartData.cart_payment_id;
      orderpayment.op_amount = cartData.grand_total;
      orderpayment.isCash = 1;
      orderpayment.op_status = 1;
      orderpayment.op_datetime =
          await CommunFun.getCurrentDateTime(DateTime.now());
      orderpayment.op_by = userdata.id;
      orderpayment.updated_at =
          await CommunFun.getCurrentDateTime(DateTime.now());
      orderpayment.updated_by = userdata.id;
      orderPaymentList.add(orderpayment);
    }
    if (cartData.voucher_id != 0 && cartData.voucher_id != null) {
      history.voucher_id = cartData.voucher_id;
      history.amount = cartData.discount;
      history.created_at = await CommunFun.getCurrentDateTime(DateTime.now());
      history.uuid = uuid;
    }
    // Shifr Invoice Table
    int appid = await shiftAPI.getLastShiftInvoiceAppID(terminalId);
    if (appid != 0) {
      shiftinvoice.app_id = appid + 1;
    } else {
      shiftinvoice.app_id = 1;
    }
    shiftinvoice.shift_app_id = int.parse(shiftid);
    shiftinvoice.status = 1;
    shiftinvoice.created_by = userdata.id;
    shiftinvoice.created_at =
        await CommunFun.getCurrentDateTime(DateTime.now());
    shiftinvoice.serverId = 0;
    shiftinvoice.localID = await CommunFun.getLocalID();
    shiftinvoice.terminal_id = int.parse(terminalId);
    shiftinvoice.shift_terminal_id = int.parse(terminalId);
    var orderid = await orderApi.placeOrder(
      order,
      detaislist,
      orderModifires,
      orderAttributes,
      orderPaymentList,
      history,
      shiftinvoice,
      currentCart,
    );
    await printReceipt(orderid);
    await clearCartAfterSuccess(orderid);
  }

  // insertRacInv(user, cartItem, customer) async {
  //   Customer_Liquor_Inventory inventory = new Customer_Liquor_Inventory();
  //   var orderDateF;

  //   var appid = await localAPI.getLastCustomerInventory();
  //   if (appid != 0) {
  //     inventory.appId = appid + 1;
  //   } else {
  //     inventory.appId = 1;
  //   }
  //   var branchid = await CommunFun.getbranchId();
  //   var now = DateTime.now();
  //   var newDate = new DateTime(now.year, now.month + 1, now.day);
  //   orderDateF = DateFormat('yyyy-MM-dd HH:mm:ss').format(newDate);
  //   List<Box> boxList = await localAPI.getBoxForProduct(cartItem.productId);
  //   if (boxList.length > 0) {
  //     inventory.uuid = await CommunFun.getLocalID();
  //     inventory.clCustomerId = customer;
  //     inventory.clProductId = cartItem.productId;
  //     inventory.clBranchId = int.parse(branchid);
  //     inventory.clRacId = boxList[0].racId;
  //     inventory.clBoxId = boxList[0].boxId;
  //     inventory.type = boxList[0].boxFor;
  //     inventory.clTotalQuantity = boxList[0].wineQty;
  //     inventory.clExpiredOn = orderDateF;
  //     inventory.clLeftQuantity = boxList[0].wineQty != null
  //         ? (boxList[0].wineQty - cartItem.productQty)
  //         : 0;
  //     inventory.status = 1;
  //     inventory.updatedAt = await CommunFun.getCurrentDateTime(DateTime.now());
  //     inventory.updatedBy = user.id;
  //     var clid = await localAPI.insertWineInventory(inventory, false);
  //     Customer_Liquor_Inventory_Log log = new Customer_Liquor_Inventory_Log();
  //     var lastappid = await localAPI.getLastCustomerInventoryLog();
  //     if (lastappid != 0) {
  //       log.appId = lastappid + 1;
  //     } else {
  //       log.appId = 1;
  //     }
  //     log.uuid = await CommunFun.getLocalID();
  //     log.clAppId = inventory.appId;
  //     log.branchId = int.parse(branchid);
  //     log.productId = cartItem.productId;
  //     log.customerId = customer;
  //     log.liType = boxList[0].boxFor;
  //     log.qty = cartItem.productQty;
  //     log.qtyBeforeChange = boxList[0].wineQty;
  //     log.qtyAfterChange = boxList[0].wineQty != null
  //         ? (boxList[0].wineQty - cartItem.productQty)
  //         : 0;
  //     log.updatedAt = await CommunFun.getCurrentDateTime(DateTime.now());
  //     log.updatedBy = user.id;
  //     var lid = await localAPI.insertWineInventoryLog(log);
  //   }
  // }

  printReceipt(int orderid) async {
    var terminalid = await CommunFun.getTeminalKey();
    dynamic data = await orderApi.getOrdersDetailsData(orderid, terminalid);

    // List<OrderPayment> orderpaymentdata =
    //     await orderApi.getOrderpaymentData(orderid, terminalid);
    // List<Payments> paymentMethod =
    //     await localAPI.getOrderpaymentmethod(orderid, terminalid);
    // List<OrderDetail> orderitem =
    //     await orderApi.getOrderDetailsList(orderid, terminalid);
    // Orders order = await orderApi.getcurrentOrders(orderid, terminalid);
    // List<OrderAttributes> attributes =
    //     await localAPI.getOrderAttributes(orderid);
    // List<OrderModifire> modifires = await localAPI.getOrderModifire(orderid);

    if (permissions.contains(Constant.PRINT_RECIEPT)) {
      if (permissions.contains(Constant.OPEN_DRAWER)) {
        printKOT.checkReceiptPrint(
            printerreceiptList[0].printerIp,
            context,
            branchData,
            taxJson,
            data["order_items"], // List<OrderDetail>
            data["order_attributes"], // List<OrderAttributes>
            data["order_modifires"], // List<OrderModifire>
            data["order"], // Orders
            data["order_payment"], // List<OrderPayment>
            data["order_payment_method"], // List<Payments>
            tableName,
            currency,
            customer != null ? customer.name : Strings.walkin_customer);
        await clearCartAfterSuccess(orderid);
      } else {
        await CommonUtils.openPermissionPop(context, Constant.OPEN_DRAWER,
            () async {
          printKOT.checkReceiptPrint(
              printerreceiptList[0].printerIp,
              context,
              branchData,
              taxJson,
              data["order_items"], // List<OrderDetail>
              data["order_attributes"], // List<OrderAttributes>
              data["order_modifires"], // List<OrderModifire>
              data["order"], // Orders
              data["order_payment"], // List<OrderPayment>
              data["order_payment_method"], // List<Payments>
              tableName,
              currency,
              customer != null ? customer.name : Strings.walkin_customer);
          await clearCartAfterSuccess(orderid);
        }, () async {
          printKOT.checkReceiptPrint(
              printerreceiptList[0].printerIp,
              context,
              branchData,
              taxJson,
              data["order_items"], // List<OrderDetail>
              data["order_attributes"], // List<OrderAttributes>
              data["order_modifires"], // List<OrderModifire>
              data["order"], // Orders
              data["order_payment"], // List<OrderPayment>
              data["order_payment_method"], // List<Payments>
              tableName,
              currency,
              customer != null ? customer.name : Strings.walkin_customer);
          await clearCartAfterSuccess(orderid);
        });
      }
    } else {
      await CommonUtils.openPermissionPop(context, Constant.PRINT_RECIEPT,
          () async {
        if (permissions.contains(Constant.OPEN_DRAWER)) {
          printKOT.checkReceiptPrint(
              printerreceiptList[0].printerIp,
              context,
              branchData,
              taxJson,
              data["order_items"], // List<OrderDetail>
              data["order_attributes"], // List<OrderAttributes>
              data["order_modifires"], // List<OrderModifire>
              data["order"], // Orders
              data["order_payment"], // List<OrderPayment>
              data["order_payment_method"], // List<Payments>
              tableName,
              currency,
              customer != null ? customer.name : Strings.walkin_customer);
          await clearCartAfterSuccess(orderid);
        } else {
          await CommonUtils.openPermissionPop(context, Constant.OPEN_DRAWER,
              () async {
            printKOT.checkReceiptPrint(
                printerreceiptList[0].printerIp,
                context,
                branchData,
                taxJson,
                data["order_items"], // List<OrderDetail>
                data["order_attributes"], // List<OrderAttributes>
                data["order_modifires"], // List<OrderModifire>
                data["order"], // Orders
                data["order_payment"], // List<OrderPayment>
                data["order_payment_method"], // List<Payments>
                tableName,
                currency,
                customer != null ? customer.name : Strings.walkin_customer);
            await clearCartAfterSuccess(orderid);
          }, () async {
            printKOT.checkReceiptPrint(
                printerreceiptList[0].printerIp,
                context,
                branchData,
                taxJson,
                data["order_items"], // List<OrderDetail>
                data["order_attributes"], // List<OrderAttributes>
                data["order_modifires"], // List<OrderModifire>
                data["order"], // Orders
                data["order_payment"], // List<OrderPayment>
                data["order_payment_method"], // List<Payments>
                tableName,
                currency,
                customer != null ? customer.name : Strings.walkin_customer);
            await clearCartAfterSuccess(orderid);
          });
        }
      }, () async {
        await clearCartAfterSuccess(orderid);
      });
    }
  }

  clearCartAfterSuccess(orderid) async {
    await Preferences.removeSinglePref(Constant.TABLE_DATA);
    await Preferences.removeSinglePref(Constant.CUSTOMER_DATA);
    await Navigator.pushNamedAndRemoveUntil(
        context, Constant.SelectTableScreen, (Route<dynamic> route) => false,
        arguments: {"isAssign": false});
  }

  getTaxs() async {
    List<BranchTax> taxlist = [];
    List<BranchTax> taxlists = await CommunFun.getbranchTax();
    if (taxlists.length > 0) {
      setState(() {
        taxlist = taxlists;
      });
      taxlist = taxlists;
    }
    return taxlist;
  }

  countTax(subT) async {
    var res = await getTaxs();
    var totalTax = [];
    double taxvalue = 0.00;
    if (taxlist.length > 0) {
      for (var i = 0; i < taxlist.length; i++) {
        var taxlistitem = taxlist[i];
        var taxval = taxlistitem.rate != null
            ? subT * double.parse(taxlistitem.rate) / 100
            : 0.0;
        taxval = double.parse(taxval.toStringAsFixed(2));
        taxvalue += taxval;
        setState(() {
          taxvalues = taxvalue;
        });
        var taxmap = {
          "id": taxlistitem.id,
          "tax_id": taxlistitem.taxId,
          "branch_id": taxlistitem.branchId,
          "rate": taxlistitem.rate,
          "status": taxlistitem.status,
          "updated_at": taxlistitem.updatedAt,
          "updated_by": taxlistitem.updatedBy,
          "taxAmount": taxval.toString(),
          "taxCode": taxlistitem.code
        };
        totalTax.add(taxmap);
      }
    }
    return totalTax;
  }

  itememovefromCart(cartitem) async {
    try {
      MST_Cart cart = new MST_Cart();
      MSTCartdetails cartitemdata = cartitem;
      var subt = allcartData.sub_total - cartitemdata.productPrice;
      var taxjson = await countTax(subt);
      var disc = allcartData.discount != null
          ? allcartData.discount - cartitemdata.discount
          : 0;
      if (cartList.length == 1) {
        cart = allcartData;
        cart.sub_total = 0.0;
        cart.serviceCharge = 0.0;
        cart.discount = 0.0;
        cart.total_qty = 0.0;
        cart.grand_total = 0.0;
        cart.tax_json = "";
        cart.voucher_id = 0;
        cart.voucher_detail = "";
      } else {
        cart = allcartData;
        cart.sub_total = subt;
        cart.discount = disc;
        cart.serviceCharge =
            await CommunFun.countServiceCharge(cart.serviceChargePercent, subt);
        cart.total_qty = allcartData.total_qty - cartitemdata.productQty;
        cart.grand_total = (subt - disc) + taxvalues;
        cart.tax_json = json.encode(taxjson);
      }
      await cartapi.deleteCartItem(
          cartitem, currentCart, cart, cartList.length == 1);
      if (cartitem.isSendKichen == 1) {
        var deletedlist = [];
        deletedlist.add(cartitem);
        //openPrinterPop(deletedlist);
      }
      if (cartList.length > 1) {
        await getCartItem(currentCart);
      } else {
        setState(() {
          cartList = [];
          grandTotal = 0.0;
          discount = 0.0;
          tax = 0.0;
          subtotal = 0.0;
          serviceCharge = 0.0;
          serviceChargePer = 0;
        });
      }
    } catch (e) {
      CommunFun.showToast(context, e.message.toString());
    }
  }

  applyforFocProduct(cartitem) {
    CommonUtils.showAlertDialog(context, () {
      Navigator.of(context).pop();
    }, () {
      Navigator.of(context).pop();
      opneSelectQtyPop(cartitem);
    }, Strings.warning, Strings.warning_msg, Strings.yes, Strings.no, true);
  }

  opneSelectQtyPop(cartitem) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ChangeQtyDailog(
              type: null,
              qty: cartitem.productQty,
              onClose: (qty, remark) {
                Navigator.of(context).pop();
                splitproductfromItem(qty, cartitem, remark);
              });
        });
  }

  splitproductfromItem(qty, MSTCartdetails cartitem, remark) async {
    MSTCartdetails focProduct = new MSTCartdetails();
    User userdata = await CommunFun.getuserDetails();
    bool isupdate = false;
    if (cartitem.productQty == 1) {
      isupdate = true;
      focProduct.id = cartitem.id;
    }
    focProduct.isFocProduct = 1;
    focProduct.cartId = cartitem.cartId;
    focProduct.productId = cartitem.productId;
    focProduct.productName = cartitem.productName;
    focProduct.productSecondName = cartitem.productSecondName;
    focProduct.productPrice = 0.0;
    focProduct.productQty = qty;
    focProduct.productNetPrice = cartitem.productNetPrice;
    focProduct.createdBy = userdata.id;
    focProduct.cart_detail = cartitem.cart_detail;
    focProduct.discount = 0.0;
    focProduct.remark = remark;
    focProduct.issetMeal = cartitem.issetMeal;
    focProduct.taxValue = 0.0;
    focProduct.printer_id = cartitem.printer_id;
    focProduct.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
    focProduct.setmeal_product_detail = cartitem.setmeal_product_detail;
    var realprice = (cartitem.productPrice / cartitem.productQty);
    var dis = (cartitem.discount / cartitem.productQty);
    cartitem.productQty = cartitem.productQty - qty;
    cartitem.productPrice = (realprice * cartitem.productQty);
    cartitem.discount = (realprice * dis);
    MST_Cart cart = new MST_Cart();
    cart = allcartData;
    var subt = allcartData.sub_total - (realprice * qty);
    var taxjson = await countTax(subt);
    var disc =
        allcartData.discount != null ? allcartData.discount - (dis * qty) : 0;
    cart.sub_total = subt;
    cart.discount = disc;
    cart.total_qty = allcartData.total_qty - qty;
    cart.grand_total = (cart.sub_total - disc) + taxvalues;
    cart.tax_json = json.encode(taxjson);
    var result =
        await cartapi.makeAsFocProduct(focProduct, isupdate, cart, cartitem);

    getCartItem(currentCart);
  }

  editCartItem(cart) async {
    var prod;

    if (cart.issetMeal == 0) {
      List<ProductDetails> productdt =
          await prodList.productdData(cart.productId);
      if (productdt.length > 0) {
        prod = productdt[0];
      }
    } else {
      List<SetMeal> productdt = await prodList.setmealData(cart.productId);
      if (productdt.length > 0) {
        prod = productdt[0];
      }
    }

    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProductQuantityDailog(
              selproduct: prod,
              issetMeal: cart.issetMeal == 1 ? true : false,
              cartID: currentCart,
              cartItem: cart,
              onClose: () {
                refreshAfterAction(false);
              });
        });
    //     return false;
    //   }
    // }
  }

  selectTable() {
    Navigator.pushNamedAndRemoveUntil(
        context, Constant.SelectTableScreen, (Route<dynamic> route) => false,
        arguments: {"isAssign": false});
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    Future<bool> _willPopCallback() async {
      return false;
    }

    final itemEditScreen = GridView.count(
      crossAxisCount: 5,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      padding: EdgeInsets.all(10),
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if (permissions.contains(Constant.DISCOUNT_ITEM)) {
              applyforFocProduct(itemSelectedIndex);
              setState(() {
                itemSelectedIndex = new MSTCartdetails();
              });
            } else {
              CommonUtils.openPermissionPop(context, Constant.DISCOUNT_ITEM,
                  () {
                applyforFocProduct(itemSelectedIndex);
                setState(() {
                  itemSelectedIndex = new MSTCartdetails();
                });
              }, () {});
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.free_breakfast),
              SizedBox(height: 2),
              Text(
                'Make FOC',
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            if (permissions.contains(Constant.EDIT_ITEM)) {
              editCartItem(itemSelectedIndex);
              setState(() {
                itemSelectedIndex = new MSTCartdetails();
              });
            } else {
              CommonUtils.openPermissionPop(context, Constant.EDIT_ITEM, () {
                editCartItem(itemSelectedIndex);
                setState(() {
                  itemSelectedIndex = new MSTCartdetails();
                });
              }, () {});
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.insert_drive_file),
              SizedBox(height: 2),
              Text(
                'Edit Detail',
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            print(itemSelectedIndex);
            setState(() {
              itemSelectedIndex = new MSTCartdetails();
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.library_add),
              SizedBox(height: 2),
              Text(
                'Set Quantity',
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            print(itemSelectedIndex);
            setState(() {
              itemSelectedIndex = new MSTCartdetails();
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.art_track),
              SizedBox(height: 2),
              Text(
                'Set Remark',
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            if (permissions.contains(Constant.DELETE_ITEM)) {
              itememovefromCart(itemSelectedIndex);
              setState(() {
                itemSelectedIndex = new MSTCartdetails();
              });
            } else {
              CommonUtils.openPermissionPop(context, Constant.DELETE_ITEM, () {
                itememovefromCart(itemSelectedIndex);
                setState(() {
                  itemSelectedIndex = new MSTCartdetails();
                });
              }, () {});
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.delete),
              SizedBox(height: 2),
              Text(
                'Delete',
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            print(itemSelectedIndex);
            setState(() {
              itemSelectedIndex = new MSTCartdetails();
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.ac_unit),
              SizedBox(height: 2),
              Text(
                'Modifier',
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            print(itemSelectedIndex);
            setState(() {
              itemSelectedIndex = new MSTCartdetails();
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.room_service),
              SizedBox(height: 2),
              Text(
                'Service Type',
                textAlign: TextAlign.center,
              )
            ],
          ),
        )
      ],
    );
    // Categrory Tabs
    final _tabs = TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.label,
        unselectedLabelColor: Colors.white,
        labelColor: Colors.white,
        isScrollable: true,
        labelPadding: EdgeInsets.all(2),
        indicatorPadding: EdgeInsets.all(2),
        indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: Colors.deepOrange),
        tabs: List<Widget>.generate(categoryFirstRow.length, (int index) {
          return new Tab(
            child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.safeBlockHorizontal * 3,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  categoryFirstRow[index].name.toUpperCase(),
                  style: Styles.whiteBoldsmall(),
                )),
          );
        }));

    final _secondTabs = TabBar(
        controller: _secondTabController,
        indicatorSize: TabBarIndicatorSize.label,
        unselectedLabelColor: Colors.white,
        labelColor: Colors.white,
        isScrollable: true,
        labelPadding: EdgeInsets.all(2),
        indicatorPadding: EdgeInsets.all(2),
        indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: Colors.deepOrange),
        tabs: List<Widget>.generate(categorySecondRow.length, (int index) {
          //index = (tabsList.length/2).ceil() + index;

          return new Tab(
            child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.safeBlockHorizontal * 3,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  categorySecondRow[index].name.toUpperCase(),
                  style: Styles.whiteBoldsmall(),
                )),
          );
        }));
    /* final _subtabs = TabBar(
      controller: _subtabController,
      indicatorSize: TabBarIndicatorSize.label,
      unselectedLabelColor: Colors.white,
      labelColor: Colors.white,
      labelPadding: EdgeInsets.all(1),
      indicatorPadding: EdgeInsets.all(0),
      isScrollable: true,
      indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(30), color: Colors.deepOrange),
      tabs: List<Widget>.generate(subCatList.length, (int index) {
        return new Tab(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.safeBlockVertical * 2,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              subCatList[index].name.toUpperCase(),
              style: Styles.whiteBoldsmall(),
            ),
          ),
        );
      }),
    ); */

    final _quantityTabs = TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.label,
        unselectedLabelColor: Colors.white,
        labelColor: Colors.white,
        isScrollable: false,
        labelPadding: EdgeInsets.all(2),
        indicatorPadding: EdgeInsets.all(2),
        indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: Colors.deepOrange),
        tabs: List<Widget>.generate(quantity.length, (int index) {
          return new Tab(
            child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.safeBlockHorizontal * 2,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'x ' + quantity[index].toString(),
                  style: Styles.whiteBoldsmall(),
                )),
          );
        }));

    return Scaffold(
      key: scaffoldKey,
      drawer: DrawerWid(),
      body: LoadingOverlay(
          child: SafeArea(
            child: new GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                slidableController.activeState?.close();
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Table(
                  border: TableBorder.all(color: Colors.white, width: 0.6),
                  columnWidths: {
                    0: FractionColumnWidth(.3),
                    1: FractionColumnWidth(.6),
                  },
                  children: [
                    TableRow(children: [
                      TableCell(child: tableHeader2()),
                      TableCell(child: tableHeader1()),
                    ]),
                    TableRow(children: [
                      TableCell(
                        child: Stack(
                          children: <Widget>[
                            Container(
                              // color: Colors.white,
                              child: SizedBox(
                                  height: MediaQuery.of(context).size.height -
                                      SizeConfig.safeBlockVertical * 10,
                                  width: SizeConfig.safeBlockHorizontal * 50,
                                  child: cartITems()),
                            ),
                            /* Positioned(
                              bottom: 25,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 80,
                                color: StaticColor.backgroundColor,
                                child: paybutton(context),
                              ),
                            ), */
                            !isShiftOpen ? openShiftButton(context) : SizedBox()
                          ],
                        ),
                      ),
                      TableCell(
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          padding:
                              EdgeInsets.all(SizeConfig.safeBlockVertical * 1),
                          child: itemSelectedIndex.productQty != null &&
                                  itemSelectedIndex.productQty > 0
                              ? itemEditScreen
                              : Column(
                                  children: <Widget>[
                                    /* subCatList.length == 0?  */
                                    /* Container(
                                      //margin: EdgeInsets.only(left: 5, right: 5),
                                      width: MediaQuery.of(context).size.width,
                                      height: SizeConfig.safeBlockVertical * 8,
                                      color: Colors.black26,
                                      padding: EdgeInsets.all(
                                          SizeConfig.safeBlockVertical * 1.2),
                                      child: DefaultTabController(
                                          initialIndex: 0,
                                          length: categoryFirstRow.length,
                                          child: _tabs),
                                    ),
                                    Container(
                                      //margin: EdgeInsets.only(left: 5, right: 5),
                                      width: MediaQuery.of(context).size.width,
                                      height: SizeConfig.safeBlockVertical * 8,
                                      color: Colors.black26,
                                      padding: EdgeInsets.all(
                                          SizeConfig.safeBlockVertical * 1.2),
                                      child: DefaultTabController(
                                          initialIndex: 0,
                                          length: categorySecondRow.length,
                                          child: _secondTabs),
                                    ), */
                                    //Category Row 1
                                    Container(
                                      height: SizeConfig.safeBlockVertical * 8,
                                      width: MediaQuery.of(context).size.width,
                                      color: Colors.black26,
                                      child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: categoryFirstRow.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              padding: EdgeInsets.all(10.0),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: FlatButton(
                                                onPressed: () {
                                                  _selectedCategory(
                                                      index, 'first');
                                                },
                                                //color: Colors.black,  //Colors.grey.shade800,
                                                color: categoryFirstRow[index]
                                                            .name ==
                                                        selectedCategory?.name
                                                    ? Colors.deepOrange
                                                    : Colors.black26,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  //side: BorderSide(color: Colors.black)
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: SizeConfig
                                                          .safeBlockHorizontal *
                                                      3,
                                                ),
                                                child: Center(
                                                    child: Text(
                                                  categoryFirstRow[index]
                                                      .name
                                                      .toUpperCase(),
                                                  style:
                                                      Styles.whiteBoldsmall(),
                                                )),
                                              ),
                                            );
                                          }),
                                    ),
                                    Container(
                                      height: SizeConfig.safeBlockVertical * 8,
                                      width: MediaQuery.of(context).size.width,
                                      color: Colors.black26,
                                      child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: categorySecondRow.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              padding: EdgeInsets.all(10.0),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: FlatButton(
                                                onPressed: () {
                                                  _selectedCategory(
                                                      index, 'second');
                                                },
                                                //color: Colors.black,  //Colors.grey.shade800,
                                                color: categorySecondRow[index]
                                                            .name ==
                                                        selectedCategory?.name
                                                    ? Colors.deepOrange
                                                    : Colors.black26,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  //side: BorderSide(color: Colors.black)
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: SizeConfig
                                                          .safeBlockHorizontal *
                                                      3,
                                                ),
                                                child: Center(
                                                    child: Text(
                                                  categorySecondRow[index]
                                                      .name
                                                      .toUpperCase(),
                                                  style:
                                                      Styles.whiteBoldsmall(),
                                                )),
                                              ),
                                            );
                                          }),
                                    ),
                                    /*  : Container(
                                      //  margin: EdgeInsets.only(left: 5, right: 5),
                                      width: MediaQuery.of(context).size.width,
                                      height: SizeConfig.safeBlockVertical * 8,
                                      color: Colors.black26,
                                      padding: EdgeInsets.all(
                                          SizeConfig.safeBlockVertical * 1.2),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          IconButton(
                                              onPressed: _backtoMainCat,
                                              icon: Icon(
                                                Icons.arrow_back,
                                                color: Colors.white,
                                                size: SizeConfig
                                                        .safeBlockVertical *
                                                    4,
                                              )),
                                          DefaultTabController(
                                              initialIndex: 0,
                                              length: subCatList.length,
                                              child: _subtabs),
                                        ],
                                      ),
                                    ), */
                                    SingleChildScrollView(
                                      physics: BouncingScrollPhysics(),
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            mealsList.length > 0
                                                ? setMealsList()
                                                : SizedBox(),
                                            isLoading
                                                ? CommunFun.loader(context)
                                                : productList.length > 0
                                                    ? porductsList()
                                                    : SizedBox(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
          isLoading: isScreenLoad,
          color: Colors.black87,
          progressIndicator: CommunFun.overLayLoader()),
      bottomNavigationBar: Container(
        height: SizeConfig.safeBlockVertical * 7,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.grey),
          color: Color(0xFF434449), //scaffold color
        ),
        child: paybutton(context),
      ),
    );
  }

  // Widget drawerWidget() {
  //   return Container(
  //     width: MediaQuery.of(context).size.width / 3.2,
  //     height: MediaQuery.of(context).size.height,
  //     padding: EdgeInsets.only(
  //       top: 20,
  //     ),
  //     color: Colors.white,
  //     child: Drawer(
  //       child: ListView(
  //         padding: EdgeInsets.only(top: 10, left: 10, right: 10),
  //         physics: BouncingScrollPhysics(),
  //         children: <Widget>[
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: <Widget>[
  //               checkoutbtn(),
  //               SizedBox(width: SizeConfig.safeBlockVertical * 3),
  //               nameBtn()
  //             ],
  //           ),
  //           CommunFun.divider(),
  //           permissions.contains(Constant.VIEW_ORDER)
  //               ? ListTile(
  //                   onTap: () {
  //                     gotoTansactionPage();
  //                   },
  //                   leading: Icon(
  //                     Icons.art_track,
  //                     color: Colors.black,
  //                     size: SizeConfig.safeBlockVertical * 5,
  //                   ),
  //                   title: Text(
  //                     "Transaction",
  //                     style: Styles.drawerText(),
  //                   ),
  //                 )
  //               : SizedBox(),
  //           permissions.contains(Constant.VIEW_ORDER)
  //               ? ListTile(
  //                   onTap: () {
  //                     gotoWebCart();
  //                   },
  //                   leading: Icon(
  //                     Icons.shopping_cart,
  //                     color: Colors.black,
  //                     size: SizeConfig.safeBlockVertical * 5,
  //                   ),
  //                   title: Text(
  //                     "Web Orders",
  //                     style: Styles.drawerText(),
  //                   ),
  //                 )
  //               : SizedBox(),
  //           ListTile(
  //               onTap: () {
  //                 Navigator.of(context).pop();
  //                 if (isShiftOpen) {
  //                   closeShift();
  //                 } else {
  //                   openOpningAmmountPop(Strings.title_opening_amount);
  //                 }
  //               },
  //               leading: Icon(
  //                 Icons.open_in_new,
  //                 color: Colors.black,
  //                 size: SizeConfig.safeBlockVertical * 5,
  //               ),
  //               title: Text(isShiftOpen ? "Close Shift" : "Open Shift",
  //                   style: Styles.drawerText())),
  //           permissions.contains(Constant.VIEW_REPORT)
  //               ? ListTile(
  //                   onTap: () {
  //                     gotoShiftReport();
  //                   },
  //                   leading: Icon(
  //                     Icons.filter_tilt_shift,
  //                     color: Colors.black,
  //                     size: SizeConfig.safeBlockVertical * 5,
  //                   ),
  //                   title: Text(
  //                     "Shift Report",
  //                     style: Styles.drawerText(),
  //                   ),
  //                 )
  //               : SizedBox(),
  //           // permissions.contains(Constant.VIEW_ORDER)
  //           ListTile(
  //               onTap: () {
  //                 Navigator.of(context).pop();
  //                 syncOrdersTodatabase();
  //               },
  //               leading: Icon(
  //                 Icons.transform,
  //                 color: Colors.black,
  //                 size: SizeConfig.safeBlockVertical * 5,
  //               ),
  //               title: Text("Sync Orders", style: Styles.drawerText())),
  //           // : SizedBox(),
  //           ListTile(
  //               onTap: () async {
  //                 syncAllTables();
  //               },
  //               leading: Icon(
  //                 Icons.sync,
  //                 color: Colors.black,
  //                 size: SizeConfig.safeBlockVertical * 5,
  //               ),
  //               title: Text("Sync", style: Styles.drawerText())),
  //           ListTile(
  //               onTap: () {
  //                 Navigator.of(context).pop();
  //                 Navigator.pushNamed(context, Constant.SettingsScreen);
  //               },
  //               leading: Icon(
  //                 Icons.settings,
  //                 color: Colors.black,
  //                 size: SizeConfig.safeBlockVertical * 5,
  //               ),
  //               title: Text("Settings", style: Styles.drawerText())),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget tableHeader1() {
    // products Header part 1
    return Container(
      height: SizeConfig.safeBlockVertical * 11,
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
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: SizeConfig.safeBlockVertical * 5,
                  )),
              SizedBox(width: SizeConfig.safeBlockVertical * 3),
              SizedBox(width: SizeConfig.safeBlockVertical * 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  //!isWebOrder ? addCustomerBtn(context) : SizedBox(),
                  menubutton(() {
                    // opneMenuButton();
                  })
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget tableHeader2() {
    // products Header part 2
    return Container(
      padding: EdgeInsets.only(left: 5, right: 5),
      height: SizeConfig.safeBlockVertical * 11,
      // color: Colors.blue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          selectedTable != null
              ? Expanded(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.person,
                        color: Colors.white,
                        size: SizeConfig.safeBlockVertical * 4,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        tableName +
                            " (" +
                            selectedTable.number_of_pax.toString() +
                            ")",
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        textAlign: TextAlign.start,
                        style: Styles.whiteBoldsmall(),
                      ),
                    ],
                  ),
                )
              : SizedBox(),
          Expanded(
            child: TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _textController,
                style: Styles.communBlacksmall(),
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.only(left: 20, top: 0, bottom: 0),
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(
                          right: SizeConfig.safeBlockVertical * 3),
                      child: Icon(
                        Icons.search,
                        color: Colors.deepOrange,
                        size: SizeConfig.safeBlockVertical * 5,
                      ),
                    ),
                    hintText: Strings.search_bar_text,
                    hintStyle: Styles.communGrey(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white),
              ),
              suggestionsCallback: (pattern) async {
                return SearchProductList;
              },
              itemBuilder: (context, SearchProductList) {
                // var image_Arr = SearchProductList.base64
                //     .replaceAll("data:image/jpg;base64,", '');
                return ListTile(
                    leading: Container(
                      color: Colors.grey,
                      width: 40,
                      height: 40,
                      child: SearchProductList.base64 != ""
                          ? CommonUtils.imageFromBase64String(
                              SearchProductList.base64)
                          : new Image.asset(
                              Strings.no_image,
                              gaplessPlayback: true,
                              fit: BoxFit.cover,
                            ),
                    ),
                    title: Text(
                      SearchProductList.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(SearchProductList.price.toString()),
                    trailing: SearchProductList.qty != null &&
                            SearchProductList.hasInventory == 1 &&
                            SearchProductList.qty <= 0
                        ? Text(Strings.out_of_stoke,
                            style: Styles.orangesimpleSmall())
                        : SizedBox());
              },
              onSuggestionSelected: (suggestion) {
                if (permissions.contains(Constant.ADD_ORDER)) {
                  if (suggestion.qty == null ||
                      suggestion.hasInventory != 1 ||
                      suggestion.qty > 0.0) {
                    if (isShiftOpen) {
                      if (isTableSelected && !isWebOrder) {
                        showQuantityDailog(suggestion, false);
                      } else {
                        if (!isWebOrder) {
                          selectTable();
                        }
                      }
                    } else {
                      CommunFun.showToast(context, Strings.shift_open_message);
                    }
                  } else {
                    CommunFun.showToast(context, Strings.out_of_stoke_msg);
                  }
                }
                // Navigator.of(context).push(MaterialPageRoute(
                //     //builder: (context) => ProductPage(product: suggestion)
                //     ));
              },
            ),
          )
        ],
      ),
    );
  }

  Widget addCustomerBtn(context) {
    return customer == null && permissions.contains(Constant.ADD_ORDER)
        ? RaisedButton(
            padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
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
                  size: SizeConfig.safeBlockVertical * 3,
                ),
                SizedBox(width: 5),
                Text(Strings.btn_Add_customer.toUpperCase(),
                    style: Styles.whiteBoldsmall()),
              ],
            ),
            color: Colors.deepOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
          )
        : SizedBox();
  }

  Widget menubutton(Function _onPress) {
    return PopupMenuButton(
        padding: EdgeInsets.all(0),
        icon: Icon(Icons.more_vert,
            color: Colors.white, size: SizeConfig.safeBlockVertical * 5),
        offset: Offset(0, 100),
        // onSelected: 0,
        onSelected: selectOption,
        itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                enabled: isShiftOpen ? true : false,
                value: 0,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.select_all,
                        color: Colors.black,
                        size: SizeConfig.safeBlockVertical * 5,
                      ),
                      SizedBox(width: 15),
                      Text(Strings.select_table,
                          style: Styles.communBlacksmall()),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                enabled: isTableSelected ? true : false,
                value: 1,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.close,
                        color: Colors.black,
                        size: SizeConfig.safeBlockVertical * 5,
                      ),
                      SizedBox(width: 15),
                      Text(Strings.close_table,
                          style: Styles.communBlacksmall())
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                enabled: cartList.length > 1 ? true : false,
                value: 2,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.call_split,
                        color: Colors.black,
                        size: SizeConfig.safeBlockVertical * 5,
                      ),
                      SizedBox(width: 15),
                      Text(Strings.split_order,
                          style: Styles.communBlacksmall()),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                enabled: isShiftOpen ? true : false,
                value: 3,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.call_split,
                        color: Colors.black,
                        size: SizeConfig.safeBlockVertical * 5,
                      ),
                      SizedBox(width: 15),
                      Text(Strings.close_shift,
                          style: Styles.communBlacksmall()),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                enabled: (permissions.contains(Constant.ADD_ORDER) ||
                            permissions.contains(Constant.EDIT_ORDER)) &&
                        cartList.length > 0
                    ? true
                    : false,
                value: 4,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.print,
                        color: Colors.black,
                        size: SizeConfig.safeBlockVertical * 5,
                      ),
                      SizedBox(width: 15),
                      Text(Strings.check_list,
                          style: Styles.communBlacksmall()),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                enabled: (permissions.contains(Constant.ADD_ORDER) ||
                            permissions.contains(Constant.EDIT_ORDER)) &&
                        cartList.length > 0
                    ? true
                    : false,
                value: 5,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.print,
                        color: Colors.black,
                        size: SizeConfig.safeBlockVertical * 5,
                      ),
                      SizedBox(width: 15),
                      Text(Strings.draft_report,
                          style: Styles.communBlacksmall()),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                enabled: permissions.contains(Constant.DELETE_ORDER) &&
                        cartList.length > 0
                    ? true
                    : false,
                value: 6,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.delete,
                        color: Colors.black,
                        size: SizeConfig.safeBlockVertical * 5,
                      ),
                      SizedBox(width: 15),
                      Text(Strings.delete_order,
                          style: Styles.communBlacksmall()),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                // enabled: permissions.contains(Constant.DELETE_ORDER) &&
                //         cartList.length > 0
                //     ? true
                //     : false,
                value: 7,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.send,
                        color: Colors.black,
                        size: SizeConfig.safeBlockVertical * 5,
                      ),
                      SizedBox(width: 15),
                      Text(Strings.reprint_Order,
                          style: Styles.communBlacksmall()),
                    ],
                  ),
                ),
              ),
            ]);
  }

  Widget setMealsList() {
    // products List
    var size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    //final double itemHeight = (size.height - kToolbarHeight - 24) / 1.8;
    final double itemHeight = size.width / 4.2;
    final double itemWidth = size.width / 4.2;
    return Container(
      padding: EdgeInsets.only(top: 5),
      child: GridView.count(
        childAspectRatio: (itemWidth / itemHeight),
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: mealsList.map((meal) {
          var proprice = meal.price.toStringAsFixed(2);
          return InkWell(
            onTap: () {
              if (permissions.contains(Constant.EDIT_ORDER)) {
                if (isShiftOpen) {
                  if (isTableSelected && !isWebOrder) {
                    showQuantityDailog(meal, true);
                  } else {
                    if (!isWebOrder) {
                      selectTable();
                    }
                  }
                } else {
                  CommunFun.showToast(context, Strings.shift_open_message);
                }
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
                      tag: meal.setmealId != null ? meal.setmealId : 0,
                      child: Container(
                        color: Colors.grey,
                        width: MediaQuery.of(context).size.width,
                        height: itemHeight / 2.2,
                        child: meal.base64 != ""
                            ? CommonUtils.imageFromBase64String(meal.base64)
                            : new Image.asset(
                                Strings.no_image,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                              ),
                      )),
                  Container(
                    padding: EdgeInsets.all(2),
                    margin: EdgeInsets.only(top: itemHeight / 2.2),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                    ),
                    child: Center(
                      child: Text(
                        meal.name.toString().toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Styles.whiteSmall(),
                      ),
                    ),
                  ),
                  Positioned(
                    top: itemHeight / 2.2 - SizeConfig.safeBlockVertical * 5,
                    left: 0,
                    child: Container(
                      height: SizeConfig.safeBlockVertical * 5,
                      // width: 50,
                      padding: EdgeInsets.all(5),
                      color: Colors.deepOrange,
                      child: Center(
                        child: Text(
                            currency != null
                                ? currency + ' ' + proprice.toString()
                                : proprice.toString(),
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

  Widget porductsList() {
    // products List
    var size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    //final double itemHeight = (size.height - kToolbarHeight - 24) / 1.8;
    final double itemHeight = size.width / 4.2;
    final double itemWidth = size.width / 4.2;
    return Container(
      //color: Colors.lightBlue,
      height: MediaQuery.of(context).size.height / 1.3,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: 10, bottom: 20, left: 0, right: 0),
      child: GridView.count(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        childAspectRatio: (itemWidth / itemHeight),
        crossAxisCount: 4,
        crossAxisSpacing: 9.0,
        mainAxisSpacing: 9.0,
        children: productList.map((product) {
          final prodprice = product.price.toStringAsFixed(2);
          return InkWell(
            onTap: () {
              if (product.qty == null ||
                  product.hasInventory != 1 ||
                  product.qty > 0.0) {
                if (permissions.contains(Constant.ADD_ORDER)) {
                  checkshiftopne(product);
                } else {
                  CommonUtils.openPermissionPop(context, Constant.ADD_ORDER,
                      () {
                    checkshiftopne(product);
                  }, () {});
                }
              } else {
                CommunFun.showToast(context, Strings.out_of_stoke_msg);
              }
            },
            child: Container(
              height: itemHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.all(0),
              child: Stack(
                alignment: AlignmentDirectional.topCenter,
                children: <Widget>[
                  Hero(
                      tag: product.productId != null ? product.productId : 0,
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8)),
                          ),
                          height: itemHeight / 2.2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8)),
                            child: product.base64 != ""
                                ? CommonUtils.imageFromBase64String(
                                    product.base64)
                                : new Image.asset(
                                    Strings.no_image,
                                    fit: BoxFit.cover,
                                    gaplessPlayback: true,
                                  ),
                          ))),
                  Container(
                    padding: EdgeInsets.all(2),
                    margin: EdgeInsets.only(top: itemHeight / 2.2),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8)),
                    ),
                    child: Center(
                      child: Text(
                        product.name.toString().toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Styles.whiteSmall(),
                      ),
                    ),
                  ),
                  Positioned(
                    top: itemHeight / 2.2 - SizeConfig.safeBlockVertical * 5,
                    left: 0,
                    child: Container(
                      height: SizeConfig.safeBlockVertical * 5,
                      // width: 50,
                      padding: EdgeInsets.all(5),
                      color: Colors.deepOrange,
                      child: Center(
                        child: Text(
                            currency != null
                                ? currency + ' ' + prodprice.toString()
                                : prodprice.toString(),
                            style: Styles.whiteSimpleSmall()),
                      ),
                    ),
                  ),
                  product.qty != null &&
                          product.hasInventory == 1 &&
                          product.qty <= 0
                      ? Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            height: SizeConfig.safeBlockVertical * 4,
                            // width: 50,
                            padding: EdgeInsets.all(2),
                            color: Colors.deepOrange,
                            child: Center(
                              child: Text(Strings.out_of_stoke,
                                  style: Styles.whiteSimpleSmall()),
                            ),
                          ),
                        )
                      : SizedBox()
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
        mainAxisAlignment: !isWebOrder
            ? MainAxisAlignment.spaceAround
            : MainAxisAlignment.center,
        children: <Widget>[
          !isWebOrder
              ? Container(
                  //margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 1.3),
                  height: SizeConfig.safeBlockVertical * 5,
                  width: MediaQuery.of(context).size.width / 10,
                  child: RaisedButton(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    onPressed: () {
                      if (permissions.contains(Constant.ADD_ORDER)) {
                        sendTokitched(cartList);
                      } else {
                        CommonUtils.openPermissionPop(
                            context, Constant.ADD_ORDER, () {
                          sendTokitched(cartList);
                        }, () {});
                      }
                    },
                    child: Text(
                      Strings.send,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: SizeConfig.safeBlockVertical * 2.8,
                          fontWeight: FontWeight.bold),
                    ),
                    color: Colors.deepOrange,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ),
                )
              : SizedBox(),
          Container(
            /* margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 1.3 + 10),*/
            height: SizeConfig.safeBlockVertical * 5,
            width: MediaQuery.of(context).size.width / 10,
            child: RaisedButton(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              onPressed: () {
                if (!isWebOrder) {
                  if (permissions.contains(Constant.ADD_ORDER) ||
                      permissions.contains(Constant.EDIT_ORDER)) {
                    sendPayment();
                  } else {
                    CommonUtils.openPermissionPop(context, Constant.ADD_ORDER,
                        () {
                      sendPayment();
                    }, () {});
                  }
                } else {
                  //weborder payment
                  if (permissions.contains(Constant.ADD_ORDER) ||
                      permissions.contains(Constant.EDIT_ORDER)) {
                    checkoutWebOrder();
                  } else {
                    CommonUtils.openPermissionPop(context, Constant.ADD_ORDER,
                        () {
                      checkoutWebOrder();
                    }, () {});
                  }
                }
              },
              child: Text(
                !isWebOrder ? Strings.title_pay : Strings.checkout,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConfig.safeBlockVertical * 2.8,
                    fontWeight: FontWeight.bold),
              ),
              color: Colors.deepOrange,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
          ),
          addCustomerBtn(context),
          Container(
            /* margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 1.3 + 10),*/
            height: SizeConfig.safeBlockVertical * 5,
            width: MediaQuery.of(context).size.width / 10,
            child: RaisedButton(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              onPressed: () {},
              child: Text(
                !isWebOrder ? Strings.title_pay : Strings.checkout,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConfig.safeBlockVertical * 2.8,
                    fontWeight: FontWeight.bold),
              ),
              color: Colors.deepOrange,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
          ),
          PopupMenuItem(
            enabled: isShiftOpen ? true : false,
            value: 0,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.select_all,
                    color: Colors.black,
                    size: SizeConfig.safeBlockVertical * 5,
                  ),
                  SizedBox(width: 15),
                  Text(Strings.select_table, style: Styles.communBlacksmall()),
                ],
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
          color: Colors.white70.withOpacity(0.9),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                Strings.shiftTextLable,
                style: TextStyle(fontSize: SizeConfig.safeBlockVertical * 4),
              ),
              SizedBox(height: 15),
              Text(
                Strings.closed,
                style: TextStyle(
                    fontSize: SizeConfig.safeBlockVertical * 6,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              shiftbtn(() {
                openOpningAmmountPop(Strings.title_opening_amount);
              })
            ],
          ),
        ),
      ),
    );
  }

  Widget shiftbtn(Function onPress) {
    return RaisedButton(
      padding: EdgeInsets.only(top: 15, left: 30, right: 30, bottom: 15),
      onPressed: onPress,
      child: Text(
        Strings.open_shift,
        style: TextStyle(
            color: Colors.deepOrange,
            fontSize: SizeConfig.safeBlockVertical * 4),
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
    final customerdatawidget = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Icon(
          Icons.account_circle,
          color: Colors.grey,
          size: SizeConfig.safeBlockVertical * 4,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 5,
            ),
            Text(customer != null ? customer.name : ""),
            Text(customer != null ? customer.email : ""),
          ],
        ),
        IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: SizeConfig.safeBlockVertical * 4,
            ),
            onPressed: () {
              removeCutomer();
            })
      ],
    );

    final carttitle = Row(
      children: <Widget>[
        Expanded(
          child: Text('  ' + Strings.header_name, style: Styles.darkBlue()),
          flex: 6,
        ),
        Expanded(
          child: Text(
            Strings.qty,
            style: Styles.darkBlue(),
            textAlign: TextAlign.end,
          ),
          flex: 1,
        ),
        Expanded(
          child: Text(
            Strings.amount,
            style: Styles.darkBlue(),
            textAlign: TextAlign.end,
          ),
          flex: 2,
        ),
        Expanded(
          child: Icon(Icons.delete_forever),
          flex: 1,
        ),
      ],
    );

    final cartTable = ListView(
      //physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      // itemExtent:60.0,
      padding: EdgeInsets.only(bottom: 200),
      children: cartList.map((cart) {
        return Slidable(
          key: Key(cart.id.toString()),
          controller: slidableController,
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.15,
          direction: Axis.horizontal,
          child: GestureDetector(
            onTap: () => setState(() {
              if (cart.id == itemSelectedIndex.id) {
                itemSelectedIndex = new MSTCartdetails();
              } else {
                itemSelectedIndex = cart;
              }
            }),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              color: cart.id == itemSelectedIndex.id
                  ? Colors.deepOrange[400]
                  : Colors.transparent,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('  ' + cart.productName.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.clip,
                            style: Styles.greysmall()),
                        cart.attrName != null
                            ? Text(" (" + cart.attrName + ") ",
                                maxLines: 2,
                                overflow: TextOverflow.clip,
                                style: Styles.greysmall())
                            : SizedBox(),
                        cart.modiName != null
                            ? Text(" (" + cart.modiName + ") ",
                                maxLines: 2,
                                overflow: TextOverflow.clip,
                                style: Styles.greysmall())
                            : SizedBox(),
                      ],
                    ),
                    flex: 6,
                  ),
                  Expanded(
                    child: Text(
                      cart.productQty.toString(),
                      style: Styles.greysmall(),
                      textAlign: TextAlign.end,
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Text(
                      cart.productPrice.toStringAsFixed(2),
                      style: Styles.greysmall(),
                      textAlign: TextAlign.end,
                    ),
                    flex: 2,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (permissions.contains(Constant.DELETE_ITEM)) {
                          itememovefromCart(itemSelectedIndex);
                        } else {
                          CommonUtils.openPermissionPop(
                              context, Constant.DELETE_ITEM, () {
                            itememovefromCart(itemSelectedIndex);
                            setState(() {
                              itemSelectedIndex = new MSTCartdetails();
                            });
                          }, () {});
                        }
                      },
                      child: Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                    flex: 1,
                  ),
                ],
              ),
            ),
          ),
          secondaryActions: isWebOrder
              ? <Widget>[
                  cart.issetMeal == 0
                      ? IconSlideAction(
                          color: Colors.blueAccent,
                          icon: Icons.free_breakfast,
                          onTap: () {
                            if (permissions.contains(Constant.EDIT_ITEM)) {
                              applyforFocProduct(cart);
                            } else {
                              CommonUtils.openPermissionPop(
                                  context, Constant.EDIT_ITEM, () {
                                applyforFocProduct(cart);
                              }, () {});
                            }
                          },
                        )
                      : SizedBox(),
                ]
              : <Widget>[
                  cart.issetMeal == 0
                      ? IconSlideAction(
                          color: Colors.blueAccent,
                          icon: Icons.free_breakfast,
                          onTap: () {
                            if (permissions.contains(Constant.EDIT_ITEM)) {
                              applyforFocProduct(cart);
                            } else {
                              CommonUtils.openPermissionPop(
                                  context, Constant.EDIT_ITEM, () {
                                applyforFocProduct(cart);
                              }, () {});
                            }
                          },
                        )
                      : SizedBox(),
                  IconSlideAction(
                    color: Colors.black45,
                    icon: Icons.edit,
                    onTap: () {
                      if (cart.isFocProduct != 1) {
                        if (permissions.contains(Constant.EDIT_ORDER)) {
                          editCartItem(cart);
                        } else {
                          CommonUtils.openPermissionPop(
                              context, Constant.EDIT_ORDER, () {
                            editCartItem(cart);
                          }, () {});
                        }
                      } else {
                        CommunFun.showToast(context, Strings.foc_product_msg);
                      }
                    },
                  ),
                  IconSlideAction(
                    color: Colors.red,
                    icon: Icons.delete_outline,
                    onTap: () {
                      if (permissions.contains(Constant.DELETE_ORDER)) {
                        itememovefromCart(cart);
                      } else {
                        CommonUtils.openPermissionPop(
                            context, Constant.DELETE_ORDER, () {
                          itememovefromCart(cart);
                        }, () {});
                      }
                    },
                  )
                ],
        );
      }).toList(),
    );
    var vaucher = allcartData != null &&
            allcartData.voucher_detail != null &&
            allcartData.voucher_detail != ""
        ? json.decode(allcartData.voucher_detail)
        : null;

    final totalPriceTable = Padding(
      padding: EdgeInsets.only(
        bottom: 10,
      ),
      child: ExpandablePanel(
        header: Builder(
          builder: (context) {
            expandableController = ExpandableController.of(context);
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                InkWell(
                  child: Icon(
                    expandableController.expanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    size: 40,
                  ),
                  onTap: () {
                    expandableController.toggle();
                  },
                ),
              ],
            );
          },
        ),
        collapsed: ExpandableButton(
          child: Column(
            children: <Widget>[
              Divider(
                color: Colors.black,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(Strings.total, style: Styles.darkBlue()),
                    Text(
                      grandTotal.toStringAsFixed(2),
                      style: Styles.darkBlue(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        expanded: ExpandableButton(
          child: Column(
            children: <Widget>[
              Divider(
                color: Colors.black,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 5, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      Strings.sub_total.toUpperCase(),
                      style: Styles.darkBlue(),
                    ),
                    Text(
                      subtotal.toStringAsFixed(2),
                      style: Styles.darkBlue(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 5, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      Strings.discount.toUpperCase(),
                      style: Styles.orangeDis(),
                    ),
                    Text(
                      discount.toStringAsFixed(2),
                      style: Styles.orangeDis(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 5, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      Strings.service_charge.toUpperCase() +
                          "($serviceChargePer%)",
                      style: Styles.darkBlue(),
                    ),
                    Text(
                      serviceCharge.toStringAsFixed(2),
                      style: Styles.darkBlue(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 5, right: 10),
                child: taxJson.length != 0
                    ? Column(
                        children: taxJson.map((taxitem) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                Strings.tax.toUpperCase() +
                                    " " +
                                    taxitem["taxCode"] +
                                    "(" +
                                    taxitem["rate"] +
                                    "%)",
                                style: Styles.darkBlue(),
                              ),
                              Text(taxitem["taxAmount"].toString(),
                                  style: Styles.darkBlue()),
                            ],
                          );
                        }).toList(),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            Strings.tax.toUpperCase(),
                            style: Styles.darkBlue(),
                          ),
                          Text(
                            tax.toStringAsFixed(2),
                            style: Styles.darkBlue(),
                          ),
                        ],
                      ),
              ),
              Divider(
                color: Colors.black,
                thickness: 1,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 5, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(Strings.grand_total, style: Styles.darkBlue()),
                    Text(
                      grandTotal.toStringAsFixed(2),
                      style: Styles.darkBlue(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        theme: const ExpandableThemeData(
          tapBodyToCollapse: true,
          tapBodyToExpand: true,
          tapHeaderToExpand: true,
          expandIcon: Icons.arrow_drop_up,
          collapseIcon: Icons.arrow_drop_down,
          iconSize: 35.0,
          hasIcon: false,
        ),
      ),
    );
    return Column(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height -
              SizeConfig.safeBlockVertical * 10,
          color: Colors.grey[300],
          padding: EdgeInsets.all(0),
          child: Stack(
            children: <Widget>[
              customer != null
                  ? Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      height: 50,
                      width: MediaQuery.of(context).size.width / 1.2,
                      child: customerdatawidget)
                  : SizedBox(),
              cartList.length != 0
                  ? Container(
                      width: MediaQuery.of(context).size.width / 1.2,
                      margin: EdgeInsets.only(top: customer != null ? 50 : 0),
                      color: Colors.white,
                      padding: EdgeInsets.all(5),
                      child: carttitle,
                    )
                  : SizedBox(),
              Container(
                  //  color: Colors.amber,
                  //color: Colors.red,
                  height: MediaQuery.of(context).size.height / 2,
                  margin: EdgeInsets.only(top: customer != null ? 85 : 35),
                  child: cartTable),
              cartList.length != 0
                  ? Positioned(
                      bottom: 100,
                      left: 0,
                      right: 0,
                      child: Container(
                          color: Colors.grey[300], child: totalPriceTable),
                    )
                  : Center(
                      child: Text(
                        Strings.item_not_available,
                        style: Styles.communBlacksmall(),
                      ),
                    )
            ],
          ),
        ),
      ],
    );
  }
}
