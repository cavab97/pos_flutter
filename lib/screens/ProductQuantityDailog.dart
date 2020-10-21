import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/Attribute_data.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/ModifireData.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/Printer.dart';
import 'package:mcncashier/models/Product_Store_Inventory.dart';
import 'package:mcncashier/models/BranchTax.dart';
import 'package:mcncashier/models/SetMeal.dart';
import 'package:mcncashier/models/SetMealProduct.dart';
import 'package:mcncashier/models/Tax.dart';
import 'package:mcncashier/models/mst_sub_cart_details.dart';
import 'package:mcncashier/models/saveOrder.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/theme/Sized_Config.dart';

class ProductQuantityDailog extends StatefulWidget {
  // quantity Dailog
  ProductQuantityDailog(
      {Key key,
      this.product,
      this.issetMeal,
      this.cartID,
      this.cartItem,
      this.onClose})
      : super(key: key);
  final bool issetMeal;
  final product;
  final int cartID;
  final cartItem;
  Function onClose;

  @override
  _ProductQuantityDailogState createState() => _ProductQuantityDailogState();
}

class _ProductQuantityDailogState extends State<ProductQuantityDailog> {
  TextEditingController productController = new TextEditingController();
  LocalAPI localAPI = LocalAPI();
  List<Attribute_Data> attributeList = [];
  ProductDetails productItem;
  SetMeal setmeal;
  MSTCartdetails cartitem;
  List<SetMealProduct> tempCart = new List<SetMealProduct>();
  List<ModifireData> modifireList = [];
  List selectedAttr = [];
  MST_Cart currentCart = new MST_Cart();
  List<MSTCartdetails> cartItems = [];
  List<SetMealProduct> mealProducts = [];
  List<ModifireData> selectedModifier = [];
  double product_qty = 1.0;
  double price = 0.00;
  Printer printer;
  bool isEditing = false;
  List<BranchTax> taxlist = [];
  double taxvalues = 0.00;
  int isSelectedAttr = -1;
  bool isSetMeal = false;
  var productnetprice = 0.00;
  var currency;

  @override
  void initState() {
    super.initState();
    setState(() {
      isSetMeal = widget.issetMeal;
      isEditing = widget.cartItem != null;
      cartitem = widget.cartItem;
    });
    setstate();
  }

  setSetMealData() {
    if (cartitem != null) {
      List<dynamic> cartData = jsonDecode(cartitem.setmeal_product_detail);

      List<SetMealProduct> tCartData = cartData.isNotEmpty
          ? cartData.map((c) => SetMealProduct.fromJson(c)).toList()
          : [];

      setState(() {
        tempCart = tCartData;
      });
      print("===============================");

      tempCart.forEach((element) {
        print(element.setmealProductId);
        print(element.setmealId);
      });
    }
  }

  setstate() async {
    if (isSetMeal) {
      setSetMealData();
      setState(() {
        setmeal = widget.product;
        price = setmeal.price;
        productnetprice = setmeal.price;
      });
    } else {
      setState(() {
        productItem = widget.product;
        price = productItem.price;
        productnetprice = productItem.price;
      });
    }
    if (isSetMeal) {
      getMealProducts();
      if (isEditing) {
        setEditingData();
      }
    } else {
      getAttributes();
    }
    getTaxs();
    getPrinter();

    if (widget.cartID != null) {
      getCartData();
      getcartItemsDetails();
    }
    var curre = await Preferences.getStringValuesSF(Constant.CURRENCY);
    setState(() {
      currency = curre;
    });
  }

  getMealProducts() async {
    List<SetMealProduct> mealProductList =
        await localAPI.getMealsProductData(setmeal.setmealId);
    if (mealProductList.length > 0) {
      setState(() {
        mealProducts = mealProductList;
      });
      tempCart.addAll(mealProducts);
    }
  }

