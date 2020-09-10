import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/models/Table.dart';
import 'package:mcncashier/models/Table_order.dart';
import 'package:mcncashier/services/LocalAPIs.dart';

class SelectTablePage extends StatefulWidget {
  // PIN Enter PAGE
  SelectTablePage({Key key}) : super(key: key);

  @override
  _SelectTablePageState createState() => _SelectTablePageState();
}

class _SelectTablePageState extends State<SelectTablePage> {
  TextEditingController paxController = new TextEditingController();
  GlobalKey<ScaffoldState> scaffoldKey;
  LocalAPI localAPI = LocalAPI();
  List<Tables> tableList = new List<Tables>();
  var selectedTable;
  var number_of_pax;
  @override
  void initState() {
    super.initState();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    getTables();
  }

  getTables() async {
    List<Tables> tables = await localAPI.getTables();
    setState(() {
      tableList = tables;
    });
  }

  selectTableForNewOrder() async {
    Table_order table_order = new Table_order();
    table_order.table_id = selectedTable.tableId;
    table_order.number_of_pax = int.parse(paxController.text);
    var result = await localAPI.insertTableOrder(table_order);
    print(result);
    await Preferences.setStringToSF(
        Constant.TABLE_DATA, json.encode(table_order));
    Navigator.of(context).pop();
    Navigator.pushNamed(context, Constant.DashboardScreen);
  }

  Widget neworder_button(context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        opnPaxDailog();
      },
      child: Text(
        Strings.new_order,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.blueAccent, fontSize: 30),
      ),
    );
  }

  Widget paxTextInput() {
    return TextField(
      controller: paxController,
      keyboardType: TextInputType.number,
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
          size: 40,
        ),
        hintText: "Enter pax",
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
      onChanged: (e) {
        print(e);
      },
    );
  }

  Widget enterButton(Function _onPress) {
    return RaisedButton(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
      onPressed: _onPress,
      child: Text(
        Strings.enterPax,
        style: TextStyle(color: Colors.white, fontSize: 25),
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
        title: Text(Strings.enterPax),
        content: Builder(
          builder: (context) {
            return Container(
              height: 200,
              width: 200,
              child: Center(
                  child: Column(
                children: <Widget>[
                  paxTextInput(),
                  SizedBox(
                    height: 50,
                  ),
                  enterButton(() {
                    selectTableForNewOrder();
                  }),
                ],
              )),
            );
          },
        ));
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

  Widget alertDailog(context) {
    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        content: Builder(
          builder: (context) {
            return Container(
                height: 100,
                width: 150,
                child: Center(
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      neworder_button(context),
                      SizedBox(
                        height: 10,
                      ),
                      CommunFun.divider(),
                      Text(Strings.merge_order,
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 30, color: Colors.blueAccent))
                    ],
                  ),
                ));
          },
        ));
  }

  opnPaxDailog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return paxalertDailog(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            Strings.select_table,
            style:
                TextStyle(fontSize: 30, color: Theme.of(context).primaryColor),
          ),
        ),
        body: Center(
          child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: <Widget>[tablesListwidget()],
              )),
        ));
  }

  Widget tablesListwidget() {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2.4;
    final double itemWidth = size.width / 4.2;
    return GridView.count(
      shrinkWrap: true,
      childAspectRatio: (itemWidth / itemHeight),
      crossAxisCount: 6,
      children: tableList.map((table) {
        return InkWell(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          onTap: () {
            setState(() {
              selectedTable = table;
            });
            openSelectTablePop();
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
                    child: Center(
                      child: Text(
                        table.tableName,
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: itemHeight / 2),
                  width: MediaQuery.of(context).size.width,
                  //height: itemHeight / 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        table.tableType.toString().toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Positioned(
                //   top: itemHeight / 2 - 30,
                //   left: 0,
                //   child: Container(
                //     height: 30,
                //     width: 50,
                //     padding: EdgeInsets.all(5),
                //     color: Colors.deepOrange,
                //     child: Center(
                //       child: Text(
                //         table.tableCapacity.toString(),
                //         style: TextStyle(
                //             fontWeight: FontWeight.w400,
                //             color: Colors.white,
                //             fontSize: 15),
                //       ),
                //     ),
                //   ),
                //)
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
