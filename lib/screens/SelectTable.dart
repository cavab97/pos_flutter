import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/models/Table.dart';
import 'package:mcncashier/services/LocalAPIs.dart';

class SelectTablePage extends StatefulWidget {
  // PIN Enter PAGE
  SelectTablePage({Key key}) : super(key: key);

  @override
  _SelectTablePageState createState() => _SelectTablePageState();
}

class _SelectTablePageState extends State<SelectTablePage> {
  GlobalKey<ScaffoldState> scaffoldKey;
  LocalAPI localAPI = LocalAPI();
  List<Tables> tableList = new List<Tables>();
  var selectedTable;
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

  selectTableForNewOrder() {
    var table = selectedTable;
    var data = {
      'table_id': table.table_id,
      'is_merge_table': "",
      'merged_table_id': '',
      'number_of_pax': '',
      'table_seat': '',
      'save_order_id': '',
      'merged_pax': '',
      'table_locked_by': '',
      'is_order_merged': '',
    };
  }

  Widget neworder_button(context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        selectTableForNewOrder();
      },
      child: Text(
        Strings.new_order,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.blueAccent, fontSize: 30),
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

  openSelectTablePop() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertDailog(context);
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
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 4.2;
    return GridView.count(
      shrinkWrap: true,
      childAspectRatio: (itemWidth / itemHeight),
      crossAxisCount: 6,
      children: tableList.map((table) {
        return InkWell(
          onTap: () {
            setState(() {
              selectedTable = table;
            });
            openSelectTablePop();
          },
          child: Container(
            width: itemHeight,
            height: itemWidth,
            // padding: EdgeInsets.all(5),
            margin: EdgeInsets.all(5),
            child: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: <Widget>[
                Hero(
                    tag: table.tableId,
                    child: Container(
                        decoration: new BoxDecoration(
                          color: Colors.white,
                          // image: new DecorationImage(
                          //   image: ExactAssetImage(table.tableName),
                          //   fit: BoxFit.cover,
                          // ),
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: itemHeight / 2,
                        child: Center(
                            child: Text(table.tableName,
                                style: TextStyle(fontSize: 30))))),
                Container(
                  margin: EdgeInsets.only(top: itemHeight / 2),
                  width: MediaQuery.of(context).size.width,
                  //height: itemHeight / 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                  ),
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
                        table.tableCapacity.toString(),
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
    );
  }
}
