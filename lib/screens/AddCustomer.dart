import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/Citys.dart';
import 'package:mcncashier/models/Countrys.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/States.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/screens/SearchCustomer.dart';
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
  final _formKey = GlobalKey<FormState>();
  List<Countrys> countrys = [];
  List<States> states = [];
  List<Citys> citys = [];
  List<States> filterstates = [];
  List<Citys> filtercitys = [];
  var selectedCountry;
  var selectedCity;
  var selectedState;
  var selectedCountryError = "";
  var selectedStateError = "";
  var selectedCityError = "";
  @override
  void initState() {
    super.initState();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    getaddresFileds();
  }

  getaddresFileds() {
    getCountrysList();
    getStatesList();
    getCitysList();
  }

  getCountrysList() async {
    List<Countrys> country = await localAPI.getCountrysList();
    if (country.length > 0) {
      setState(() {
        countrys = country;
      });
    }
  }

  getStatesList() async {
    List<States> state = await localAPI.getStatesList();
    if (state.length > 0) {
      setState(() {
        states = state;
        filterstates = state;
      });
    }
  }

  getCitysList() async {
    List<Citys> city = await localAPI.getCitysList();
    if (city.length > 0) {
      setState(() {
        citys = city;
        filtercitys = city;
      });
    }
  }

  filterState() async {
    if (selectedCountry != null) {
      var list =
          await states.where((x) => x.countryId == selectedCountry).toList();
      print(list);
      setState(() {
        filterstates = list;
      });
    } else {
      setState(() {
        filterstates = states;
      });
    }
  }

  filterCity() {
    if (selectedState != null) {
      var list = citys.where((x) => x.stateId == selectedState).toList();
      print(list);
      setState(() {
        filtercitys = list;
      });
    } else {
      setState(() {
        filtercitys = citys;
      });
    }
  }

  validateFields() {
    return true;
  }

  __validateForm() {
    bool _isValid = _formKey.currentState.validate();

    if (selectedCountry == null) {
      setState(() => selectedCountryError = "Please select country!");
      _isValid = false;
    }
    if (selectedState == null) {
      setState(() => selectedStateError = "Please select state!");
      _isValid = false;
    }
    if (selectedCity == null) {
      setState(() => selectedCityError = "Please select city!");
      _isValid = false;
    }

    return _isValid;
  }

  addCustomer() async {
    if (__validateForm()) {
      var terminalkey = await CommunFun.getTeminalKey();
      Customer customer = new Customer();
      User userdata = await CommunFun.getuserDetails();
      int appid = await localAPI.getLastCustomerid(terminalkey);
      if (appid != 0) {
        customer.appId = appid + 1;
      } else {
        customer.appId = int.parse(terminalkey);
      }
      customer.terminalId = int.parse(terminalkey);
      customer.name = firstname_controller.text;
      customer.username = lastname_controller.text;
      customer.email = email_controller.text;
      customer.mobile = phone_controller.text;
      customer.password = password_controller.text;
      customer.address = addressLine1_controller.text;
      customer.email = email_controller.text;
      customer.status = 1;
      customer.uuid = await CommunFun.getLocalID();
      customer.cityId = selectedCity != null ? selectedCity : 0;
      customer.stateId = selectedState != null ? selectedState : 0;
      customer.countryId = selectedCountry != null ? selectedCountry : 0;
      customer.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
      customer.createdBy = userdata.id;
      var result = await localAPI.addCustomer(customer);
      Navigator.of(context).pop();
      setState(() {
        selectedCityError = "";
        selectedCountryError = "";
        selectedStateError = "";
      });
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return SearchCustomerPage(
                onClose: () {
                  Navigator.pushNamed(context, Constant.DashboardScreen);
                },
                isFor: Constant.dashboard);
          });
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
            left: 15,
            top: 0,
            child: RaisedButton(
              padding: EdgeInsets.only(left: 8, right: 8, top: 0, bottom: 0),
              onPressed: () {
                addCustomer();
              },
              child: Text(Strings.btn_Add_customer,
                  style: Styles.whiteBoldsmall()),
              color: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
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
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: SizeConfig.safeBlockVertical * 2.5),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5)),
              padding: EdgeInsets.all(5),
              height: SizeConfig.safeBlockVertical * 9,
              width: MediaQuery.of(context).size.width,
              child: new DropdownButton(
                underline: Container(
                  color: Colors.transparent,
                ),
                value: selectedCountry,
                isExpanded: true,
                selectedItemBuilder: (BuildContext context) {
                  return countrys.map((item) {
                    return Text(
                      item.name,
                      style: Theme.of(context).textTheme.subtitle,
                    );
                  }).toList();
                },
                items: countrys.map((value) {
                  return new DropdownMenuItem(
                    value: value.countryId,
                    child: new Text(
                      value.name,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.safeBlockVertical * 3),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCountry = value;
                    selectedCityError = "";
                    selectedCountryError = "";
                    selectedStateError = "";
                  });
                },
              ),
            ),
            selectedCountryError == ""
                ? SizedBox.shrink()
                : Text(selectedCountryError ?? "",
                    style: TextStyle(color: Colors.red[700], fontSize: 12)),
          ]),
    );
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
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: SizeConfig.safeBlockVertical * 2.5),
            ),
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5)),
              height: SizeConfig.safeBlockVertical * 9,
              width: MediaQuery.of(context).size.width,
              child: new DropdownButton(
                underline: Container(
                  color: Colors.transparent,
                ),
                value: selectedCity,
                isExpanded: true,
                selectedItemBuilder: (BuildContext context) {
                  return filtercitys.map((item) {
                    return Text(
                      item.name,
                      style: Theme.of(context).textTheme.subtitle,
                    );
                  }).toList();
                },
                items: filtercitys.map((value) {
                  return new DropdownMenuItem(
                    value: value.cityId,
                    child: new Text(
                      value.name,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.safeBlockVertical * 3),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCity = value;
                    selectedCityError = "";
                    selectedCountryError = "";
                    selectedStateError = "";
                  });
                },
              ),
            ),
            selectedCityError == ""
                ? SizedBox.shrink()
                : Text(selectedCityError ?? "",
                    style: TextStyle(color: Colors.red[700], fontSize: 12)),
          ]),
    );
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
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: SizeConfig.safeBlockVertical * 2.5),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5)),
              padding: EdgeInsets.all(5),
              height: SizeConfig.safeBlockVertical * 9,
              width: MediaQuery.of(context).size.width,
              child: new DropdownButton(
                underline: Container(
                  color: Colors.transparent,
                ),
                value: selectedState,
                isExpanded: true,
                selectedItemBuilder: (BuildContext context) {
                  return filterstates.map((item) {
                    return Text(
                      item.name,
                      style: Theme.of(context).textTheme.subtitle,
                    );
                  }).toList();
                },
                items: filterstates.map((value) {
                  return new DropdownMenuItem(
                    value: value.stateId,
                    child: new Text(
                      value.name,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.safeBlockVertical * 3),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedState = value;
                    selectedCityError = "";
                    selectedCountryError = "";
                    selectedStateError = "";
                  });
                  filterCity();
                },
              ),
            ),
            selectedStateError == ""
                ? SizedBox.shrink()
                : Text(
                    selectedStateError ?? "",
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
          ]),
    );
  }

  Widget inputfield(lable, type, isCompal, isPassword, Function _onchnage) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextFormField(
        //controller: lable,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter ' + lable + '.';
          }
          return null;
        },
        keyboardType: type,
        obscureText: isPassword,
        decoration: InputDecoration(
          //contentPadding: EdgeInsets.only(left: 5, right: 5),
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
      //height: MediaQuery.of(context).size.height / 1.8,
      child: Form(
          key: _formKey,
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
                          Strings.fisrtname, TextInputType.text, true, false,
                          (e) {
                    firstname_controller.text = e;
                  })),
                  TableCell(
                      child: inputfield(
                          Strings.lastname, TextInputType.text, true, false,
                          (e) {
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
                          Strings.phone, TextInputType.number, true, false,
                          (e) {
                    phone_controller.text = e;
                  })),
                ]),
                TableRow(children: [
                  TableCell(
                      child: inputfield(
                          Strings.password, TextInputType.text, true, true,
                          (e) {
                    password_controller.text = e;
                  })),
                  TableCell(
                      child: inputfield(Strings.addressline1,
                          TextInputType.text, false, false, (e) {
                    addressLine1_controller.text = e;
                  })),
                ]),
                TableRow(children: [
                  TableCell(child: countryselect()),
                  TableCell(child: stateSelect()),
                ]),
                TableRow(
                    children: [TableCell(child: cityselect()), SizedBox()]),
              ],
            ),
          )),
    );
  }
}
