import 'package:flutter/material.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';

class DashboradPage extends StatefulWidget {
  DashboradPage({Key key}) : super(key: key);
  @override
  _DashboradPageState createState() => _DashboradPageState();
}

class _DashboradPageState extends State<DashboradPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  @override
  void initState() {
    super.initState();
    databaseHelper.initializeDatabase();
    //  getData();
  }

  getData() async {
    var data = await databaseHelper.getlocalData();
    print(data);
  }

  @override
  Widget build(BuildContext context) {
    final cartTable = Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder(
            horizontalInside: BorderSide(
                width: 1, color: Colors.grey, style: BorderStyle.solid)),
        children: [
          TableRow(decoration: BoxDecoration(color: Colors.white), children: [
            Padding(
                padding: EdgeInsets.only(left: 10, top: 20, bottom: 20),
                child: Text(
                  "Name",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
            Padding(
              padding: EdgeInsets.only(left: 20, top: 20, bottom: 20),
              child: Text("Qty", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 20, bottom: 20),
              child: Text("Ammount",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ]),
          TableRow(children: [
            Padding(
                padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                child: Text("item 1")),
            Padding(
                padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                child: Text("5.00")),
            Padding(
                padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                child: Text("35.00")),
          ]),
          TableRow(children: [
            Padding(
                padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                child: Text("item 1")),
            Padding(
                padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                child: Text("5.00")),
            Padding(
                padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                child: Text("35.00")),
          ]),
        ]);
    final totalPriceTable = Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder(
            horizontalInside: BorderSide(
                width: 1, color: Colors.grey, style: BorderStyle.solid)),
        children: [
          TableRow(children: [
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Text("SUB TOTAL"),
            ),
            Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text("00:00")),
          ]),
          TableRow(children: [
            Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text("Discount")),
            Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text("00:00")),
          ]),
          TableRow(children: [
            Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text("TAX")),
            Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text("00:00")),
          ]),
          TableRow(children: [
            Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text("GRAND TOTAL")),
            Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text("150.00")),
          ]),
        ]);
    final _tabs = TabBar(
      indicatorSize: TabBarIndicatorSize.label,
      unselectedLabelColor: Colors.white,
      labelColor: Colors.white,
      indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: Colors.deepOrange),
      labelStyle: TextStyle(fontSize: 16),
      tabs: [
        Tab(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                "CRAB BEE",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              )),
        ),
        Tab(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                "COFFI",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              )),
        ),
        Tab(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                "TEA",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              )),
        ),
        Tab(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                "LAMKDS",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              )),
        ),
        Tab(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                "TEXT",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              )),
        )
      ],
    );
    return Scaffold(
        body: Container(
            margin: EdgeInsets.only(top: 30),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Table(
              border: TableBorder.all(color: Colors.white, width: 1),
              columnWidths: {
                0: FractionColumnWidth(.6),
                1: FractionColumnWidth(.3),
              },
              children: [
                TableRow(children: [
                  TableCell(
                      child: Container(
                          height: 80,
                          padding: EdgeInsets.only(left: 10, right: 10),
                          width: MediaQuery.of(context).size.width / 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.dehaze,
                                    color: Colors.white,
                                    size: 40,
                                  ),
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
                                width: MediaQuery.of(context).size.width / 3,
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
                                    hintText: "Search product here...",
                                    hintStyle: TextStyle(
                                        fontSize: 18.0, color: Colors.black),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(50),
                                      borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      ),
                                    ),
                                    filled: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 20, top: 20, bottom: 20),
                                    fillColor: Colors.white,
                                  ),
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 25.0),
                                  onChanged: (e) {
                                    print(e);
                                  },
                                ),
                              )
                            ],
                          ))),
                  TableCell(
                    child: Container(
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
                              padding: EdgeInsets.only(
                                  left: 10, right: 10, top: 5, bottom: 5),
                              onPressed: () {},
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  SizedBox(width: 5),
                                  Text("Add Customer",
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
                        )),
                  ),
                ]),
                TableRow(children: [
                  TableCell(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      // height: MediaQuery.of(context).size.height,
                      // color: Colors.green,
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 65,
                            color: Colors.black38,
                            padding: EdgeInsets.all(10),
                            child: DefaultTabController(
                                initialIndex: 0, length: 5, child: _tabs),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: GridView.count(
                              crossAxisCount: 4,
                              children: List.generate(50, (index) {
                                return InkWell(
                                  onTap: () {},
                                  child: Container(
                                    // decoration: BoxDecoration(
                                    //   border: Border.all(
                                    //       width: 1, color: Color(0xFFDEDFDF)),
                                    // ),
                                    margin: EdgeInsets.all(5),
                                    child: Stack(
                                      alignment: AlignmentDirectional.topCenter,
                                      children: <Widget>[
                                        Hero(
                                            tag: index,
                                            child: Container(
                                                decoration: new BoxDecoration(
                                                  color: Colors.greenAccent,
                                                  image: new DecorationImage(
                                                    image: new ExactAssetImage(
                                                        'assets/photo-1504674900247-0877df9cc836.jfif'),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: 250,
                                                child: Center())),
                                        Container(
                                          margin: EdgeInsets.only(top: 150),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          // height: 90,
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                "UMZX TJD FJDFK FJD",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                            top: 130,
                                            left: 0,
                                            child: Container(
                                                color: Colors.deepOrange,
                                                child: Text(
                                                  "Rs500",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15),
                                                )))
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  TableCell(
                      child: Column(
                    children: <Widget>[
                      Container(
                          height: MediaQuery.of(context).size.height / 1.3,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(12),
                          child: Column(
                            children: <Widget>[
                              Container(
                                  height:
                                      MediaQuery.of(context).size.height / 1.4,
                                  color: Colors.grey[300],
                                  padding: EdgeInsets.all(10),
                                  child: Stack(
                                    children: <Widget>[
                                      cartTable,
                                      Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child:
                                              Container(child: totalPriceTable))
                                    ],
                                  )),
                            ],
                          )),
                      Container(
                          height: 70,
                          width: 320,
                          child: CommunFun.roundedButton("PAY", () {}))
                    ],
                  )),
                ]),
              ],
            )));
  }
}
