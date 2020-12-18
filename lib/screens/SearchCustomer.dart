import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/screens/AddCustomer.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:mcncashier/components/colors.dart';

class SearchCustomerPage extends StatefulWidget {
  SearchCustomerPage({Key key, this.onClose, this.isFor}) : super(key: key);
  Function onClose;
  String isFor;

  @override
  _SearchCustomerPageState createState() => _SearchCustomerPageState();
}

class _SearchCustomerPageState extends State<SearchCustomerPage> {
  GlobalKey<ScaffoldState> scaffoldKey;
  LocalAPI localAPI = LocalAPI();
  List<Customer> customerList = new List<Customer>();
  List<Customer> filterList = [];
  bool isFiltring = false;

  @override
  void initState() {
    super.initState();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    getcustomerList();
  }

  getcustomerList() async {
    var terminalkey = await CommunFun.getTeminalKey();
    List<Customer> customers = await localAPI.getCustomers(terminalkey);
    setState(() {
      customerList = customers;
    });
  }

  addCustomer() {
    Navigator.of(context).pop();
    showDialog(
        // Opning Ammount Popup
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AddCustomerPage();
        });
  }

  saveCustomerTolocal(customer) async {
    if (widget.isFor == Constant.dashboard) {
      await Preferences.setStringToSF(
          Constant.CUSTOMER_DATA, json.encode(customer));
    } else if (widget.isFor == Constant.splitbill) {
      await Preferences.setStringToSF(
          Constant.CUSTOMER_DATA_SPLIT, json.encode(customer));
    }
    Navigator.of(context).pop();
    widget.onClose();
  }

  filterCustomer(val) {
    var list = customerList
        .where((x) =>
            x.name.toString().toLowerCase().contains(val.toLowerCase()) ||
            x.email.toString().toLowerCase().contains(val.toLowerCase()))
        .toList();
    setState(() {
      filterList = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      title: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
            height: SizeConfig.safeBlockVertical * 9,
            color: StaticColor.colorBlack,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(Strings.searchCustomer, style: Styles.whiteBoldsmall()),
              ],
            ),
          ),
          Positioned(
            left: 15,
            //  top: 0,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RaisedButton(
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
                    onPressed: () {
                      addCustomer();
                    },
                    child: Text(Strings.addNew, style: Styles.whiteBoldsmall()),
                    color: StaticColor.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  )
                ]), /*GestureDetector(
              onTap: () {
                addCustomer();
              },
              child: Text(
                Strings.add_new.toUpperCase(),
                style: Styles.whiteSimpleSmall(),
              ),
            ),*/
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
                color: StaticColor.colorRed,
                borderRadius: BorderRadius.circular(30.0)),
            child: Icon(
              Icons.clear,
              color: StaticColor.colorWhite,
              size: 30,
            ),
          ),
        ));
  }

  Widget mainContent() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          isFiltring = false;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.8,
        height: MediaQuery.of(context).size.height / 1.8,
        child: SingleChildScrollView(
          child: Container(
            child: Column(children: <Widget>[
              customerSearchBox(),
              SizedBox(
                height: 10,
              ),
              customerLists()
            ]),
          ),
        ),
      ),
    );
  }

  Widget customerSearchBox() {
    return Container(
      height: SizeConfig.safeBlockVertical * 10,
      padding: EdgeInsets.all(SizeConfig.safeBlockVertical * 1),
      color: StaticColor.colorGrey400,
      child: TextField(
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 15),
            child: Icon(
              Icons.search,
              color: StaticColor.colorGrey400,
              size: SizeConfig.safeBlockVertical * 5,
            ),
          ),
          hintText: Strings.customerSearchHint,
          hintStyle: TextStyle(
              fontSize: SizeConfig.safeBlockVertical * 2.5,
              fontWeight: FontWeight.bold,
              color: StaticColor.colorGrey400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
          filled: true,
          contentPadding: EdgeInsets.only(left: 20, top: 20, bottom: 20),
          fillColor: StaticColor.colorWhite,
        ),
        style: TextStyle(color: StaticColor.colorBlack, fontSize: 18.0),
        onTap: () {
          setState(() {
            isFiltring = true;
          });
        },
        onSubmitted: (e) {},
        onChanged: (e) {
          filterCustomer(e);
        },
      ),
    );
  }

  Widget customerLists() {
    if (isFiltring) {
      return ListView(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          children: filterList.map((customer) {
            return ListTile(
              onTap: () {
                saveCustomerTolocal(customer);
              },
              leading: Text(
                customer.name == null ? customer.firstName : customer.name,
                style: Styles.communBlacksmall(),
              ),
              title: Text(customer.email, style: Styles.communBlacksmall()),
            );
          }).toList());
    } else {
      return ListView(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        children: customerList.map((customer) {
          return ListTile(
            onTap: () {
              saveCustomerTolocal(customer);
            },
            leading: Text(
              customer.name == null ? customer.firstName : customer.name,
              style: Styles.communBlacksmall(),
            ),
            title: Text(customer.email, style: Styles.communBlacksmall()),
          );
        }).toList(),
      );
    }
  }
}
