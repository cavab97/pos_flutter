import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/models/Attribute_data.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/ModifireData.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/services/LocalAPIs.dart';

class ProductQuantityDailog extends StatefulWidget {
  // quantity Dailog
  ProductQuantityDailog({Key key, this.product}) : super(key: key);
  final product;
  @override
  _ProductQuantityDailogState createState() => _ProductQuantityDailogState();
}

class _ProductQuantityDailogState extends State<ProductQuantityDailog> {
  TextEditingController productController = new TextEditingController();
  LocalAPI localAPI = LocalAPI();
  List<Attribute_Data> attributeList = [];
  ProductDetails productItem;
  List<ModifireData> modifireList = [];
  List selectedAttr = [];
  ModifireData selectedModifier;
  int product_qty = 1;
  int price = 0;
  @override
  void initState() {
    super.initState();
    setState(() {
      productItem = widget.product;
      price = productItem.price;
    });
    getAttributes();
  }

  getAttributes() async {
    List<Attribute_Data> productAttr =
        await localAPI.getProductDetails(productItem);
    if (productAttr.length > 0) {
      setState(() {
        attributeList = productAttr;
      });
    }
    List<ModifireData> productModifeir =
        await localAPI.getProductModifeir(productItem);
    if (productModifeir.length > 0) {
      setState(() {
        modifireList = productModifeir;
      });
    }
  }

  increaseQty() {
    var prevproductqty = product_qty;
    setState(() {
      product_qty = prevproductqty + 1;
      // price = productItem.price * product_qty;
    });
    setPrice();
  }

  decreaseQty() {
    if (product_qty != 0) {
      var prevproductqty = product_qty;
      setState(() {
        product_qty = prevproductqty - 1;
        // price = productItem.price * product_qty;
      });
      setPrice();
    }
  }

  onSelectAttr(id, attribute, attrTypeIDs, attrPrice) {
    // var array = [];
    var prvSeelected = selectedAttr;
    var isSelected = selectedAttr.any((item) => item['ca_id'] == id);
    if (isSelected) {
      selectedAttr.removeWhere((item) => item['ca_id'] == id);
      prvSeelected.add({
        'ca_id': id,
        'attribute': attribute,
        'attrType_ID': attrTypeIDs,
        'attr_price': attrPrice
      });
      setState(() {
        selectedAttr = prvSeelected;
      });
    } else {
      prvSeelected.add({
        'ca_id': id,
        'attribute': attribute,
        'attrType_ID': attrTypeIDs,
        'attr_price': attrPrice
      });
      setState(() {
        selectedAttr = prvSeelected;
      });
    }
    setPrice();
  }

  setPrice() {
    var productPrice = productItem.price;
    var pricewithQty = productPrice * product_qty;
    var newPrice = pricewithQty;
    if (selectedAttr.length > 0) {
      for (int i = 0; i < selectedAttr.length; i++) {
        var price = selectedAttr[i]["attr_price"];
        newPrice += int.parse(price);
      }
    }
    if (selectedModifier != null) {
      newPrice += selectedModifier.price;
    }
    setState(() {
      price = newPrice;
    });
  }

  setModifire(mod) {
    setState(() {
      selectedModifier = mod;
    });
    setPrice();
  }

