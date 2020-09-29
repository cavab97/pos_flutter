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
import 'package:mcncashier/models/Printer.dart';
import 'package:mcncashier/models/Product_Store_Inventory.dart';
import 'package:mcncashier/models/BranchTax.dart';
import 'package:mcncashier/models/Tax.dart';
import 'package:mcncashier/models/mst_sub_cart_details.dart';
import 'package:mcncashier/models/saveOrder.dart';
import 'package:mcncashier/services/LocalAPIs.dart';

class ProductQuantityDailog extends StatefulWidget {
  // quantity Dailog
  ProductQuantityDailog({Key key, this.product, this.cartID, this.cartItem})
      : super(key: key);
  final product;
  final int cartID;
  final cartItem;

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
  List<MSTCartdetails> cartItems = [];
  List<ModifireData> selectedModifier = [];
  double product_qty = 1.0;
  double price = 0.0;
  Printer printer;
  bool isEditing = false;
  List<BranchTax> taxlist = [];
  double taxvalues = 0;
  TextStyle attrStyle = TextStyle(color: Colors.black, fontSize: 20.0);

  @override
  void initState() {
    super.initState();
    setState(() {
      isEditing = widget.cartItem != null;
      productItem = widget.product;
      price = productItem.price;
      cartitem = widget.cartItem;
    });
    getAttributes();
    getTaxs();
    getPrinter();
    if (widget.cartID != null) {
      getCartData();
      getcartItemsDetails();
    }
  }

  getPrinter() async {
    List<Printer> printerlist =
        await localAPI.getPrinter(productItem.productId.toString());
    if (printerlist.length > 0) {
      setState(() {
        printer = printerlist[0];
      });
    }
  }

