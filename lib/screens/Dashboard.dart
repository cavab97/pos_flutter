import 'package:flutter/material.dart';
import 'package:mcncashier/components/communText.dart';

class DashboradPage extends StatefulWidget {
  DashboradPage({Key key}) : super(key: key);
  @override
  _DashboradPageState createState() => _DashboradPageState();
}

class _DashboradPageState extends State<DashboradPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
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
                              initialIndex: 0,
                              length: 5,
                              child: TabBar(
                                indicatorSize: TabBarIndicatorSize.label,
                                unselectedLabelColor: Colors.white,
                                labelColor: Colors.white,
                                indicator: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.deepOrange),
                                labelStyle: TextStyle(fontSize: 16),
                                tabs: [
                                  Tab(
                                    child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Text(
                                          "TEXT",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ),
                                  Tab(
                                    child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Text(
                                          "TEXT",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ),
                                  Tab(
                                    child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Text(
                                          "TEXT",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ),
                                  Tab(
                                    child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Text(
                                          "TEXT",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ),
                                  Tab(
                                    child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Text(
                                          "TEXT",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  )
                                ],
                              ),
                            ),
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
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Color(0xFFDEDFDF)),
                                    ),
                                    margin: EdgeInsets.all(5),
                                    child: Stack(
                                      alignment: AlignmentDirectional.topCenter,
                                      children: <Widget>[
                                        Hero(
                                            tag: 1,
                                            child: Container(
                                              color: Colors.greenAccent,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 200,
                                              child: Image.asset(
                                                "assets/photo-1504674900247-0877df9cc836.jfif",
                                                fit: BoxFit.contain,
                                              ),
                                            )),
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
                                color: Colors.grey[300],
                                child: Table(children: [
                                  TableRow(
                                      decoration:
                                          BoxDecoration(color: Colors.white),
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.only(
                                                left: 10, top: 20, bottom: 20),
                                            child: Text(
                                              "Name",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 20, top: 20, bottom: 20),
                                          child: Text("Qty",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 10, top: 20, bottom: 20),
                                          child: Text("Ammount",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        )
                                      ]),
                                  TableRow(children: [
                                    Text("item 1"),
                                    Text("item 2"),
                                    Text("item 2"),
                                  ]),
                                  TableRow(children: [
                                    Text("item 3"),
                                    Text("item 4"),
                                    Text("item 4"),
                                  ]),
                                ]),
                              ),
                            ],
                          )),
                      Container(
                          height: 80,
                          width: 320,
                          child: CommunFun.roundedButton("PAY", () {}))
                    ],
                  )),
                ]),
              ],
            )));
  }
}
