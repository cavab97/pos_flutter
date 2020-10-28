import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/models/Table_order.dart';
import 'package:mcncashier/models/saveOrder.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/models/TableDetails.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:mcncashier/theme/Sized_Config.dart';

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
  List<TablesDetails> tableList = new List<TablesDetails>();
  var selectedTable;
  var number_of_pax;
  var orderid;
  var mergeInTable;
  var changeInTable;
  bool isLoading = false;
  bool isMergeing = false;
  bool isChangingTable = false;
  bool isAssigning = false;
  bool isChanging = false;
  TabController _tabController;
  @override
  void initState() {
    super.initState();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    getTables();
    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
    _tabController = new TabController(length: 2, vsync: this);
    checkSelectedTable();
  }

  checkSelectedTable() async {
    var tableid = await Preferences.getStringValuesSF(Constant.TABLE_DATA);
    if (tableid != null) {}
  }

  getTables() async {
    setState(() {
      isLoading = true;
    });
    var branchid = await CommunFun.getbranchId();
    List<TablesDetails> tables = await localAPI.getTables(branchid);
    setState(() {
      tableList = tables;
      isLoading = false;
    });
  }

  viewOrder() async {
    var tableid = selectedTable.tableId;
    List<Table_order> order = await localAPI.getTableOrders(tableid);
    await Preferences.setStringToSF(Constant.TABLE_DATA, json.encode(order[0]));
    Navigator.of(context).pop();
    Navigator.pushNamed(context, Constant.DashboardScreen);
  }

  ontableTap(table) {
    setState(() {
      selectedTable = table;
    });
    if (isAssigning) {
      opnPaxDailog();
    } else {
      paxController.text =
          table.numberofpax != null ? table.numberofpax.toString() : "";
      openSelectTablePop();
    }
  }

  mergeTabledata(table) async {
    Table_order table_order = new Table_order();
    var pax = mergeInTable.numberofpax != null ? mergeInTable.numberofpax : 0;
    pax += table.numberofpax != null ? table.numberofpax : 0;
    table_order.table_id = mergeInTable.tableId;
    table_order.save_order_id =
        mergeInTable.saveorderid != 0 ? mergeInTable.saveorderid : null;
    table_order.is_merge_table = "1";
    table_order.merged_table_id = table.tableId;
    table_order.number_of_pax = pax;
    var result = await localAPI.insertTableOrder(table_order);
    setState(() {
      isMergeing = false;
      mergeInTable = null;
    });
    CommunFun.showToast(context, "Table merged");
    getTables();
  }

  mergeTable(table) {
    setState(() {
      isMergeing = true;
      mergeInTable = table;
    });
    Navigator.of(context).pop();
    //opnPaxDailog();
  }

  selectTableForNewOrder() async {
    if (int.parse(paxController.text) <= selectedTable.tableCapacity) {
      Table_order table_order = new Table_order();
      table_order.table_id = selectedTable.tableId;
      table_order.number_of_pax = int.parse(paxController.text);
      table_order.save_order_id = selectedTable.saveorderid;
      var result = await localAPI.insertTableOrder(table_order);

      await Preferences.setStringToSF(
          Constant.TABLE_DATA, json.encode(table_order));
      Navigator.of(context).pop();
      Navigator.pushNamed(context, Constant.DashboardScreen);
    } else {
      CommunFun.showToast(context, "Please enter pax minimum table capcity.");
    }
  }

  assignTabletoOrder() async {
    if (int.parse(paxController.text) <= selectedTable.tableCapacity) {
      SaveOrder orderData = new SaveOrder();
      orderData.orderName = selectedTable.tableName;
      orderData.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
      orderData.numberofPax = int.parse(paxController.text);
      orderData.cartId = orderid;

      Table_order tableorder = new Table_order();
      tableorder.table_id = selectedTable.tableId;
      tableorder.number_of_pax = int.parse(paxController.text);
      await localAPI.insertTableOrder(tableorder);
      await localAPI.insertSaveOrders(orderData, selectedTable.tableId);
      await localAPI.updateTableidintocart(orderid, selectedTable.tableId);
      Navigator.of(context).pop();
      Navigator.pushNamed(context, Constant.WebOrderPages);
    } else {
      CommunFun.showToast(context, "Please enter pax minimum table capcity.");
    }
  }

  openSelectTablePop() {
    showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (BuildContext context) {
        return alertDailog(context);
      },
    );
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

  cancleTableOrder() async {
    if (selectedTable.saveorderid != null && selectedTable.saveorderid != 0) {
      List<SaveOrder> cartID =
          await localAPI.gettableCartID(selectedTable.saveorderid);
      if (cartID.length > 0) {
        await localAPI.removeCartItem(cartID[0].cartId, selectedTable.tableId);
      }
    } else {
      await localAPI.deleteTableOrder(selectedTable.tableId);
    }
    await Preferences.removeSinglePref(Constant.TABLE_DATA);
    await getTables();
    Navigator.of(context).pop();
  }

  changeTablePop() {
    Navigator.of(context).pop();
    CommonUtils.showAlertDialog(context, () {
      Navigator.of(context).pop();
    }, () {
      Navigator.of(context).pop();
      setState(() {
        isChangingTable = true;
      });
    }, "Warning", "Are you want sure to change your table?", "Yes", "No", true);
  }

  changeTableToOtherTable(table) async {
    var cartid;
    if (selectedTable.saveorderid != null && selectedTable.saveorderid != 0) {
      List<SaveOrder> cartID =
          await localAPI.gettableCartID(selectedTable.saveorderid);
      if (cartID.length > 0) {
        cartid = cartID[0].cartId;
      }
    }
    var tables = await localAPI.changeTable(
        selectedTable.tableId, table.tableId, cartid);
    print(tables);
    setState(() {
      changeInTable = null;
      isChangingTable = false;
    });
    var tableid = await Preferences.getStringValuesSF(Constant.TABLE_DATA);
    if (tableid != null) {
      var tableddata = json.decode(tableid);
      Table_order tabledata = Table_order.fromJson(tableddata);
      if (tabledata.table_id == selectedTable.tableId) {
        tabledata.table_id = table.tableId;
        await Preferences.setStringToSF(
            Constant.TABLE_DATA, jsonEncode(tabledata));
      }
    }
    await getTables();
  }

  changePax() {
    setState(() {
      isChanging = true;
    });
    opnPaxDailog();
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;

    setState(() {
      isAssigning = arguments['isAssign'];
      orderid = arguments['orderID'];
    });
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(
            Icons.arrow_back,
            size: 30.0,
          ),
          onPressed: () {
            if (isMergeing || isChangingTable) {
              setState(() {
                isMergeing = false;
                mergeInTable = null;
                isChangingTable = false;
                changeInTable = null;
              });
            } else {
              Navigator.pushNamed(context, Constant.DashboardScreen);
            }
          },
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
            isMergeing
                ? Strings.merge_table
                : isChangingTable ? Strings.change_table : Strings.select_table,
            style: Styles.whiteMediumBold()),
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
                  "Dine In",
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
                  "Take Away",
                ),
              ),
            ),
          ],
        ),
      ),
      body: new GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SafeArea(
            child: TabBarView(
              controller: _tabController,
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                Container(
                    padding: EdgeInsets.all(10),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: tablesListwidget(1)),
                Container(
                    padding: EdgeInsets.all(10),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: tablesListwidget(2)),
              ],
            ),
          )),
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

  Widget alertDailog(context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      content: Builder(
        builder: (context) {
          return Container(
              //height: MediaQuery.of(context).size.height / 4,
              width: MediaQuery.of(context).size.width / 4.5,
              child: ListView(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                children: ListTile.divideTiles(
                  context: context,
                  tiles: [
                    selectedTable.numberofpax == null
                        ? ListTile(
                            title: neworder_button(context),
                          )
                        : SizedBox(),
                    selectedTable.numberofpax != null
                        ? ListTile(
                            title: changePaxbtn(context),
                          )
                        : SizedBox(),
                    selectedTable.numberofpax != null
                        ? ListTile(
                            title: viewOrderBtn(context),
                          )
                        : SizedBox(),
                    selectedTable.numberofpax != null
                        ? ListTile(
                            title: changeTable(context),
                          )
                        : SizedBox(),
                    selectedTable.numberofpax != null
                        ? ListTile(
                            title: cancleOrder(context),
                          )
                        : SizedBox(),
                    ListTile(
                      onTap: () {
                        mergeTable(selectedTable);
                      },
                      title: Text(
                        Strings.merge_order,
                        textAlign: TextAlign.center,
                        style: Styles.bluesmall(),
                      ),
                    )
                  ],
                ).toList(),
              ));
        },
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

  Widget neworder_button(context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        setState(() {
          isChanging = false;
        });
        opnPaxDailog();
      },
      child: Text(Strings.new_order,
          textAlign: TextAlign.center, style: Styles.bluesmall()),
    );
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
    final double itemWidth = size.width / 4.2;
    if (isAssigning) {
      var list = tableList
          .where((x) => x.numberofpax == 0 || x.numberofpax == null)
          .toList();
      setState(() {
        tableList = list;
      });
    }
    if (isMergeing || isChangingTable) {
      var list =
          tableList.where((x) => x.tableId != selectedTable.tableId).toList();
      setState(() {
        tableList = list;
      });
      if (tableList.length == 0) {
        CommunFun.showToast(context, "Table not available for merge.");
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
      childAspectRatio: (itemWidth / itemHeight),
      crossAxisCount: 6,
      children: newtableList.map((table) {
        return InkWell(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          onTap: () {
            if (isMergeing) {
              if (table.merged_table_id == null) {
                mergeTabledata(table);
              } else {
                CommunFun.showToast(
                    context, "Table already merged with other table");
              }
            }
            if (isChangingTable) {
              if (table.saveorderid == 0) {
                changeTableToOtherTable(table);
              } else {
                CommunFun.showToast(context, "Table already occupied");
              }
            } else {
              ontableTap(table);
            }
          },
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
                            table.merged_table_id != null
                                ? table.tableName +
                                    " : " +
                                    table.merge_table_name.toString()
                                : table.tableName,
                            style: Styles.blackMediumBold(),
                          ),
                        ]),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: itemHeight / 2),
                  width: MediaQuery.of(context).size.width,
                  //height: itemHeight / 5,
                  decoration: BoxDecoration(
                      color: table.numberofpax != null
                          ? Colors.deepOrange
                          : Colors.grey[600],
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
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
                            ? Strings.orders + " 1"
                            : Strings.orders + "0",
                        style: Styles.blackMediumBold()))
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
