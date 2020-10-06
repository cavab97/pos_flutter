import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/theme/Sized_Config.dart';

class AddCustomerPage extends StatefulWidget {
  AddCustomerPage({Key key}) : super(key: key);

  @override
  _AddCustomerPageState createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  GlobalKey<ScaffoldState> scaffoldKey;
  TextEditingController firstname_controller = new TextEditingController();
  TextEditingController lastname_controller = new TextEditingController();
  TextEditingController email_controller = new TextEditingController();
  TextEditingController phone_controller = new TextEditingController();
  TextEditingController password_controller = new TextEditingController();
  TextEditingController dateofBirth_controller = new TextEditingController();
  TextEditingController addressLine1_controller = new TextEditingController();
  TextEditingController postcode_controller = new TextEditingController();
  LocalAPI localAPI = LocalAPI();
  String _selectedCountry = "India";
  List<String> countries = ['A', 'B', 'C', 'D'];

  @override
  void initState() {
    super.initState();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  validateFields() {
    return true;
  }

  addCustomer() async {
    var isvalid = validateFields();
    if (isvalid) {
      var terminalkey = await CommunFun.getTeminalKey();
      Customer customer = new Customer();
      customer.terminalId = int.parse(terminalkey);
      customer.firstName = firstname_controller.text;
      customer.lastName = lastname_controller.text;
      customer.email = email_controller.text;
      customer.mobile = phone_controller.text;
      customer.password = password_controller.text;
      customer.address = addressLine1_controller.text;
      customer.email = email_controller.text;
      customer.cityId = 0;
      customer.stateId = 0;
      customer.countryId = 0;
      var result = await localAPI.addCustomer(customer);
      print(result);
      Navigator.of(context).pop();
    }
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
            color: Colors.black,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(Strings.btn_Add_customer,
                    style: TextStyle(
                        fontSize: SizeConfig.safeBlockVertical * 3,
                        color: Colors.white)),
              ],
            ),
          ),
          Positioned(
            left: 40,
            top: 20,
            child: GestureDetector(
              onTap: () {
                addCustomer();
              },
              child: Text(
                Strings.add.toUpperCase(),
                style: Styles.whiteBoldsmall(),
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

  Widget countryselect() {
    return new Padding(
        padding: EdgeInsets.all(10),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                Strings.countrys,
                style: TextStyle(color: Colors.grey, fontSize: SizeConfig.safeBlockVertical * 2.5),
              ),
              Container(
                  height: SizeConfig.safeBlockVertical * 9,
                  width: MediaQuery.of(context).size.width,
                  child: new DropdownButton<String>(
                    isExpanded: true,
                    items: <String>['India', 'Canada', 'UK', 'USA']
                        .map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(
                          value,
                          style: TextStyle(color: Colors.black,fontSize: SizeConfig.safeBlockVertical * 3),
                        ),
                      );
                    }).toList(),
                    onChanged: (_) {},
                  ))
            ]));
  }

  Widget cityselect() {
    return new Padding(
        padding: EdgeInsets.all(10),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                Strings.city,
                style: TextStyle(color: Colors.grey, fontSize: SizeConfig.safeBlockVertical * 2.5),
              ),
              Container(
                  height: SizeConfig.safeBlockVertical * 9,
                  width: MediaQuery.of(context).size.width,
                  child: new DropdownButton<String>(
                    isExpanded: true,
                    items: <String>['India', 'Canada', 'UK', 'USA']
                        .map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(
                          value,
                          style: TextStyle(color: Colors.black,fontSize: SizeConfig.safeBlockVertical * 3),
                        ),
                      );
                    }).toList(),
                    onChanged: (_) {},
                  ))
            ]));
  }

  Widget stateSelect() {
    return new Padding(
        padding: EdgeInsets.all(10),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                Strings.state,
                style: TextStyle(color: Colors.grey, fontSize: SizeConfig.safeBlockVertical * 2.5),
              ),
              Container(
                  height: SizeConfig.safeBlockVertical * 9,
                  width: MediaQuery.of(context).size.width,
                  child: new DropdownButton<String>(
                    isExpanded: true,
                    items: <String>['Gujarat', 'Mumbai', 'Rajastan', 'Maharast']
                        .map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(
                          value,
                          style: TextStyle(color: Colors.black,fontSize: SizeConfig.safeBlockVertical * 3),
                        ),
                      );
                    }).toList(),
                    onChanged: (_) {},
                  ))
            ]));
  }

  Widget inputfield(lable, type, isCompal, isPassword, Function _onchnage) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextField(
        //controller: lable,
        keyboardType: type,
        obscureText: isPassword,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(left: 10,right: 10),
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey),
          ),
          labelText: isCompal ? lable + "*" : lable,
          labelStyle: TextStyle(
            fontSize: SizeConfig.safeBlockVertical * 2.5,
            color: Colors.grey,
          ),
        ),
        style: TextStyle(
            color: Colors.black, fontSize: SizeConfig.safeBlockVertical * 3),
        onChanged: _onchnage,
      ),
    );
  }

  Widget mainContent() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.8,
      height: MediaQuery.of(context).size.height / 1.8,
      child: SingleChildScrollView(
        child: Table(
          columnWidths: {
            0: FractionColumnWidth(.5),
            1: FractionColumnWidth(.5),
          },
          children: [
            TableRow(children: [
              TableCell(
                  child: inputfield(
                      Strings.fisrtname, TextInputType.text, true, false, (e) {
                firstname_controller.text = e;
              })),
              TableCell(
                  child: inputfield(
                      Strings.lastname, TextInputType.text, true, false, (e) {
                lastname_controller.text = e;
              })),
            ]),
            TableRow(children: [
              TableCell(
                  child: inputfield(
                      Strings.email, TextInputType.text, true, false, (e) {
                email_controller.text = e;
              })),
              TableCell(
                  child: inputfield(
                      Strings.phone, TextInputType.number, true, false, (e) {
                phone_controller.text = e;
              })),
            ]),
            TableRow(children: [
              TableCell(
                  child: inputfield(
                      Strings.password, TextInputType.text, true, true, (e) {
                password_controller.text = e;
              })),
              TableCell(
                  child: inputfield(
                      Strings.addressline1, TextInputType.text, false, false,
                      (e) {
                addressLine1_controller.text = e;
              })),
            ]),
            TableRow(children: [
              TableCell(child: cityselect()),
              TableCell(child: stateSelect()),
            ]),
            TableRow(children: [
              TableCell(child: countryselect()),
              TableCell(
                  child: inputfield(
                      Strings.postcode, TextInputType.number, false, false,
                      (e) {
                postcode_controller.text = e;
              })),
            ]),
          ],
        ),
      ),
    );
  }
}
