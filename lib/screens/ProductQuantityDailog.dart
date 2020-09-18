import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/models/Attribute_data.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/ModifireData.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/mst_sub_cart_details.dart';
import 'package:mcncashier/models/saveOrder.dart';
import 'package:mcncashier/services/LocalAPIs.dart';

class ProductQuantityDailog extends StatefulWidget {
  // quantity Dailog
  ProductQuantityDailog({Key key, this.product, this.cartID, this.iscartItem})
      : super(key: key);
  final product;
  final int cartID;
  final iscartItem;
  @override
  _ProductQuantityDailogState createState() => _ProductQuantityDailogState();
}

class _ProductQuantityDailogState extends State<ProductQuantityDailog> {
  TextEditingController productController = new TextEditingController();
  LocalAPI localAPI = LocalAPI();
  List<Attribute_Data> attributeList = [];
  ProductDetails productItem;
  MSTCartdetails cartitem;
  List<ModifireData> modifireList = [];
  List selectedAttr = [];
  MST_Cart currentCart = new MST_Cart();
  List<ModifireData> selectedModifier = [];
  double product_qty = 1;
  double price = 0.0;
  bool isEditing = false;

  TextStyle attrStyle = TextStyle(color: Colors.black, fontSize: 20.0);
  @override
  void initState() {
    super.initState();
    setState(() {
      isEditing = widget.iscartItem != null;
      productItem = widget.product;
      price = productItem.price;
      cartitem = widget.iscartItem;
    });
    getAttributes();
    if (widget.cartID != null) {
      getCartData();
    }
  }

  setEditingData() async {
    List<MSTSubCartdetails> details =
        await localAPI.getItemModifire(cartitem.id);

    if (details.length > 0) {
      for (var i = 0; i < details.length; i++) {
        var item = details[i];
        if (item.caId != null) {
          //Attr
          if (attributeList.length > 0) {
            for (var i = 0; i < attributeList.length; i++) {
              var attribute = attributeList[i];
              var attributType = attribute.attr_types.split(',');
              var attrIDs = attribute.attributeId.split(',').asMap();
              var attrtypesPrice =
                  attribute.attr_types_price.split(',').asMap();
              for (var a = 0; a < attributType.length; a++) {
                onSelectAttr(attribute.ca_id, attributType[a], attrIDs[a],
                    attrtypesPrice[a]);
              }
            }
          }
        } else {
          // Modi
          if (modifireList.length > 0) {
            for (var j = 0; j < modifireList.length; j++) {
              if (modifireList[j].modifierId == item.modifierId) {
                setModifire(modifireList[i]);
              }
            }
          }
        }
      }
    }
    product_qty = cartitem.productQty is int
        ? cartitem.productQty.toDouble()
        : cartitem.productQty;
    price = cartitem.productPrice;
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
    if (isEditing) {
      setEditingData();
    }
  }

  getCartData() async {
    List<MST_Cart> cartval = await localAPI.getCurrentCart(widget.cartID);
    if (cartval.length != 0) {
      setState(() {
        currentCart = cartval[0];
      });
    }
  }

  increaseQty() {
    if (productItem.hasInventory == 0) {
      var prevproductqty = product_qty;
      setState(() {
        product_qty = prevproductqty + 1;
      });
    } else {
      if (product_qty <= productItem.qty) {
        var prevproductqty = product_qty;
        setState(() {
          product_qty = prevproductqty + 1;
        });
      } else {
        CommunFun.showToast(context, "selected qty is not available in store");
      }
    }
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
    var newPrice = productPrice;
    if (selectedAttr.length > 0) {
      for (int i = 0; i < selectedAttr.length; i++) {
        var price = selectedAttr[i]["attr_price"];
        newPrice += int.parse(price);
      }
    }
    if (selectedModifier.length > 0) {
      for (int i = 0; i < selectedModifier.length; i++) {
        var mprice = selectedModifier[i].price;
        newPrice += mprice;
      }
    }

    var pricewithQty = newPrice * product_qty;
    setState(() {
      price = pricewithQty;
    });
  }

  setModifire(mod) {
    var isSelected = selectedModifier.any((item) => item.pmId == mod.pmId);

    if (isSelected) {
      selectedModifier.removeWhere((item) => item.pmId == mod);
      setState(() {
        selectedModifier = selectedModifier;
      });
    } else {
      selectedModifier.add(mod);
      setState(() {
        selectedModifier = selectedModifier;
      });
    }
    setPrice();
  }

  updateCartItem() {
    produtAddTocart();
  }

