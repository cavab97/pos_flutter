import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';

class TransactionsPage extends StatefulWidget {
  // Transactions list
  TransactionsPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: transactionsDrawer(), // page Drawer
        body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Table(
              columnWidths: {
                0: FractionColumnWidth(.3),
                1: FractionColumnWidth(.6),
              },
              children: [
                TableRow(children: [
                  TableCell(
                      // Part 1 white
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          color: Colors.white,
                          child: ListView(
                            padding: EdgeInsets.all(20),
                            children: <Widget>[
                              Text("Transaction",
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800])),
                              transationsSearchBox(),
                              SizedBox(
                                height: 15,
                              ),
                              Text("Wednesday, August 19",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey[900])),
                              searchTransationList()
                            ],
                          ))),
                  TableCell(
                    // Part 2 transactions list
                    child: Center(
                      child: SingleChildScrollView(
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2,
                          margin: EdgeInsets.only(top: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Wen,August 19 09:53 PM",
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Text(
                                "13.00",
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).accentColor),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Text(
                                "00000000 - Processed by OKDEE OKEY PROCESSED FORM",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width / 2,
                                child: Center(
                                  child: Text(
                                    "Aaron Young",
                                    style: TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).accentColor),
                                  ),
                                ),
                                color: Colors.grey[900].withOpacity(0.4),
                              ),
                              productList(),
                              SizedBox(
                                height: 30,
                              ),
                              totalAmountValues(),
                              SizedBox(
                                height: 30,
                              ),
                              cancelButton(() {
                                Navigator.of(context).pop();
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ));
  }

  transactionsDrawer() {
    return Drawer(
      child: Container(color: Colors.white),
    );
  }

  Widget transationsSearchBox() {
    return Container(
      height: 70,
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(10),
      color: Colors.grey[400],
      child: TextField(
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 15),
            child: Icon(
              Icons.search,
              color: Colors.grey[400],
              size: 40,
            ),
          ),
          hintText: "Invoice Number or S/N",
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
      ),
    );
  }

  Widget totalAmountValues() {
    return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder(
            horizontalInside: BorderSide(
                width: 1, color: Colors.grey, style: BorderStyle.solid)),
        children: [
          TableRow(children: [
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                Strings.sub_total.toUpperCase(),
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text("00:00",
                    style: TextStyle(
                        fontSize: 20, color: Theme.of(context).accentColor))),
          ]),
          TableRow(children: [
            Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text("TAX",
                    style: TextStyle(fontSize: 20, color: Colors.grey))),
            Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text("00:00",
                    style: TextStyle(
                        fontSize: 20, color: Theme.of(context).accentColor))),
          ]),
          TableRow(children: [
            Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text("GRAND TOTAL",
                    style: TextStyle(fontSize: 20, color: Colors.grey))),
            Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text("00:00",
                    style: TextStyle(
                        fontSize: 20, color: Theme.of(context).accentColor))),
          ])
        ]);
  }

  Widget cancelButton(Function _onPress) {
    return RaisedButton(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
      onPressed: _onPress,
      child: Text(
        Strings.cancel_tansaction,
        style: TextStyle(color: Colors.white, fontSize: 25),
      ),
      color: Colors.deepOrange,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  Widget productList() {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      child: Column(children: <Widget>[
        InkWell(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Hero(
                    tag: 1,
                    child: Container(
                      height: 100,
                      width: 130,
                      decoration: new BoxDecoration(
                        color: Colors.greenAccent,
                        image: new DecorationImage(
                          image: new ExactAssetImage(
                              'assets/photo-1504674900247-0877df9cc836.jfif'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Flexible(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("YMZX BBQ SPICY",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Theme.of(context).primaryColor)),
                              // SizedBox(height: 3),
                              // Text(
                              //   widget.favorite.product.store.name,
                              //   overflow: TextOverflow.fade,
                              //   softWrap: false,
                              //   style: Theme.of(context).textTheme.caption,
                              // ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text("7.00",
                            style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).primaryColor)),
                        SizedBox(width: 80),
                        Text("7.00",
                            style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).accentColor)),
                      ],
                    ),
                  )
                ],
              ),
            )),
        CommunFun.divider(),
        InkWell(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Hero(
                    tag: 2,
                    child: Container(
                      height: 100,
                      width: 130,
                      decoration: new BoxDecoration(
                        color: Colors.greenAccent,
                        image: new DecorationImage(
                          image: new ExactAssetImage(
                              'assets/photo-1504674900247-0877df9cc836.jfif'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Flexible(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("YMZX BBQ SPICY",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Theme.of(context).primaryColor)),
                              // SizedBox(height: 3),
                              // Text(
                              //   widget.favorite.product.store.name,
                              //   overflow: TextOverflow.fade,
                              //   softWrap: false,
                              //   style: Theme.of(context).textTheme.caption,
                              // ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text("7.00",
                            style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).primaryColor)),
                        SizedBox(width: 80),
                        Text("7.00",
                            style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).accentColor)),
                      ],
                    ),
                  )
                ],
              ),
            )),
      ]),
    );
  }

  Widget searchTransationList() {
    return ListView(shrinkWrap: true, children: <Widget>[
      ListTile(
        title: Text('09:34 PM',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600])),
        subtitle: Text('INVOICE : 0000000092',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600])),
        isThreeLine: true,
        trailing: Text("35.00",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600])),
      ),
      ListTile(
        title: Text('09:34 PM',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600])),
        subtitle: Text('INVOICE : 0000000092',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600])),
        isThreeLine: true,
        trailing: Text("35.00",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600])),
      ),
      ListTile(
        title: Text('09:34 PM',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600])),
        subtitle: Text('INVOICE : 0000000092',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600])),
        isThreeLine: true,
        trailing: Text("35.00",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600])),
      ),
      ListTile(
        title: Text('09:34 PM',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600])),
        subtitle: Text('INVOICE : 0000000092',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600])),
        isThreeLine: true,
        trailing: Text("35.00",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600])),
      ),
    ]);
  }
}