  getPrinter() async {
    List<Printer> printerlist = await localAPI.getPrinter(
        !isSetMeal ? productItem.productId.toString() : setmeal.setmealId);
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
    if (!isSetMeal) {
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
                var attrIDs = attribute.attributeId.split(',');
                var attrtypesPrice = attribute.attr_types_price.split(',');
                for (var a = 0; a < attributType.length; a++) {
                  var aattrid = int.parse(attrIDs[a]);
                  if (item.attributeId == aattrid) {
                    onSelectAttr(a, attribute.ca_id, attributType[a],
                        attrIDs[a], attrtypesPrice[a]);
                    break;
                  }
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
    if (isSetMeal) {
      var prevproductqty = product_qty;
      setState(() {
        product_qty = prevproductqty + 1;
      });
      setPrice();
    } else {
      if (productItem.hasInventory == 1) {
        List<ProductStoreInventory> cartval =
            await localAPI.checkItemAvailableinStore(productItem.productId);
        if (cartval.length > 0) {
          double storeqty = cartval[0].qty;
          if (storeqty > product_qty) {
            var prevproductqty = product_qty;
            setState(() {
              product_qty = prevproductqty + 1;
            });
            setPrice();
          } else {
            CommunFun.showToast(context, Strings.stock_not_valilable);
          }
        } else {
          var prevproductqty = product_qty;
          setState(() {
            product_qty = prevproductqty + 1;
          });
          setPrice();
        }
      } else {
        var prevproductqty = product_qty;
        setState(() {
          product_qty = prevproductqty + 1;
        });
        setPrice();
      }
    }
  }

  decreaseQty() {
    if (product_qty > 1) {
      var prevproductqty = product_qty;
      setState(() {
        product_qty = prevproductqty - 1;
      });
      setPrice();
    }
  }

  onSelectAttr(i, id, attribute, attrTypeIDs, attrPrice) {
    if (isSelectedAttr == i) {
      isSelectedAttr = -1;
    } else {
      isSelectedAttr = i;
    }

    selectedAttr.clear();
    if (isSelectedAttr != -1) {
      selectedAttr.add({
        'ca_id': id,
        'attribute': attribute,
        'attrType_ID': attrTypeIDs,
        'attr_price': attrPrice
      });
    }
    setState(() {
      selectedAttr = selectedAttr;
    });
    setPrice();
    /*// var array = [];
    var prvSeelected = selectedAttr;
    var isSelected =
        selectedAttr.any((item) => item['attrType_ID'] == attrTypeIDs);
    if (isSelected) {
      selectedAttr.removeWhere((item) => item['attrType_ID'] == attrTypeIDs);
      */ /* prvSeelected.add({
        'ca_id': id,
        'attribute': attribute,
        'attrType_ID': attrTypeIDs,
        'attr_price': attrPrice
      });*/ /*
      setState(() {
        selectedAttr = prvSeelected;
      });
    } else {
      prvSeelected.removeWhere((item) => item['attrType_ID'] == attrTypeIDs);
      prvSeelected.add({
        'ca_id': id,
        'attribute': attribute,
        'attrType_ID': attrTypeIDs,
        'attr_price': attrPrice
      });
      setState(() {
        selectedAttr = prvSeelected;
      });
    }*/
  }

  setPrice() {
    var productPrice = productnetprice;
    var newPrice = productPrice;
    if (!isSetMeal) {
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
    }
    var pricewithQty = newPrice * product_qty;
    setState(() {
      price = pricewithQty;
    });
  }

  setModifire(mod) {
    var isSelected = selectedModifier.any((item) => item.pmId == mod.pmId);
    if (isSelected) {
      selectedModifier.removeWhere((item) => item.pmId == mod.pmId);
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
        if (isSetMeal) {
          if (item.productId == setmeal.setmealId) {
            item.productQty = product_qty;
          }
        } else {
          if (item.productId == productItem.productId) {
            item.productQty = product_qty;
          }
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
      double selectedITemTotal = 0;
      for (var i = 0; i < cartItems.length; i++) {
        var item = cartItems[i];
        selectedITemTotal += item.productPrice;
      }
      if (isEditing) {
        selectedITemTotal = selectedITemTotal - cartitem.productPrice;
      }
      subT = selectedITemTotal + price;
    } else {
      subT += price;
    }
    return subT;
  }

  countGrandtotal(subt, tax, dis) {
    double grandTotal = 0;
    // if (cartItems.length > 0) {
    //   for (var i = 0; i < cartItems.length; i++) {
    //     var item = cartItems[i];
    //     if (isSetMeal) {
    //       if (item.productId == setmeal.setmealId) {
    //         item.productQty = product_qty;
    //       }
    //     } else {
    //       if (item.productId == productItem.productId) {
    //         item.productPrice = price;
    //       }
    //     }
    //     grandTotal += item.productPrice;
    //   }
    //   if (!isEditing) {
    //     grandTotal += price;
    //   }
    // } else {
    //   grandTotal += price;
    // }
    grandTotal = ((subt - dis) + tax);
    return grandTotal;
  }

  _setSelectUnselect(SetMealProduct product) {
    var contain = tempCart.where(
        (element) => element.setmealProductId == product.setmealProductId);
    if (contain.isNotEmpty) {
      setState(() {
        tempCart.remove(product);
      });
    } else if (contain.isEmpty) {
      setState(() {
        tempCart.add(product);
      });
    }
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
          "taxAmount": taxval.toStringAsFixed(2),
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
        : 0.00;
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
    var grandTotal = await countGrandtotal(subtotal, taxvalues, disc);

    //cart data
    cart.user_id = customerid;
    cart.branch_id = int.parse(branchid);
    cart.sub_total = double.parse(subtotal.toStringAsFixed(2));
    cart.discount = disc;
    cart.table_id = tableData["table_id"];
    cart.discount_type = currentCart.discount_type;
    cart.total_qty = qty;
    cart.tax = double.parse(taxvalues.toStringAsFixed(2));
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

    // MST Sub Cart details

    ///insert
    var cartid = await localAPI.insertItemTocart(currentCart.id, cart,
        productItem, orderData, tableData["table_id"], subCartData);
    ProductDetails cartItemproduct = new ProductDetails();

    if (!isSetMeal) {
      cartItemproduct = productItem;
      cartItemproduct.qty = product_qty;
      cartItemproduct.price = double.parse(price.toStringAsFixed(2));
    } else {
      cartItemproduct.qty = product_qty;
      cartItemproduct.price = double.parse(price.toStringAsFixed(2));
      cartItemproduct.status = setmeal.status;
      cartItemproduct.productId = setmeal.setmealId;
      cartItemproduct.base64 = setmeal.base64;
      cartItemproduct.name = setmeal.name;
      cartItemproduct.uuid = setmeal.uuid;
    }
    cartItemproduct
        .toJson()
        .removeWhere((String key, dynamic value) => value == null);
    var data = cartItemproduct;
    MSTCartdetails cartdetails = new MSTCartdetails();
    if (isEditing) {
      cartdetails.id = cartitem.id;
    }

    cartdetails.cartId = cartid;
    cartdetails.productId =
        isSetMeal ? setmeal.setmealId : productItem.productId;
    cartdetails.productName = isSetMeal ? setmeal.name : productItem.name;
    cartdetails.productPrice = double.parse(price.toStringAsFixed(2));
    cartdetails.productQty = product_qty.toDouble();
    cartdetails.productNetPrice =
        double.parse(productnetprice.toStringAsFixed(2));
    cartdetails.createdBy = loginData["id"];
    cartdetails.cart_detail = jsonEncode(data);
    cartdetails.discount = 0;
    cartdetails.issetMeal = isSetMeal ? 1 : 0;
    cartdetails.taxValue = taxvalues;
    cartdetails.printer_id = printer != null ? printer.printerId : 0;
    cartdetails.createdAt = DateTime.now().toString();
    if (isSetMeal) {
      cartdetails.setmeal_product_detail = json.encode(tempCart);
    }
    var detailID = await localAPI.addintoCartDetails(cartdetails);

    if (selectedModifier.length > 0) {
      for (var i = 0; i < selectedModifier.length; i++) {
        var modifire = selectedModifier[i];
        subCartData.cartdetailsId = detailID;
        subCartData.localID = cart.localID;
        subCartData.productId = productItem.productId;
        subCartData.modifierId = modifire.modifierId;
        subCartData.modifirePrice = modifire.price;
        var res = await localAPI.addsubCartData(subCartData);
      }
    }
    if (selectedAttr.length > 0) {
      for (var i = 0; i < selectedAttr.length; i++) {
        var attr = selectedAttr[i];
        subCartData.cartdetailsId = detailID;
        subCartData.localID = cart.localID;
        subCartData.productId = productItem.productId;
        subCartData.caId = attr["ca_id"];
        subCartData.attributeId = int.parse(attr["attrType_ID"]);
        subCartData.attrPrice = int.parse(attr["attr_price"]).toDouble();
        var res = await localAPI.addsubCartData(subCartData);
      }
    }
    if (isEditing && cartitem.isSendKichen == 1) {
      var items = [];
      items.add(cartitem);
      //  senditemtoKitchen(items);
    }
    widget.onClose();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AlertDialog(
      contentPadding: EdgeInsets.all(0),
      titlePadding: EdgeInsets.all(0),
      title: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
            height: SizeConfig.safeBlockVertical * 9,
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(isSetMeal ? setmeal.name : productItem.name,
                    style: TextStyle(
                        fontSize: SizeConfig.safeBlockVertical * 3,
                        color: Colors.white)),
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
              child: Text(
                isSetMeal
                    ? currency != null
                        ? currency + " " + price.toStringAsFixed(2).toString()
                        : price.toStringAsFixed(2).toString()
                    : currency != null
                        ? currency + " " + price.toStringAsFixed(2).toString()
                        : price.toStringAsFixed(2).toString(),
                style: Styles.orangeMedium(),
              ),
            ),
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
      width: MediaQuery.of(context).size.width / 1.8,
      height: MediaQuery.of(context).size.height / 1.8,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            getAttributeList(),
            getMealsProductList(),
            modifireList.length != 0
                ? Text(
                    Strings.modifier,
                    style:
                        TextStyle(fontSize: SizeConfig.safeBlockVertical * 3),
                  )
                : SizedBox(),
            SizedBox(height: 5),
            modifireList.length != 0 ? modifireItmeList() : SizedBox(),
            SizedBox(height: 10),
            _extraNotesTitle(),
            SizedBox(height: 5),
            inputNotesView(),
          ],
        ),
      ),
    );
  }

  Widget getMealsProductList() {
    return isSetMeal
        ? Container(
            //color: Colors.green,
            height: MediaQuery.of(context).size.height / 2.1,
            child: SingleChildScrollView(
              child: Column(
                  children: mealProducts.map((product) {
                var index = mealProducts.indexOf(product);
                return InkWell(
                    onTap: () {
                      _setSelectUnselect(product);
                    },
                    child: Container(
                      color: tempCart
                              .where((element) =>
                                  element.setmealProductId ==
                                  product.setmealProductId)
                              .isNotEmpty
                          ? Colors.grey[100]
                          : Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Hero(
                            tag: product.productId,
                            child: new Stack(
                              children: [
                                Container(
                                  height: SizeConfig.safeBlockVertical * 8,
                                  width: SizeConfig.safeBlockVertical * 9,
                                  child: product.base64 != "" &&
                                          product.base64 != null
                                      ? CommonUtils.imageFromBase64String(
                                          product.base64)
                                      : new Image.asset(
                                          Strings.no_imageAsset,
                                          fit: BoxFit.cover,
                                          gaplessPlayback: true,
                                        ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 15),
                          Flexible(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(product.name.toUpperCase(),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: Styles.smallBlack())
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(product.quantity.toString(),
                                    style: Styles.smallBlack()),
                                SizedBox(width: 90),
                                IconButton(
                                  onPressed: () {
                                    var contain = tempCart.where((element) =>
                                        element.setmealProductId ==
                                        product.setmealProductId);
                                    if (contain.isNotEmpty) {
                                      setState(() {
                                        tempCart.remove(product);
                                      });
                                    } else if (contain.isEmpty) {
                                      setState(() {
                                        tempCart.add(product);
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    tempCart
                                            .where((element) =>
                                                element.setmealProductId ==
                                                product.setmealProductId)
                                            .isNotEmpty
                                        ? Icons.check_circle
                                        : Icons.check_circle_outline,
                                    color: Colors.green,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ));
              }).toList()),
            ),
          )
        : SizedBox();
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
                style: TextStyle(fontSize: SizeConfig.safeBlockVertical * 3),
              ),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
                  height: SizeConfig.safeBlockVertical * 9,
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
                                            color: i == isSelectedAttr
                                                ? Colors.green
                                                : Colors.grey[300],
                                            width: 4,
                                          )),
                                      minWidth: 50,
                                      child: Text(attr.toString(),
                                          style: Styles.blackMediumBold()),
                                      textColor: Colors.black,
                                      color: Colors.grey[300],
                                      onPressed: () {
                                        onSelectAttr(i, attribute.ca_id, attr,
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
        height: SizeConfig.safeBlockVertical * 9,
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
                    minWidth: 50,
                    child: Row(
                      children: <Widget>[
                        Text(
                          modifier.name.toString(),
                          style: Styles.blackMediumBold(),
                        ),
                        SizedBox(width: 10),
                        Text(
                          modifier.price.toStringAsFixed(2).toString(),
                          style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: SizeConfig.safeBlockVertical * 2.5),
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
          fontSize: SizeConfig.safeBlockVertical * 3,
          fontWeight: FontWeight.w400,
          color: Colors.grey[800]),
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
          style: TextStyle(
              fontSize: SizeConfig.safeBlockVertical * 3, height: 1.4),
          maxLines: 2,
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
      width: 100,
      decoration:
          BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
      child: Center(
        child: Text(
            product_qty.toString() +
                " " +
                (!isSetMeal
                    ? productItem.priceTypeName != null
                        ? productItem.priceTypeName
                        : ""
                    : ""),
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
                  size: SizeConfig.safeBlockVertical * 4,
                )
              : Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: SizeConfig.safeBlockVertical * 4,
                ),
          SizedBox(width: 10),
          Text(isEditing ? Strings.update : Strings.add,
              style: TextStyle(
                color: Colors.white,
                fontSize: SizeConfig.safeBlockVertical * 3,
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