  produtAddTocart() async {
    MST_Cart cart = new MST_Cart();
    SaveOrder orderData = new SaveOrder();
    MSTSubCartdetails subCartData = new MSTSubCartdetails();
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    var table = await Preferences.getStringValuesSF(Constant.TABLE_DATA);
    var loginUser = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
    var customerData =
        await Preferences.getStringValuesSF(Constant.CUSTOMER_DATA);
    var loginData = await json.decode(loginUser);
    //cart data
    cart.user_id = customerData != null ? customerData["customer_id"] : 0;
    cart.branch_id = int.parse(branchid);
    cart.sub_total =
        currentCart.sub_total != null ? currentCart.sub_total + price : price;
    cart.discount = currentCart.discount != null ? currentCart.discount + 0 : 0;
    cart.discount_type = 0;
    cart.total_qty = currentCart.total_qty != null
        ? currentCart.total_qty + product_qty.toDouble()
        : product_qty.toDouble();
    cart.tax = 0;
    cart.grand_total = currentCart.grand_total != null
        ? currentCart.grand_total + price
        : price;
    cart.customer_terminal =
        customerData != null ? customerData["terminal_id"] : 0;
    if (!isEditing) {
      cart.created_at = await CommunFun.getCurrentDateTime(DateTime.now());
    }
    cart.created_by = loginData["id"];
    cart.localID = await CommunFun.getLocalID();
    var tableData = await json.decode(table); // table data
    orderData.orderName = tableData != null ? "" : "test";
    if (!isEditing) {
      orderData.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
    }
    orderData.numberofPax = tableData != null ? tableData["number_of_pax"] : 0;
    orderData.isTableOrder = tableData != null ? 1 : 0;
    var productdata = productItem; // PRoduct Data
    productdata.qty = product_qty.toDouble();
    productdata.price = price;
    // MST Sub Cart details

    ///insert
    var cartid = await localAPI.insertItemTocart(currentCart.id, cart,
        productdata, orderData, tableData["table_id"], subCartData);

    MSTCartdetails cartdetails = new MSTCartdetails();
    if (isEditing) {
      cartdetails.id = cartitem.id;
    }
    cartdetails.cartId = cartid;
    cartdetails.productId = productdata.productId;
    cartdetails.productName = productdata.name;
    cartdetails.productPrice = productdata.price;
    cartdetails.productQty = productdata.qty;
    cartdetails.discount = 0;
    cartdetails.taxValue = 0;
    cartdetails.createdAt = DateTime.now().toString();

    var detailID = await localAPI.addintoCartDetails(cartdetails);

    if (selectedModifier.length > 0) {
      for (var i = 0; i < selectedModifier.length; i++) {
        var modifire = selectedModifier[i];
        subCartData.cartdetailsId = detailID;
        subCartData.localID = cart.localID;
        subCartData.productId = productdata.productId;
        subCartData.modifierId = modifire.modifierId;
        subCartData.modifirePrice = modifire.price;
        var res = await localAPI.addsubCartData(subCartData);
        print(res);
      }
    }
    if (selectedAttr.length > 0) {
      for (var i = 0; i < selectedAttr.length; i++) {
        var attr = selectedAttr[i];
        subCartData.cartdetailsId = detailID;
        subCartData.localID = cart.localID;
        subCartData.productId = productdata.productId;
        subCartData.caId = attr["ca_id"];
        subCartData.attributeId = int.parse(attr["attrType_ID"]);
        subCartData.attrPrice = int.parse(attr["attr_price"]).toDouble();
        var res = await localAPI.addsubCartData(subCartData);
        print(res);
      }
    }

    await Navigator.pushNamed(context, Constant.DashboardScreen);
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
                child: Text(price.toString(),
                    style: TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 25,
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
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width / 2.8,
          //height: MediaQuery.of(context).size.height /2.5,
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
        ),
      ),
    );
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
                                      height: 25,
                                      minWidth: 50,
                                      child: Text(attr.toString(),
                                          style: attrStyle),
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
                            color: selectedModifier.any((item) =>
                                    item.pmId == modifier.pmId ||
                                    modifier.isDefault == 1)
                                ? Colors.green
                                : Colors.grey[300],
                            width: 4)),
                    height: 20,
                    minWidth: 50,
                    child: Row(
                      children: <Widget>[
                        Text(
                          modifier.name.toString(),
                          style: attrStyle,
                        ),
                        SizedBox(width: 10),
                        Text(
                          modifier.price.toDouble().toString(),
                          style:
                              TextStyle(color: Colors.deepOrange, fontSize: 15),
                        ),
                      ],
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
      Strings.notesAndQty,
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
      height: 40,
      width: 70,
      decoration:
          BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
      child: Center(
        child: Text(product_qty.toString(),
            style: TextStyle(color: Colors.grey, fontSize: 20)),
      ),
    );
  }

  Widget _button(String number, Function() f) {
    // Creating a method of return type Widget with number and function f as a parameter
    return Padding(
      padding: EdgeInsets.all(5),
      child: MaterialButton(
        height: 40,
        child: Text(number,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30.0)),
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
        if (isEditing) {
          updateCartItem();
        } else {
          produtAddTocart();
        }
      },
      child: Row(
        children: <Widget>[
          !isEditing
              ? Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: 30,
                )
              : Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 27,
                ),
          SizedBox(width: 10),
          Text(isEditing ? "Update" : "Add",
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
