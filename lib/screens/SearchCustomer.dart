import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/screens/AddCustomer.dart';
import 'package:mcncashier/services/LocalAPIs.dart';

class SearchCustomerPage extends StatefulWidget {
  SearchCustomerPage({Key key}) : super(key: key);

  @override
  _SearchCustomerPageState createState() => _SearchCustomerPageState();
}

class _SearchCustomerPageState extends State<SearchCustomerPage> {
  GlobalKey<ScaffoldState> scaffoldKey;
  LocalAPI localAPI = LocalAPI();
  List<Customer> customerList = new List<Customer>();
  @override
  void initState() {
    super.initState();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    getcustomerList();
  }

  getcustomerList() async {
    List<Customer> customers = await localAPI.getCustomers();
    setState(() {
      customerList = customers;
    });
  }

  addCustomer() {
    Navigator.of(context).pop();
    showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return AddCustomerPage();
        });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      title: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
            height: 70,
            color: Colors.black,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(Strings.search_customer,
                    style: TextStyle(fontSize: 30, color: Colors.white)),
              ],
            ),
          ),
          Positioned(
            right: 30,
            top: 15,
            child: GestureDetector(
              onTap: () {
                addCustomer();
              },
              child: Text(
                Strings.add_new.toUpperCase(),
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),
          ),
          closeButton(context),
        ],
      ),
      content: mainContent(),
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
            child: Icon(
              Icons.clear,
              color: Colors.white,
              size: 30,
            ),
          ),
        ));
  }

  Widget mainContent() {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      height: MediaQuery.of(context).size.height / 1.4,
      child: Container(
        padding: EdgeInsets.all(0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Column(children: <Widget>[
          customerSearchBox(),
          SizedBox(
            height: 15,
          ),
          customerLists()
        ]),
      ),
    );
  }

  Widget customerSearchBox() {
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
          hintText: Strings.customer_Search_Hint,
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

  Widget customerLists() {
    return ListView(
      shrinkWrap: true,
      children: customerList.map((customer) {
        return ListTile(
          onTap: () {
            Navigator.of(context).pop();
          },
          leading:
              Text(customer.name == null ? customer.firstName : customer.name),
          title: Text(customer.email),
        );
      }).toList(),
    );
  }
}
