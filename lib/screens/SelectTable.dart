import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mcncashier/components/DrawerWidget.dart';
import 'package:mcncashier/components/QrScanAndGenrate.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/helpers/LocalAPI/Cart.dart';
import 'package:mcncashier/helpers/LocalAPI/PrinterList.dart';
import 'package:mcncashier/helpers/LocalAPI/TablesList.dart';
import 'package:mcncashier/models/Printer.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/models/Table_order.dart';
import 'package:mcncashier/models/Terminal.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/models/saveOrder.dart';
import 'package:mcncashier/printer/printerconfig.dart';
import 'package:mcncashier/screens/OpningAmountPop.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/models/TableDetails.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:mcncashier/models/colorTable.dart';

import '../components/communText.dart';
import '../helpers/LocalAPI/OrdersList.dart';
import '../helpers/LocalAPI/ShiftList.dart';

class SelectTablePage extends StatefulWidget {
  // PIN Enter PAGE
  SelectTablePage({Key key}) : super(key: key);

  @override
  _SelectTablePageState createState() => _SelectTablePageState();
}

class _SelectTablePageState extends State<SelectTablePage>
    with SingleTickerProviderStateMixin {
  TextEditingController paxController = new TextEditingController();
  GlobalKey<ScaffoldState> scaffoldKey;
  LocalAPI localAPI = LocalAPI();
  TablesList tabList = new TablesList();
  Cartlist cartlist = new Cartlist();
  OrdersList ordersList = new OrdersList();
  PrinterList printerAPI = new PrinterList();
  ShiftList shiftList = new ShiftList();
  List<TablesDetails> tableList = new List<TablesDetails>();
  List<int> mergeTableList = [];
  PrintReceipt printKOT = PrintReceipt();
  List<Printer> printerList = new List<Printer>();
  List<Printer> printerreceiptList = new List<Printer>();
  TablesDetails selectedTable;
  var number_of_pax;
  var orderid;
  TablesDetails mergeInTable;
  TablesDetails changeInTable;
  bool isLoading = false;
  bool isMergeing = false;
  bool isChangingTable = false;
  bool isAssigning = false;
  String qrCodeString = "";
  bool isChanging = false;
  bool isShiftOpen = true;
  bool isMenuOpne = true;
  bool changingColors = false;
  var permissions = "";
  TabController _tabController;
  MaterialColor tableSelectedColor = Colors.orange;
  List<ColorTable> tableColors = new List<ColorTable>();

  @override
  void initState() {
    super.initState();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
    _tabController = new TabController(length: 2, vsync: this);
    
    checkisInit();
    checkISlogin();
  }

  checkisInit() async {
    var isInit = await CommunFun.checkDatabaseExit();
    if (isInit == true) {
      afterInit();
    } else {
      await databaseHelper.initializeDatabase();
      afterInit();
    }
  }

  afterInit() {
    getTables();
    checkshift();
    getAllPrinter();
    setPermissons();
  }

  setPermissons() async {
    var permission = await CommunFun.getPemission();
    setState(() {
      permissions = permission;
    });
  }

  checkISlogin() async {
    var loginUser = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
    if (loginUser == null) {
      Navigator.pushNamed(context, Constant.PINScreen);
    }
  }

  checkshift() async {
    /*Set terminal name for print receipt only */
    if (Strings.terminalName.isEmpty) {
      var terminalkey = await CommunFun.getTeminalKey();
      Terminal terminalData = await branchapi.getTerminalDetails(terminalkey);
      if (terminalData != null) {
        Strings.terminalName = terminalData.terminalName;
      }
    }

    var isOpen = await Preferences.getStringValuesSF(Constant.IS_SHIFT_OPEN);
    setState(() {
      isShiftOpen = isOpen != null && isOpen == "true" ? true : false;
    });
  }

  getTables() async {
    setState(() {
      isLoading = true;
    });
    var branchid = await CommunFun.getbranchId();
    List<TablesDetails> tables = await tabList.getTables(context, branchid);
    setState(() {
      tableList = tables;
      isLoading = false;
    });
  }

  viewOrder() async {
    // view order data if already order in table
    var tableid = selectedTable.tableId;
    List<Table_order> order = await tabList.getTableOrders(tableid);
    await Preferences.setStringToSF(Constant.TABLE_DATA, json.encode(order[0]));
    setState(() {
      isMenuOpne = true;
      //isMenuOpne = false;
    });
    Navigator.pushNamed(context, Constant.DashboardScreen);
  }

  ontableTap(table) async {
    setState(() {
      selectedTable = table;
      isMenuOpne = true;
    });
    paxController.text =
        table.numberofpax != null ? table.numberofpax.toString() : "";
    var tableid = selectedTable.tableId;
    List<Table_order> order = await tabList.getTableOrders(tableid);
    if (order.length > 0) {
      viewOrder();
    } else {
      addNewOrder();
    }
  }

  ontableLongTap(table) {
    setState(() {
      selectedTable = table;
      //isMenuOpne = true;
    });
    paxController.text =
        table.numberofpax != null ? table.numberofpax.toString() : "";
  }

changeColors() {
  Future.delayed(Duration(seconds: 1), () {
    setState(() {
      tableSelectedColor = (tableSelectedColor == null || tableSelectedColor == Colors.orange) ? Colors.grey : Colors.orange;
      if(isMergeing || isChangingTable) {
        changeColors();
        changingColors = true;
      } else changingColors = false;
    });
  });
}
  mergeTabledata(TablesDetails table) async {
    setState(() {
      isLoading = true;
    });
    // Merge table
    TablesDetails table1 = mergeInTable;
    TablesDetails table2 = table;
    Table_order table_order = new Table_order();
    var pax = table1.numberofpax != null ? table1.numberofpax : 0;
    pax += table2.numberofpax != null ? table2.numberofpax : 0;
    table_order.number_of_pax = pax ?? 0;
    table_order.table_id = table1.tableId;
    table_order.save_order_id =
        table1.saveorderid != 0 ? table1.saveorderid : 0;
    table_order.is_merge_table = "1";
    table_order.merged_table_id = table2.tableId;
    var result = await tabList.mergeTableOrder(context, table_order);
    setState(() {
      isMergeing = false;
      mergeInTable = null;
      isLoading = false;
    });
    CommunFun.showToast(context, Strings.table_mearged_msg);
    getTables();
  }

  mergeTable(table) {
    setState(() {
      isMenuOpne = true;
      //isMenuOpne = false;
      if (isMergeing && mergeInTable == table) {
        isMergeing = false;
        mergeInTable = null;
      } else {
        isMergeing = true;
        mergeInTable = table;
      }
      selectedTable=null;
      if(!changingColors) changeColors();
    });
  }

  selectTableForNewOrder() async {
    //if ((int.tryParse(paxController.text) ?? 0) <= selectedTable.tableCapacity) {
    Table_order tableOrder = new Table_order();
    tableOrder.table_id = selectedTable.tableId;
    tableOrder.number_of_pax = (int.tryParse(paxController.text) ?? 0);
    tableOrder.save_order_id = selectedTable.saveorderid;
    tableOrder.service_charge =
        CommunFun.getDoubleValue(selectedTable.tableServiceCharge);
    await tabList.insertTableOrder(context, tableOrder);
    await Preferences.setStringToSF(
        Constant.TABLE_DATA, json.encode(tableOrder));
    paxController.text = "";
    Navigator.of(context).pop();
    if (!isChanging) {
      setState(() {
        isMenuOpne = true;
        //isMenuOpne = false;
      });
      Navigator.pushNamed(context, Constant.DashboardScreen);
    }
    getTables();
  }
  /*   else {
      CommunFun.showToast(context, Strings.table_pax_msg);
    }
  } */

  assignTabletoOrder() async {
    setState(() {
      isLoading = true;
    });
    if (int.tryParse(paxController.text) <= selectedTable.tableCapacity) {
      SaveOrder orderData = new SaveOrder();
      orderData.orderName = selectedTable.tableName;
      orderData.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
      orderData.numberofPax = int.tryParse(paxController.text);
      orderData.cartId = orderid;
      Table_order tableorder = new Table_order();
      tableorder.table_id = selectedTable.tableId;
      tableorder.number_of_pax = (int.tryParse(paxController.text) ?? 0);
      tableorder.service_charge = selectedTable.tableServiceCharge;
      var saveorderid =
          await cartlist.addSaveOrder(orderData, selectedTable.tableId);
      tableorder.save_order_id = saveorderid;
      var tab = await tabList.insertTableOrder(context, tableorder);
      Navigator.of(context).pop();
      Navigator.pushNamed(context, Constant.WebOrderPages);
    } else {
      CommunFun.showToast(context, Strings.table_pax_msg);
    }
  }

  opnPaxDailog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return paxalertDailog(context);
      },
    );
  }

  opneQrcodePop() async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return QRCodesImagePop(
            ip: selectedTable.tableQr,
            onClose: () {},
          );
        });
  }

  cancleTableOrder() async {
    CommonUtils.showAlertDialog(context, () {
      Navigator.of(context).pop();
    }, () async {
      Navigator.of(context).pop();
      cancleTOrder();
    }, Strings.warning, Strings.cancle_order_msg, Strings.yes, Strings.no,
        true);
  }

  cancleTOrder() async {
    setState(() {
      isLoading = true;
      if(selectedTable.merged_table_id != null) {
        mergeTableList.remove(selectedTable.merged_table_id);
      }
    });
    if (selectedTable.saveorderid != null && selectedTable.saveorderid != 0) {
      // List<SaveOrder> cartID =
      //     await localAPI.gettableCartID(selectedTable.saveorderid);
      // if (cartID.length > 0) {
      await ordersList.removeCart(selectedTable.saveorderid, selectedTable.tableId);
      // }
    } else {
      await tabList.deleteTableOrder(selectedTable.tableId);
    }
    await Preferences.removeSinglePref(Constant.TABLE_DATA);
    setState(() {
      isLoading = false;
      isMenuOpne = true;
      selectedTable = null;
      //isMenuOpne = false;
    });
    await getTables();
  }

  changeTablePop() {
    CommonUtils.showAlertDialog(context, () {
      Navigator.of(context).pop();
    }, () {
      Navigator.of(context).pop();
      setState(() {
        isMenuOpne = true;
        //isMenuOpne = false;
        isChangingTable = true;
        if(!changingColors) changeColors();
      });
    }, Strings.warning, Strings.change_table_msg, Strings.yes, Strings.no,
        true);
  }

  changeTableToOtherTable(table) async {
    var cartid;
    // if (selectedTable.saveorderid != null && selectedTable.saveorderid != 0) {
    //   List<SaveOrder> cartID =
    //       await localAPI.gettableCartID(selectedTable.saveorderid);
    //   if (cartID.length > 0) {
    //     cartid = cartID[0].cartId;
    //   }
    // }
    await tabList.changeTable(selectedTable.tableId, table.tableId, cartid);
    var tableid = await Preferences.getStringValuesSF(Constant.TABLE_DATA);
    if (tableid != null) {
      var tableddata = json.decode(tableid);
      Table_order tabledata = Table_order.fromJson(tableddata);
      if (tabledata.table_id == selectedTable.tableId) {
        tabledata.table_id = table.tableId;
        tabledata.service_charge = table.tableServiceCharge;

        await Preferences.setStringToSF(
            Constant.TABLE_DATA, jsonEncode(tabledata));
           
      }
    }
    await getTables(); 
    setState(() {
      changeInTable = null;
      isChangingTable = false;
      selectedTable = null;
    });
  }

  changePax() {
    setState(() {
      isChanging = true;
    });
    opnPaxDailog();
  }

  getTablesColor() async {
    List<ColorTable> tables = await localAPI.getTablesColor();
    setState(() {
      tableColors = tables;
      isLoading = false;
    });
  }

  addNewOrder() {
    setState(() {
      isChanging = false;
    });
    selectTableForNewOrder();
    //opnPaxDailog();
  }

  void selectOption(choice) {
    // Causes the app to rebuild with the new _selectedChoice.
  }

  openDrawer() {
    scaffoldKey.currentState.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _willPopCallback() async {
      return false;
    }

    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    SizeConfig().init(context);
    setState(() {
      isAssigning = arguments['isAssign'];
      orderid = arguments['orderID'];
    });
    return WillPopScope(
      child: Scaffold(
        key: scaffoldKey,
        drawer: DrawerWid(),
        appBar: AppBar(
          centerTitle: false,
          leading: IconButton(
              onPressed: () {
                scaffoldKey.currentState.openDrawer();
              },
              icon: Icon(
                Icons.dehaze,
                color: Colors.white,
                size: SizeConfig.safeBlockVertical * 5,
              )),
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: SizedBox(
            height: SizeConfig.safeBlockVertical * 5,
            child: Image.asset(Strings.asset_headerLogo,
                fit: BoxFit.contain, gaplessPlayback: true),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            unselectedLabelColor: Colors.white,
            unselectedLabelStyle: Styles.whiteBoldsmall(),
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
                    Strings.dine_in,
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
                    Strings.take_away,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: <Widget>[
            new GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: SafeArea(
                  child: Stack(children: <Widget>[
                    TabBarView(
                      controller: _tabController,
                      physics: AlwaysScrollableScrollPhysics(),
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  padding: EdgeInsets.all(10),
                                  height: MediaQuery.of(context).size.height,
                                  width: isMenuOpne
                                      ? MediaQuery.of(context).size.width / 1.5
                                      : MediaQuery.of(context).size.width,
                                  child: tablesListwidget(1)),
                              menuItemDiv()
                            ],
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  padding: EdgeInsets.all(10),
                                  height: MediaQuery.of(context).size.height,
                                  width: isMenuOpne
                                      ? MediaQuery.of(context).size.width / 1.5
                                      : MediaQuery.of(context).size.width,
                                  child: tablesListwidget(2)),
                              menuItemDiv()
                            ],
                          ),
                        ),
                      ],
                    )
                  ]),
                )),
            !isShiftOpen
                ? Positioned(
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
                              style: TextStyle(
                                  fontSize: SizeConfig.safeBlockVertical * 4),
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
                              openOpningAmmountPop(
                                  Strings.title_opening_amount);
                            })
                          ],
                        ),
                      ),
                    ),
                  )
                : SizedBox()
          ],
        ),
      ),
      onWillPop: _willPopCallback,
    );
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
    int appid = await shiftList.getLastShiftAppID(terminalId);
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
    var result = await shiftList.insertShift(context, shift, shiftid);
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

  openOpningAmmountPop(isopning) async {
    await showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return OpeningAmmountPage(
              ammountext: isopning,
              onEnter: (ammountext) {
                sendOpenShft(ammountext);
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
              });
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

  Widget openShiftButton(context) {
    // Payment button
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: Center(
        child: Container(
          color: Colors.black87,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                Strings.shiftTextLable,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConfig.safeBlockVertical * 4),
              ),
              SizedBox(height: 25),
              Text(
                Strings.closed,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConfig.safeBlockVertical * 6,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
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

  Widget menuItemDiv() {
    return isMenuOpne
        ? Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width / 3.5,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: optionsList(context))
        : SizedBox();
  }

  Widget optionsList(context) {
    return ListView(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      children: [
        selectedTable == null
            ? Container(
                height: MediaQuery.of(context).size.height * .6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Select a Table',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              )
            : SizedBox(),
        selectedTable != null
            ? Text(
                selectedTable.numberofpax == null
                    ? selectedTable.tableName
                    : selectedTable.tableName +
                        " : " +
                        selectedTable.numberofpax.toString(),
                textAlign: TextAlign.center,
                style: Styles.whiteMediumBold(),
              )
            : SizedBox(),
        selectedTable != null && selectedTable.numberofpax == null
            ? neworder_button(
                Icons.supervised_user_circle, Strings.new_order, context, () {
                addNewOrder();
              })
            : SizedBox(),
        selectedTable != null && selectedTable.numberofpax != null
            ? neworder_button(
                Icons.supervised_user_circle, Strings.change_pax, context, () {
                changePax();
              })
            : SizedBox(),
        selectedTable != null && selectedTable.numberofpax != null
            ? neworder_button(Icons.remove_red_eye, Strings.view_order, context,
                () {
                viewOrder();
              })
            : SizedBox(),
        selectedTable != null && selectedTable.numberofpax != null
            ? neworder_button(
                Icons.change_history, Strings.change_table, context, () {
                changeTablePop();
              })
            : SizedBox(),
        selectedTable != null && selectedTable.numberofpax != null
            ? neworder_button(Icons.cancel, Strings.cancle_order, context, () {
                if (permissions.contains(Constant.DELETE_ORDER)) {
                  cancleTableOrder();

                } else {
                  CommonUtils.openPermissionPop(context, Constant.DELETE_ORDER,
                      () {
                    cancleTableOrder();
                  }, () {});
                }
              })
            : SizedBox(),
        selectedTable != null
            ? neworder_button(Icons.call_merge, isMergeing ? Strings.cancelMergeOrder : Strings.merge_order, context,
                () {
                mergeTable(selectedTable);
              })
            : SizedBox(),
        false && selectedTable != null && selectedTable.tableQr != null
            ? neworder_button(Icons.cancel, Strings.scanQRcode, context, () {
                opneQrcodePop();
              })
            : SizedBox(),
      ],
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

  Widget changeTable(context) {
    return GestureDetector(
      onTap: () {
        changeTablePop();
      },
      child: Text(Strings.change_table,
          textAlign: TextAlign.center, style: Styles.bluesmall()),
    );
  }

  Widget neworder_button(icon, name, context, onclick) {
    return new OutlineButton(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: Colors.white),
            SizedBox(width: 20),
            Text(name,
                textAlign: TextAlign.center, style: Styles.whiteSimpleSmall())
          ],
        ),
        borderSide:
            BorderSide(color: Colors.black, width: 1, style: BorderStyle.solid),
        onPressed: onclick,
        shape: new RoundedRectangleBorder(
            side: BorderSide(
                color: Colors.black, width: 1, style: BorderStyle.solid),
            borderRadius: new BorderRadius.circular(0.0)));
  }

  Widget changePaxbtn(context) {
    return GestureDetector(
      onTap: () {
        changePax();
      },
      child: Text(Strings.change_pax,
          textAlign: TextAlign.center, style: Styles.bluesmall()),
    );
  }

  Widget cancleOrder(context) {
    return GestureDetector(
      onTap: () {
        cancleTableOrder();
      },
      child: Text(Strings.cancle_order,
          textAlign: TextAlign.center, style: Styles.bluesmall()),
    );
  }

  Widget viewOrderBtn(context) {
    return GestureDetector(
      onTap: () {
        viewOrder();
      },
      child: Text(Strings.view_order,
          textAlign: TextAlign.center, style: Styles.bluesmall()),
    );
  }

  Widget paxTextInput() {
    return TextField(
      controller: paxController,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly
      ],
      decoration: InputDecoration(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        prefixIcon: Icon(
          Icons.person,
          color: Colors.grey[400],
          size: SizeConfig.safeBlockVertical * 5,
        ),
        hintText: Strings.enter_pax,
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
        contentPadding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
        fillColor: Colors.white,
      ),
      style: TextStyle(
          color: Colors.black, fontSize: SizeConfig.safeBlockVertical * 4),
      onChanged: (e) {},
    );
  }

  Widget enterButton(Function _onPress) {
    return RaisedButton(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
      onPressed: _onPress,
      child: Text(
        isChanging ? Strings.change_pax : Strings.enterPax,
        style: TextStyle(
            color: Colors.white, fontSize: SizeConfig.safeBlockVertical * 4),
      ),
      color: Colors.deepOrange,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  Widget paxalertDailog(context) {
    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        titlePadding: EdgeInsets.all(0),
        title: Stack(
          // popup header
          overflow: Overflow.visible,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
              ),
              padding: EdgeInsets.all(0),
              height: SizeConfig.safeBlockVertical * 9,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(isChanging ? Strings.change_pax : Strings.enterPax,
                      style: TextStyle(
                          fontSize: SizeConfig.safeBlockVertical * 3,
                          color: Colors.white)),
                ],
              ),
            ),
            closeButton(context), //popup close btn
          ],
        ),
        content: Builder(
          builder: (context) {
            KeyboardVisibilityNotification().addNewListener(
              onHide: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
            );
            return Container(
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width / 3,
              child: Center(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      paxTextInput(),
                      SizedBox(
                        height: 30,
                      ),
                      enterButton(() {
                        if (!isMergeing) {
                          if (isAssigning) {
                            assignTabletoOrder();
                          } else {
                            selectTableForNewOrder();
                          }
                        }
                      }),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }

  Widget tablesListwidget(type) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2.4;
    final double itemWidth = size.width / 4.5;
    if (isAssigning) {
      var list = tableList
          .where((x) => x.numberofpax == 0 || x.numberofpax == null)
          .toList();
      setState(() {
        tableList = list;
      });
    }
    if (isMergeing || isChangingTable) {
      var list = tableList.toList();
      //var list = tableList.where((x) => x.tableId != selectedTable.tableId).toList();
      setState(() {
        tableList = list;
      });
      if (tableList.length == 0) {
        CommunFun.showToast(context, Strings.table_not_avalilable);
      }
    }
    List<TablesDetails> newtableList = new List<TablesDetails>();
    if (type == 1) {
      //TakeAway
      var dainIn = tableList.where((x) => x.tableType == 1).toList();
      newtableList = dainIn;
    } else {
      // DineIn
      var takeAway = tableList.where((x) => x.tableType == 2).toList();
      newtableList = takeAway;
    }
    return GridView.count(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: (itemWidth / itemHeight),
      crossAxisCount: isMenuOpne ? 4 : 6,
      children: newtableList.map((table) {
        if (table.merged_table_id != null && !mergeTableList.contains(table.merged_table_id)) {
          setState(() {
            if(!isLoading) mergeTableList.add(table.merged_table_id);
          });
        };
        var selected;
        if (tableColors.length > 0 && table.occupiedMinute != null) {
          selected = tableColors.firstWhere(
              (item) => item.timeMinute >= table.occupiedMinute, orElse: () {
            if (table.occupiedMinute >=
                tableColors[tableColors.length - 1].timeMinute) {
              return tableColors[tableColors.length - 1];
            }
          });
        };
        return InkWell(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          onTap: () {
            if (mergeTableList.contains(table.tableId)) {}
            else if (selectedTable != null && selectedTable.tableId == table.tableId) { }
            else if (isMergeing) {
              if (table.merged_table_id == null) {
                //mergeInTable.
                mergeTabledata(table);
              } else {
                CommunFun.showToast(context, Strings.table_already_merged);
              }
            } else if (isChangingTable) {
              if (table.saveorderid == 0) {
                changeTableToOtherTable(table);
              } else {
                CommunFun.showToast(context, Strings.table_already_occupied);
              }
            } else {
              ontableLongTap(table);
            }
          },
          onDoubleTap: () { ontableTap(table);},
          child: Container(
            width: itemHeight,
            height: itemWidth,
            margin: EdgeInsets.all(5),
            child: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: <Widget>[
                Hero(
                  tag: table.tableId,
                  child: Container(
                    decoration: new BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0))),
                    width: MediaQuery.of(context).size.width,
                    height: itemHeight / 2,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 30),
                          Text(
                            table.merged_table_id != null
                                ? table.tableName +
                                    " : " +
                                    table.merge_table_name.toString()
                                : table.tableName,
                            style: Styles.blackMediumBold(),
                          ),
                          Text(selected != null ? selected.timeMinute.toString()+' M' : "")
                        ]),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: itemHeight / 2),
                  width: MediaQuery.of(context).size.width,
                  //height: itemHeight / 5,
                  decoration: BoxDecoration(
                      color:
                      table.is_merge_table != null ? Colors.blue : 
                      (
                        (isMergeing || isChangingTable)
                        && selectedTable != null
                        && selectedTable.tableId == table.tableId
                      ) 
                      ? tableSelectedColor :
                      (
                        selectedTable != null
                        && selectedTable.tableId == table.tableId
                      )
                      ? Colors.orange : table.numberofpax != null 
                      ? Colors.deepOrange : Colors.grey[600],
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0))),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        mergeTableList.contains(table.tableId) ? Text("-",
                                style: Styles.whiteSimpleSmall(),) :
                        table.numberofpax != null
                            ? Text(
                                Strings.occupied +
                                    table.numberofpax.toString() +
                                    "/" +
                                    table.tableCapacity.toString(),
                                style: Styles.whiteSimpleSmall())
                            : Text(
                                Strings.vacant +
                                    "0" +
                                    "/" +
                                    table.tableCapacity.toString(),
                                style: Styles.whiteSimpleSmall())
                      ],
                    ),
                ),
                Positioned(
                    top: 10,
                    left: 10,
                    child: Text(
                        table.numberofpax != null
                            ? Strings.orders + " 1 "
                            : Strings.orders + " 0 ",
                        style: Styles.blackMediumBold()))
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