  getTaxs() async {
    var branchid = await CommunFun.getbranchId();
    List<BranchTax> taxlists = await localAPI.getTaxList(branchid);
    if (taxlists.length > 0) {
      setState(() {
        taxlist = taxlists;
      });
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
                setModifire(modifireList[j]);
              }
            }
          }
        }
      }
    }

    setState(() {
      product_qty = cartitem.productQty is int
          ? cartitem.productQty.toDouble()
          : cartitem.productQty;
      price = cartitem.productPrice;
    });
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

  getcartItemsDetails() async {
    List<MSTCartdetails> cartItemslist =
        await localAPI.getCurrentCartItems(widget.cartID);
    if (cartItemslist.length != 0) {
      setState(() {
        cartItems = cartItemslist;
      });
    }
  }

  increaseQty() async {
    if (productItem.hasInventory == 1) {
      ProductStoreInventory cartval =
          await localAPI.checkItemAvailableinStore(productItem.productId);
      if (int.parse(cartval.qty) >= product_qty) {
        var prevproductqty = product_qty;
        setState(() {
          product_qty = prevproductqty + 1;
        });
      } else {
        CommunFun.showToast(context, Strings.stock_not_valilable);
      }
    } else {
      if (product_qty <= productItem.qty) {
        var prevproductqty = product_qty;
        setState(() {
          product_qty = prevproductqty + 1;
        });
      } else {
        CommunFun.showToast(context, Strings.store_Validation_message);
      }
    }
    setPrice();
  }

  decreaseQty() {
    if (product_qty > 1) {
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

  countTotalQty() {
    double qty = 0;
    if (cartItems.length > 0) {
      for (var i = 0; i < cartItems.length; i++) {
        var item = cartItems[i];
        if (item.productId == productItem.productId) {
          item.productQty = product_qty;
        }
        qty += item.productQty;
      }
      if (!isEditing) {
        qty += product_qty;
      }
    } else {
      qty += product_qty;
    }
    return qty;
  }

  countSubtotal() {
    double subT = 0;
    if (cartItems.length > 0) {
      for (var i = 0; i < cartItems.length; i++) {
        var item = cartItems[i];
        if (item.productId == productItem.productId) {
          item.productPrice = price;
        }
        subT += item.productPrice;
      }
      if (!isEditing) {
        subT += price;
      }
    } else {
      subT += price;
    }
    return subT;
  }

  countGrandtotal(tax, dis) {
    double grandTotal = 0;
    if (cartItems.length > 0) {
      for (var i = 0; i < cartItems.length; i++) {
        var item = cartItems[i];
        if (item.productId == productItem.productId) {
          item.productPrice = price;
        }
        grandTotal += item.productPrice;
      }
      if (!isEditing) {
        grandTotal += price;
      }
    } else {
      grandTotal += price;
    }
    return grandTotal = ((grandTotal + tax) - dis);
  }

  countTax(subT) async {
    var totalTax = [];
    double taxvalue = taxvalues;
    if (taxlist.length > 0) {
      for (var i = 0; i < taxlist.length; i++) {
        var taxlistitem = taxlist[i];
        List<Tax> tax = await localAPI.getTaxName(taxlistitem.taxId);
        var taxval = taxlistitem.rate != null
            ? subT * double.parse(taxlistitem.rate) / 100
            : 0.0;
        taxval = double.parse(taxval.toStringAsFixed(2));
        taxvalue += taxval;
        setState(() {
          taxvalues = taxvalue;
        });
        var taxmap = {
          "id": taxlistitem.id,
          "tax_id": taxlistitem.taxId,
          "branch_id": taxlistitem.branchId,
          "rate": taxlistitem.rate,
          "status": taxlistitem.status,
          "updated_at": taxlistitem.updatedAt,
          "updated_by": taxlistitem.updatedBy,
          "taxAmount": taxval.toString(),
          "taxCode": tax.length > 0 ? tax[0].code : "" //tax.code
        };
        totalTax.add(taxmap);
      }
    }
    return totalTax;
  }

  countDiscount() {
    return currentCart.discount != null
        ? double.parse(currentCart.discount.toStringAsFixed(2))
        : 0.0;
  }

  produtAddTocart() async {
    MST_Cart cart = new MST_Cart();
    SaveOrder orderData = new SaveOrder();
    MSTSubCartdetails subCartData = new MSTSubCartdetails();
    var branchid = await CommunFun.getbranchId();
    var table = await Preferences.getStringValuesSF(Constant.TABLE_DATA);
    var loginUser = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
    var customerData =
        await Preferences.getStringValuesSF(Constant.CUSTOMER_DATA);
    var customer =
        customerData != null ? json.decode(customerData) : customerData;
    var customerid = customer != null ? customer["customer_id"] : 0;
    var tableData = await json.decode(table); // table data
    var loginData = await json.decode(loginUser);
    var qty = await countTotalQty();
    var disc = await countDiscount();
    var subtotal = await countSubtotal();
    var totalTax = await countTax(subtotal);
    var grandTotal = await countGrandtotal(taxvalues, disc);

    //cart data
    cart.user_id = customerid;
    cart.branch_id = int.parse(branchid);
    cart.sub_total = double.parse(subtotal.toStringAsFixed(2));
    cart.discount = disc;
    cart.table_id = tableData["table_id"];
    cart.discount_type = currentCart.discount_type;
    cart.total_qty = qty;
    cart.tax = taxvalues;
    cart.source = 2;
    cart.tax_json = json.encode(totalTax);
    cart.grand_total = double.parse(grandTotal.toStringAsFixed(2));
    cart.customer_terminal = customer != null ? customer["terminal_id"] : 0;
    if (!isEditing) {
      cart.created_at = await CommunFun.getCurrentDateTime(DateTime.now());
    }
    cart.created_by = loginData["id"];
    cart.localID = await CommunFun.getLocalID();

    orderData.orderName = tableData != null ? "" : "test";
    if (!isEditing) {
      orderData.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
    }
    orderData.numberofPax = tableData != null ? tableData["number_of_pax"] : 0;
    orderData.isTableOrder = tableData != null ? 1 : 0;
    if (!isEditing) {
      orderData.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
    }
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
    cartdetails.productPrice =
        double.parse(productdata.price.toStringAsFixed(2));
    cartdetails.productQty = productdata.qty;
    cartdetails.productNetPrice = productdata.price;

    cartdetails.createdBy = loginData["id"];
    cartdetails.discount = 0;
    cartdetails.taxValue = taxvalues;
    cartdetails.printer_id = printer != null ? printer.printerId : 0;
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
    if (isEditing && cartitem.isSendKichen == 1) {
      var items = [];
      items.add(cartitem);
      //  senditemtoKitchen(items);
    }
    await Navigator.pushNamed(context, Constant.DashboardScreen);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(0),
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
      content: mainContent(),
      //main part of the popup
      actions: <Widget>[
        // Button div + - buttons
        Stack(
          children: <Widget>[
            Positioned(
                bottom: 10,
                right: 30,
                child: Text(productItem.priceTypeName + " " + price.toString(),
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.of(context).size.width / 2.8,
      height: MediaQuery.of(context).size.height / 1.8,
      child: SingleChildScrollView(
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
            SizedBox(height: 5),
            inputNotesView(),
          ],
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
                  height: 50,
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
          Text(isEditing ? Strings.update : Strings.add,
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