  produtAddTocart() async {
    MST_Cart cart = new MST_Cart();
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    var teminalID = await Preferences.getStringValuesSF(Constant.TERMINAL_KEY);
    var loginUser = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
    var loginData = await json.decode(loginUser);
    cart.user_id = loginData["id"];
    cart.branch_id = int.parse(branchid);
    cart.sub_total = price.toDouble();
    cart.discount = 0;
    cart.discount_type = 0;
    cart.total_qty = product_qty;
    cart.tax = 0;
    cart.grand_total = price.toDouble();
    cart.customer_terminal = int.parse(teminalID);
    var result = await localAPI.insertItemTocart(cart);
    print(result);
    Navigator.pushNamed(context, Constant.DashboardScreen);
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(productItem.name,
                    style: TextStyle(fontSize: 25, color: Colors.white)),
                addbutton(context)
              ],
            ),
          ),
          closeButton(context), // close button
        ],
      ),
      content: mainContent(), //main part of the popup
      actions: <Widget>[
        // Button div + - buttons
        Stack(
          children: <Widget>[
            Positioned(
                bottom: 10,
                right: 30,
                child: Text(price.toDouble().toString(),
                    style: TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 30,
                        fontWeight: FontWeight.bold))),
            Container(
              width: MediaQuery.of(context).size.width / 1.4,
              child: Column(children: <Widget>[
                CommunFun.divider(),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      buttonContainer(),
                    ]),
              ]),
            ),
          ],
        )
      ],
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

  Widget buttonContainer() {
    return Container(
      child: Row(
        children: <Widget>[
          _button("-", () {
            decreaseQty();
          }),
          _quantityTextInput(),
          _button("+", () {
            increaseQty();
          }),
        ],
      ),
    );
  }

  Widget mainContent() {
    return SingleChildScrollView(
        child: Container(
      //  height: MediaQuery.of(context).size.height / 2.4,
      width: MediaQuery.of(context).size.width / 2.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          getAttributeList(),
          modifireList.length != 0
              ? Text(
                  Strings.modifier,
                  style: TextStyle(fontSize: 20),
                )
              : SizedBox(),
          SizedBox(height: 5),
          modifireList.length != 0 ? modifireItmeList() : SizedBox(),
          SizedBox(height: 15),
          _extraNotesTitle(),
          SizedBox(height: 10),
          inputNotesView(),
        ],
      ),
    ));
  }

  Widget getAttributeList() {
    return Container(
      margin: EdgeInsets.only(bottom: 10, top: 0),
      // MediaQuery.of(context).size.height /8,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: AlwaysScrollableScrollPhysics(),
        children: attributeList.map((attribute) {
          var attributType = attribute.attr_types.split(',');
          var attrIDs = attribute.attributeId.split(',').asMap();
          var attrtypesPrice = attribute.attr_types_price.split(',').asMap();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 10),
              Text(
                attribute.attr_name,
                style: TextStyle(fontSize: 20),
              ),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10.0),
                  height: 60,
                  child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: attributType
                          .asMap()
                          .map((i, attr) {
                            return MapEntry(
                                i,
                                Padding(
                                    padding: EdgeInsets.all(5),
                                    child: MaterialButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          side: BorderSide(
                                            color: selectedAttr.any((item) =>
                                                    item['ca_id'] ==
                                                        attribute.ca_id &&
                                                    item['attribute'] == attr)
                                                ? Colors.green
                                                : Colors.grey[300],
                                            width: 4,
                                          )),
                                      height: 30,
                                      minWidth: 70,
                                      child: Text(
                                        attr.toString(),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 25.0),
                                      ),
                                      textColor: Colors.black,
                                      color: Colors.grey[300],
                                      onPressed: () {
                                        onSelectAttr(attribute.ca_id, attr,
                                            attrIDs[i], attrtypesPrice[i]);
                                      },
                                    )));
                          })
                          .values
                          .toList()))
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget modifireItmeList() {
    return Container(
        height: 60,
        child: ListView(
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            children: modifireList.map((modifier) {
              if (modifier.isDefault == 1) {
                setModifire(modifier);
              }
              return Padding(
                  padding: EdgeInsets.all(5),
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                            color: selectedModifier != null &&
                                        modifier.pmId ==
                                            selectedModifier.pmId ||
                                    modifier.isDefault == 1
                                ? Colors.green
                                : Colors.grey[300],
                            width: 4)),
                    height: 30,
                    minWidth: 70,
                    child: Text(
                      modifier.name.toString(),
                      style: TextStyle(color: Colors.black, fontSize: 25.0),
                    ),
                    textColor: Colors.black,
                    color: Colors.grey[300],
                    onPressed: () {
                      setModifire(modifier);
                    },
                  ));
            }).toList()));
  }

  Widget _sizeTitle() {
    return Text(
      Strings.size,
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w400, color: Colors.grey[800]),
    );
  }

  Widget _extraNotesTitle() {
    return Text(
      "Notes and Quantity",
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w400, color: Colors.grey[800]),
    );
  }

  Widget inputNotesView() {
    return Container(
        padding: EdgeInsets.all(10),
        //height: 170, // MediaQuery.of(context).size.height / 4,
        width: MediaQuery.of(context).size.width,
        child: Card(
          color: Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[notesInput()],
          ),
        ));
  }

  Widget notesInput() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        child: TextField(
          keyboardType: TextInputType.multiline,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(fontSize: 20, height: 1.4),
          maxLines: 3,
          decoration: new InputDecoration(
            border: InputBorder.none,
            // hintText: product_qty.toDouble().toString(),
          ),
          onChanged: (val) {},
        ),
      ),
    );
  }

  Widget _quantityTextInput() {
    return Container(
      height: 50,
      width: 90,
      decoration:
          BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
      child: Center(
        child: Text(product_qty.toDouble().toString(),
            style: TextStyle(color: Colors.grey, fontSize: 25)),
      ),
    );
  }

  Widget _button(String number, Function() f) {
    // Creating a method of return type Widget with number and function f as a parameter
    return Padding(
      padding: EdgeInsets.all(5),
      child: MaterialButton(
        height: 50,
        child: Text(number,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 40.0)),
        textColor: Colors.black,
        color: Colors.deepOrange,
        onPressed: f,
      ),
    );
  }

  Widget addbutton(context) {
    // Add button header rounded
    return RaisedButton(
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      onPressed: () {
        produtAddTocart();
      },
      child: Row(
        children: <Widget>[
          Icon(
            Icons.add_circle_outline,
            color: Colors.white,
            size: 30,
          ),
          SizedBox(width: 10),
          Text("Add",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              )),
        ],
      ),
      color: Colors.deepOrange,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
    );
  }
}
