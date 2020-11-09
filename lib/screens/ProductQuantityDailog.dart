import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/Attribute_data.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/ModifireData.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/Printer.dart';
import 'package:mcncashier/models/Product_Store_Inventory.dart';
import 'package:mcncashier/models/BranchTax.dart';
import 'package:mcncashier/models/SetMeal.dart';
import 'package:mcncashier/models/SetMealProduct.dart';
import 'package:mcncashier/models/Table_order.dart';
import 'package:mcncashier/models/Tax.dart';
import 'package:mcncashier/models/mst_sub_cart_details.dart';
import 'package:mcncashier/models/saveOrder.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/theme/Sized_Config.dart';

class ProductQuantityDailog extends StatefulWidget {
  // quantity Dailog
  ProductQuantityDailog(
      {Key key,
      this.selproduct,
      this.issetMeal,
      this.cartID,
      this.cartItem,
      this.onClose})
      : super(key: key);
  final bool issetMeal;
  final selproduct;
  final int cartID;
  final cartItem;
  Function onClose;

  @override
  _ProductQuantityDailogState createState() => _ProductQuantityDailogState();
}

class _ProductQuantityDailogState extends State<ProductQuantityDailog> {
  TextEditingController productController = new TextEditingController();
  TextEditingController extraNotes = new TextEditingController();
  LocalAPI localAPI = LocalAPI();
  List<Attribute_Data> attributeList = [];
  ProductDetails productItem = new ProductDetails();
  SetMeal setmeal;
  MSTCartdetails cartitem;
  List<SetMealProduct> tempCart = new List<SetMealProduct>();
  List<ModifireData> modifireList = [];
  List selectedAttr = [];
  List selectedSetMealAttr = [];
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
  String attributeTitle = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      isSetMeal = widget.issetMeal;
      isEditing = widget.cartItem != null;
      cartitem = widget.cartItem;
    });
    setInitstate();
  }

  setInitstate() async {
    if (isSetMeal) {
      setState(() {
        setmeal = widget.selproduct;
        price = setmeal.price;
        productnetprice = setmeal.price;
      });
      getMealProducts();
    } else {
      setState(() {
        productItem = widget.selproduct;
        price = productItem.price;
        productnetprice = productItem.price;
      });
      getAttributes(productItem.productId);
    }

    getTaxs();
    getPrinter();

    if (widget.cartID != null) {
      getCartData();
      getcartItemList();
    }
    var curre = await Preferences.getStringValuesSF(Constant.CURRENCY);
    setState(() {
      currency = curre;
    });
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
    } else {
      tempCart.addAll(mealProducts);
    }
  }

  getMealProducts() async {
    List<SetMealProduct> mealProductList =
        await localAPI.getMealsProductData(setmeal.setmealId);
    if (mealProductList.length > 0) {
      setState(() {
        mealProducts = mealProductList;
      });
      await setSetMealData();
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

  setProductEditingData() async {
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
                        attrIDs[a], attrtypesPrice[a], null);
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
      if (cartitem.remark != null && cartitem.remark.isNotEmpty) {
        extraNotes.text = cartitem.remark;
      }
      setState(() {
        product_qty = cartitem.productQty is int
            ? cartitem.productQty.toDouble()
            : cartitem.productQty;
        price = cartitem.productPrice;
      });
    }
  }

  getAttributes(productid) async {
    List<Attribute_Data> productAttr =
        await localAPI.getProductDetails(productid);
    if (productAttr.length > 0) {
      setState(() {
        attributeList = productAttr;
      });
    }

    List<ModifireData> productModifeir =
        await localAPI.getProductModifeir(productid);
    if (productModifeir.length > 0) {
      setState(() {
        modifireList = productModifeir;
      });
    }
    if (isEditing) {
      setProductEditingData();
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

//  if (attributeList.length > 0) {
//                   for (var i = 0; i < attributeList.length; i++) {
//                     var attribute = attributeList[i];
//                     var attributType = attribute.attr_types.split(',');
//                     var attrIDs = attribute.attributeId.split(',');
//                     var attrtypesPrice = attribute.attr_types_price.split(',');
//                     for (var a = 0; a < attributType.length; a++) {
//                       var aattrid = int.parse(attrIDs[a]);
//                       if (item.attributeId == aattrid) {
//                         setState(() {
//                           isEditing = true;
//                         });
//                       } else {
//                         setState(() {
//                           isEditing = false;
//                           cartitem = null;
//                         });
//                       }
//                     }
//                   }
//                 }
//  if (modifireList.length > 0) {
//                   for (var j = 0; j < modifireList.length; j++) {
//                     if (modifireList[j].modifierId == item.modifierId) {
//                       setState(() {
//                         isEditing = true;
//                       });
//                     } else {
//                       setState(() {
//                         isEditing = false;
//                         cartitem = null;
//                       });
//                     }
//                   }
//                 }
  getcartItemList() async {
    List<MSTCartdetails> cartItemslist =
        await localAPI.getCurrentCartItems(widget.cartID);
    if (cartItemslist.length != 0) {
      setState(() {
        cartItems = cartItemslist;
      });
    }
  }

  getcartItemsDetails() async {
    if (!isSetMeal) {
      var contain = cartItems
          .where((element) => element.productId == productItem.productId);
      if (contain.isNotEmpty) {
        var jsonString = jsonEncode(contain.map((e) => e.toJson()).toList());
        List<MSTCartdetails> myModels = (json.decode(jsonString) as List)
            .map((i) => MSTCartdetails.fromJson(i))
            .toList();
        var sameAttributes = [];
        MSTCartdetails itemset = new MSTCartdetails();
        for (var m = 0; m < myModels.length; m++) {
          List<MSTSubCartdetails> details =
              await localAPI.getItemModifire(myModels[m].id);
          if (details.length > 0) {
            for (var p = 0; p < details.length; p++) {
              var item = details[p];
              if (item.caId != null) {
                if (selectedAttr.length > 0) {
                  for (var i = 0; i < selectedAttr.length; i++) {
                    var attr = selectedAttr[i];
                    if (item.attributeId == int.parse(attr["attrType_ID"])) {
                      sameAttributes.add(item);
                    }
                  }
                }
              } else {
                if (selectedModifier.length > 0) {
                  for (var i = 0; i < selectedModifier.length; i++) {
                    var modifire = selectedModifier[i];
                    if (item.modifierId == modifire.modifierId) {
                      sameAttributes.add(item);
                    }
                  }
                }
              }
            }
          }
          if (selectedAttr.length != 0 || selectedModifier.length != 0) {
            if (details.length > 0 && sameAttributes.length == details.length) {
              setState(() {
                isEditing = true;
                cartitem = myModels[m];
              });
            }
          } else {
            if (details.length == 0) {
              setState(() {
                isEditing = true;
                cartitem = myModels[m];
              });
            }
          }
        }
        if (isEditing && cartitem != null) {
          setState(() {
            product_qty =
                isEditing ? product_qty + cartitem.productQty : product_qty;
            price = isEditing ? price + cartitem.productPrice : price;
          });
        }
      }
    } else {
      //Put logic here for set Meal update
      print(cartItems);
      var contain =
          cartItems.where((element) => element.productId == setmeal.setmealId);
      print(contain);
      if (contain.isNotEmpty) {
        var jsonString = jsonEncode(contain.map((e) => e.toJson()).toList());
        List<MSTCartdetails> prodData = (json.decode(jsonString) as List)
            .map((i) => MSTCartdetails.fromJson(i))
            .toList();
        setmeal.price = prodData[0].productPrice;
        List<SetMealProduct> tCartData = [];
        if (prodData[0] != null) {
          List<dynamic> cartData =
              jsonDecode(prodData[0].setmeal_product_detail);
          tCartData = cartData.isNotEmpty
              ? cartData.map((c) => SetMealProduct.fromJson(c)).toList()
              : [];
        }
        setState(() {
          isEditing = true;
          setmeal = setmeal;
          price = setmeal.price;
          product_qty = prodData[0].productQty;
          tempCart = tCartData;
          cartitem = prodData[0];
        });
      }
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

  onSelectAttr(i, id, attribute, attrTypeIDs, attrPrice, setmealid) {
    var prvSeelected = selectedAttr;
    var isSelected = selectedAttr.any((item) => item['ca_id'] == id);
    if (isSelected) {
      var isarrSelected =
          selectedAttr.any((item) => item['attribute'] == attribute);
      selectedAttr.removeWhere((item) => item['ca_id'] == id);
      if (!isarrSelected) {
        prvSeelected.add({
          'ca_id': id,
          'attribute': attribute,
          'attrType_ID': attrTypeIDs,
          'attr_price': attrPrice
        });
      }
      setState(() {
        selectedAttr = selectedAttr;
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
    // if (!isSetMeal) {
    //   if (isSelectedAttr == i) {
    //     isSelectedAttr = -1;
    //   } else {
    //     isSelectedAttr = i;
    //   }
    //   selectedAttr.clear();
    //   if (isSelectedAttr != -1) {
    //     selectedAttr.add({
    //       'ca_id': id,
    //       'attribute': attribute,
    //       'attrType_ID': attrTypeIDs,
    //       'attr_price': attrPrice
    //     });
    //   }
    //   setState(() {
    //     selectedAttr = selectedAttr;
    //   });
    // } else {
    //   //Setmenal attribute

    // }
    setPrice();
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
        if (!isSetMeal) {
          selectedITemTotal = selectedITemTotal - cartitem.productPrice;
        } else {
          selectedITemTotal = selectedITemTotal - setmeal.price;
        }
      }
      subT = selectedITemTotal + price;
    } else {
      subT += price;
    }
    return subT;
  }

  countGrandtotal(subt, serviceCharge, tax, dis) {
    double grandTotal = 0;
    grandTotal = (((subt - dis) + serviceCharge) + tax);
    return grandTotal;
  }

  _setSelectUnselect(SetMealProduct product) {
    var isSelected = tempCart
        .any((item) => item.setmealProductId == product.setmealProductId);
    if (isSelected) {
      tempCart.removeWhere(
          (item) => item.setmealProductId == product.setmealProductId);
      setState(() {
        tempCart = tempCart;
      });
    } else {
      tempCart.add(product);
      setState(() {
        tempCart = tempCart;
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

  checkIsAvailble() async {}

  produtAddTocart() async {
    MST_Cart cart = new MST_Cart();
    SaveOrder orderData = new SaveOrder();
    var branchid = await CommunFun.getbranchId();
    var loginUser = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
    var customerData =
        await Preferences.getStringValuesSF(Constant.CUSTOMER_DATA);
    var customer =
        customerData != null ? json.decode(customerData) : customerData;
    var customerid = customer != null ? customer["customer_id"] : 0;
    Table_order tableData = await CommunFun.getTableData(); // table data
    var loginData = await json.decode(loginUser);
    var qty = await countTotalQty();
    var disc = await countDiscount();
    var subtotal = await countSubtotal();
    var serviceCharge =
        await CommunFun.countServiceCharge(tableData.service_charge, subtotal);
    var serviceChargePer =
        tableData.service_charge == null
            ? await CommunFun.getServiceChargePer()
            : tableData.service_charge;

    var totalTax = await countTax(subtotal);
    var grandTotal =
        await countGrandtotal(subtotal, serviceCharge, taxvalues, disc);

    //cart data
    cart.user_id = customerid;
    cart.branch_id = int.parse(branchid);
    cart.sub_total = double.parse(subtotal.toStringAsFixed(2));
    cart.serviceCharge = CommunFun.getDoubleValue(serviceCharge);
    cart.serviceChargePercent = CommunFun.getDoubleValue(serviceChargePer);
    cart.discount = disc;
    cart.table_id = tableData.table_id;
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
    orderData.numberofPax = tableData != null ? tableData.number_of_pax : 0;
    orderData.isTableOrder = tableData != null ? 1 : 0;
    if (!isEditing) {
      orderData.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
    }

    ///insert
    var cartid = await localAPI.insertItemTocart(
        currentCart.id, cart, productItem, orderData, tableData.table_id);
    ProductDetails cartItemproduct = new ProductDetails();
    if (!isSetMeal) {
      cartItemproduct = productItem;
    } else {
      cartItemproduct.qty = product_qty;
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
    // if (!isEditing && !isSetMeal) {
    //   await getcartItemsDetails();
    // }
    if (isEditing) {
      cartdetails.id = cartitem.id;
    }
    cartdetails.cartId = cartid;
    cartdetails.productId =
        isSetMeal ? setmeal.setmealId : productItem.productId;
    cartdetails.productName = isSetMeal ? setmeal.name : productItem.name;
    cartdetails.productSecondName = isSetMeal ? "" : productItem.name_2;
    cartdetails.productPrice = double.parse(price.toStringAsFixed(2));
    cartdetails.productQty = product_qty.toDouble();
    cartdetails.productNetPrice =
        double.parse(productnetprice.toStringAsFixed(2));
    cartdetails.createdBy = loginData["id"];
    cartdetails.cart_detail = jsonEncode(data);
    cartdetails.discount = 0;
    cartdetails.localID = await CommunFun.getLocalID();
    cartdetails.remark =
        extraNotes.text.trim().isNotEmpty ? extraNotes.text.trim() : "";
    cartdetails.issetMeal = isSetMeal ? 1 : 0;
    cartdetails.taxValue = taxvalues;
    cartdetails.printer_id = printer != null ? printer.printerId : 0;
    cartdetails.createdAt = DateTime.now().toString();
    if (isSetMeal) {
      cartdetails.setmeal_product_detail = json.encode(tempCart);
    }
    var detailID = await localAPI.addintoCartDetails(cartdetails);
    await localAPI.deletesubcartDetail(detailID);
    if (selectedModifier.length > 0) {
      for (var i = 0; i < selectedModifier.length; i++) {
        MSTSubCartdetails subCartData = new MSTSubCartdetails();
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
        MSTSubCartdetails subCartData = new MSTSubCartdetails();
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
    if (isEditing) {
      if (!isSetMeal) {
        if (cartitem.isSendKichen == 1) {
          var items = [];
          items.add(cartitem);
          //senditemtoKitchen(items);
        }
      }
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
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            isSetMeal ? SizedBox() : getAttributeList(),
            getMealsProductList(),
            isSetMeal
                ? SizedBox()
                : modifireList.length != 0
                    ? Text(
                        Strings.modifier,
                        style: TextStyle(
                            fontSize: SizeConfig.safeBlockVertical * 3),
                      )
                    : SizedBox(),
            SizedBox(height: 5),
            isSetMeal
                ? SizedBox()
                : modifireList.length != 0 ? modifireItmeList() : SizedBox(),
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
            // color: Colors.green,
            height: MediaQuery.of(context).size.height / 2.1,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: mealProducts.map((product) {
                    var index = mealProducts.indexOf(product);
                    return InkWell(
                        onTap: () {
                          _setSelectUnselect(product);
                          //  getAttributes(product.productId);
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 8),
                          decoration: new BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8.0)),
                          /* color: tempCart
                              .where((element) =>
                                  element.setmealProductId ==
                                  product.setmealProductId)
                              .isNotEmpty
                          ? Colors.grey[100]
                          : Colors.white,*/
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Hero(
                                    tag: product.productId,
                                    child: new Stack(
                                      children: [
                                        Container(
                                          height:
                                              SizeConfig.safeBlockVertical * 8,
                                          width:
                                              SizeConfig.safeBlockVertical * 9,
                                          child: product.base64 != "" &&
                                                  product.base64 != null
                                              ? CommonUtils
                                                  .imageFromBase64String(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(product.name.toUpperCase(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                        Icon(
                                          tempCart
                                                  .where((element) =>
                                                      element
                                                          .setmealProductId ==
                                                      product.setmealProductId)
                                                  .isNotEmpty
                                              ? Icons.check_circle
                                              : Icons.check_circle_outline,
                                          color: Colors.green,
                                          size: 40,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              getsetMealAttrList(product),
                            ],
                          ),
                        ));
                  }).toList()),
            ),
          )
        : SizedBox();
  }

  Widget getsetMealAttrList(SetMealProduct product) {
    List<Attribute_Data> attrList = [];
    if (product.attributeDetails != "" && product.attributeDetails != null) {
      List<dynamic> attrdata = jsonDecode(product.attributeDetails);
      attrList = attrdata.isNotEmpty
          ? attrdata.map((c) => Attribute_Data.fromJson(c)).toList()
          : [];
      print(attrList);
    }

    return Container(
      //color: Colors.white,
      margin: EdgeInsets.only(bottom: isSetMeal ? 0 : 10, top: 0),
      // MediaQuery.of(context).size.height /8,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: BouncingScrollPhysics(),
        children: attrList.map((attribute) {
          var attributType = [];
          Map attrIDs;
          Map attrtypesPrice;
          if (attribute.ca_id != null) {
            attributType = attribute.attr_types.split(',');
            attrIDs = attribute.attributeId.split(',').asMap();
            attrtypesPrice = attribute.attr_types_price.split(',').asMap();
          }
          /*Set attribute name for selection toast*/
          attributeTitle = attribute.attr_name;
          return attribute.ca_id != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      attribute.attr_name != null ? attribute.attr_name : "",
                      style:
                          TextStyle(fontSize: SizeConfig.safeBlockVertical * 3),
                    ),
                    Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
                        height: SizeConfig.safeBlockVertical * 9,
                        child: ListView(
                            physics: BouncingScrollPhysics(),
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
                                                  color: selectedAttr.any(
                                                          (item) =>
                                                              item['ca_id'] ==
                                                                  attribute
                                                                      .ca_id &&
                                                              item['attribute'] ==
                                                                  attr)
                                                      ? Colors.green
                                                      : Colors.grey[300],
                                                  width: 4,
                                                )),
                                            minWidth: 50,
                                            child: Text(attr.toString(),
                                                style:
                                                    Styles.blackMediumBold()),
                                            textColor: Colors.black,
                                            color: Colors.grey[300],
                                            onPressed: () {
                                              onSelectAttr(
                                                  i,
                                                  attribute.ca_id,
                                                  attr,
                                                  attrIDs[i],
                                                  attrtypesPrice[i],
                                                  null);
                                            },
                                          )));
                                })
                                .values
                                .toList()))
                  ],
                )
              : SizedBox();
        }).toList(),
      ),
    );
  }

  Widget getAttributeList() {
    return Container(
      //color: Colors.white,
      margin: EdgeInsets.only(bottom: isSetMeal ? 0 : 10, top: 0),
      // MediaQuery.of(context).size.height /8,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: BouncingScrollPhysics(),
        children: attributeList.map((attribute) {
          var attributType = attribute.attr_types.split(',');
          var attrIDs = attribute.attributeId.split(',').asMap();
          var attrtypesPrice = attribute.attr_types_price.split(',').asMap();
          /*Set attribute name for selection toast*/
          attributeTitle = attribute.attr_name;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              isSetMeal ? SizedBox() : SizedBox(height: 10),
              isSetMeal
                  ? SizedBox()
                  : Text(
                      attribute.attr_name != null ? attribute.attr_name : "",
                      style:
                          TextStyle(fontSize: SizeConfig.safeBlockVertical * 3),
                    ),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
                  height: SizeConfig.safeBlockVertical * 9,
                  child: ListView(
                      physics: BouncingScrollPhysics(),
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
                                      minWidth: 50,
                                      child: Text(attr.toString(),
                                          style: Styles.blackMediumBold()),
                                      textColor: Colors.black,
                                      color: Colors.grey[300],
                                      onPressed: () {
                                        onSelectAttr(
                                            i,
                                            attribute.ca_id,
                                            attr,
                                            attrIDs[i],
                                            attrtypesPrice[i],
                                            null);
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
            physics: BouncingScrollPhysics(),
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
        padding: EdgeInsets.all(10),
        child: TextField(
          controller: extraNotes,
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
    return RaisedButton(
      onPressed: () {
        if (attributeList.length > 0) {
          if (selectedAttr.length > 0) {
            if (isEditing) {
              updateCartItem();
            } else {
              produtAddTocart();
            }
          } else {
            CommunFun.showToast(context, "Please select " + attributeTitle);
          }
        } else {
          if (isEditing) {
            updateCartItem();
          } else {
            produtAddTocart();
          }
        }
      },
      child: Row(
        children: <Widget>[
          !isEditing
              ? Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: SizeConfig.safeBlockVertical * 3.5,
                )
              : Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: SizeConfig.safeBlockVertical * 3.5,
                ),
          SizedBox(width: 5),
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
