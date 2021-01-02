import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/colors.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/models/Voucher.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/screens/Dashboard.dart';
import 'package:mcncashier/models/ModifireData.dart';
import 'package:mcncashier/models/Attribute_data.dart';
import 'package:mcncashier/models/PorductDetails.dart';

class SetQuantityPad extends StatefulWidget {
  // Opning ammount popup
  SetQuantityPad(
      {Key key,
      this.selproduct,
      this.cartID,
      this.cartItem,
      this.focusCart,
      this.onClose})
      : super(key: key);
  final selproduct;
  final int cartID;
  final cartItem;
  final MSTCartdetails focusCart;
  Function onClose;

  @override
  _SetQuantityPadState createState() => _SetQuantityPadState();
}

class _SetQuantityPadState extends State<SetQuantityPad> {
  ProductDetails productItem = new ProductDetails();
  String currentNumber;
  String currentDiscountType = "RM";
  MSTCartdetails focusCartPad = new MSTCartdetails();
  LocalAPI localAPI = LocalAPI();
  int totalQuantity = 0;
  double currentProductQuantity = 0.0;
  TextEditingController extraNotes = new TextEditingController();
  List<MSTCartdetails> originalCartList = [];
  List<ModifireData> selectedModifier = [];
  List<ModifireData> modifireList = [];
  List<Attribute_Data> attributeList = [];
  List selectedAttr = [];
  bool isInit = true;
  MST_Cart allcartData = new MST_Cart();
  double serviceChargePer = 0;
  double subtotal = 0;
  double serviceCharge = 0;
  double discount = 0;
  double tax = 0;
  bool isWebOrder = false;
  double grandTotal = 0;
  Voucher selectedvoucher;
  double price = 0.00;
  var productnetprice = 0.00;
  @override
  void initState() {
    super.initState();
    print(widget.focusCart.productQty.toString());
    setState(() {
      focusCartPad = widget.focusCart;
      currentNumber = widget.focusCart.productQty.toStringAsFixed(0);
      productItem = widget.selproduct;
      print(productItem.name);
      price = productItem.price;
      productnetprice = productItem.price;
    });
    getAttributes(productItem.productId);
    //currentNumber = totalQuantity.toString();
  }

  setAttrData(productData) {
    if (productData["Attributes"].length > 0) {
      setState(() {
        attributeList.addAll(productData["Attributes"]);
      });
    }
  }

  setModifireData(productData) {
    if (productData["Modifire"].length > 0) {
      setState(() {
        modifireList.addAll(productData["Modifire"]);
      });
    }
    // if (isEditing) {
    //   setProductEditingData();
    // }
  }

  getAttributes(productid) async {
    List<Attribute_Data> productAttr =
        await localAPI.getProductDetails(productid);
    // if (productAttr.length > 0) {
    //   setState(() {
    //
    //   });
    // }

    List<ModifireData> productModifeir =
        await localAPI.getProductModifeir(productid);
    //if (productModifeir.length > 0) {
    setState(() {
      modifireList = productModifeir;
      attributeList = productAttr;
    });
    //}
    // if (isEditing) {
    //   setProductEditingData();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      title: Stack(
        // popup header
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.safeBlockVertical * 5),
            height: SizeConfig.safeBlockVertical * 9,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.black),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Quantity", style: Styles.communBlack()),
                // Text(
                //     currentDiscountType == "RM"
                //         ? currentDiscountType +
                //             CommunFun.getDecimalFormat(currentNumber)
                //         : CommunFun.getDecimalFormat(currentNumber) +
                //             currentDiscountType,
                //     style: Styles.communBlack()),
              ],
            ),
          ),
          closeButton(context), //popup close btn
        ],
      ),
      content: mainContent(), // Popup body contents
    );
  }

  backspaceClick() {
    if (currentNumber != "0") {
      var currentnumber = currentNumber;
      if (currentnumber != null && currentnumber.length > 0) {
        currentnumber = currentnumber.substring(0, currentnumber.length - 1);
        if (currentnumber.length == 0) {
          currentnumber = "0";
        }
        setState(() {
          currentNumber = currentnumber;
        });
      } else {
        currentNumber = "0";
      }
    }
  }

  clearClick() {
    setState(() {
      currentNumber = "0";
    });
  }

  numberClick(val) {
    // add  value in prev value
    int limit = currentDiscountType == "%" ? 3 : 8;

    if (currentNumber.length <= limit) {
      var currentnumber = currentNumber;
      if (currentnumber == "0") {
        currentnumber = "";
      }
      currentnumber += val;
      setState(() {
        currentNumber = currentnumber;
      });
    }
  }

  // countTotals(cartId) async {
  //   MST_Cart cart = await localAPI.getCartData(cartId);

  //   List<MSTCartdetails> cartdetails = await localAPI.getCartItem(cartId);
  //   var currentSubtotal = 0.00;

  //   Voucher vaocher;
  //   if (cart.voucher_id != null && cart.voucher_id != 0) {
  //     var voucherdetail = jsonDecode(cart.voucher_detail);
  //     vaocher = Voucher.fromJson(voucherdetail);
  //   }
  //   // taxJson = json.decode(cart.tax_json);
  //   if (cart.id == null) {
  //     return;
  //   }

  //   cartdetails.forEach((cartdetail) {
  //     if (isInit) originalCartList.add(cartdetail);
  //     currentSubtotal += cartdetail.productDetailAmount != null &&
  //             cartdetail.productDetailAmount != 0.00
  //         ? cartdetail.productDetailAmount
  //         : cartdetail.productPrice;
  //   });

  //   cart.sub_total = currentSubtotal;
  //   cart.serviceCharge = currentSubtotal * (cart.serviceChargePercent / 100);
  //   cart.grand_total = (cart.sub_total - cart.discount) +
  //       cart.tax +
  //       (cart.serviceCharge == null ? 0.00 : cart.serviceCharge);
  //   await localAPI.updateWebCart(cart);

  //   if (this.mounted) {
  //     setState(() {
  //       allcartData = cart;
  //       subtotal = cart.sub_total;
  //       serviceCharge = cart.serviceCharge == null ? 0.00 : cart.serviceCharge;
  //       serviceChargePer =
  //           cart.serviceChargePercent == null ? 0 : cart.serviceChargePercent;
  //       discount = cart.discount;
  //       tax = cart.tax;
  //       isWebOrder = cart.source == 1 ? true : false;
  //       grandTotal =
  //           (subtotal - discount) + tax + serviceCharge; //cart.grand_total;
  //       selectedvoucher = vaocher;
  //       if (isInit) isInit = false;
  //     });
  //   }
  //   print(grandTotal);
  // }

  submitQuantity(val) {
    var newPrice = focusCartPad.productPrice;

    if (focusCartPad.attrName.length > 0) {
      if (attributeList.length > 0) {
        for (var i = 0; i < attributeList.length; i++) {
          var attribute = attributeList[i];
          var attributType = attribute.attr_types.split(',');

          var attrtypesPrice = attribute.attr_types_price.split(',');

          for (var a = 0; a < attributType.length; a++) {
            if (focusCartPad.attrName == attributType[a]) {
              newPrice += double.parse(attrtypesPrice[a]);
              print("tureeeeeeeeee");
            }
          }
        }
      }
    }

    if (focusCartPad.modiName.length > 0) {
      for (var a = 0; a < modifireList.length; a++) {
        if (focusCartPad.modiName == modifireList[a].name) {
          newPrice += modifireList[a].price;
          print("tureeeeeeeeee");
        }
      }
    }

    currentProductQuantity = focusCartPad.productQty;
    focusCartPad.productQty = double.parse(currentNumber.toString());
    focusCartPad.productDetailAmount =
        double.parse(currentNumber.toString()) * newPrice;
    localAPI.addintoCartDetails(focusCartPad);
    print("focusCartPad");
    print(focusCartPad.productDetailAmount);
    // countTotals(focusCartPad.cartId);
    //  countTotals(focusCartPad.cartId);
    widget.onClose(focusCartPad.cartId);
  }

  // dicsountTypeClick(val) {
  //   // add  value in prev value

  //   if (val == "RM") {
  //     setState(() {
  //       currentDiscountType = val;
  //       currentNumber = "0";
  //     });
  //   } else if (val == "%") {
  //     setState(() {
  //       currentDiscountType = val;
  //       currentNumber = "0";
  //     });
  //   }
  // }

  Widget closeButton(context) {
    return Positioned(
      top: 10,
      right: 10,
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

  Widget mainContent() {
    return getNumbers(context);
  }

  Widget _button(String number, Function() f) {
    var size = MediaQuery.of(context).size.width / 2.3;
    double resize = size / 6;
    return Container(
      width: (number == "0") ? (resize * 3) : resize,
      padding: EdgeInsets.all(SizeConfig.safeBlockVertical * 1),
      height: (number == Strings.enter) ? (resize * 2) : resize,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.grey)),
        child: number != Strings.enter
            ? Text(number,
                textAlign: TextAlign.center, style: Styles.blackMediumBold())
            : Icon(Icons.save, size: 30),
        textColor: Colors.white,
        color: number == Strings.enter ? Colors.green[900] : Colors.grey[100],
        onPressed: f,
      ),
    );
  }

  Widget splshsButton(String number, Function() f) {
    var size = MediaQuery.of(context).size.width / 2.3;
    double resize = size / 6;
    return Expanded(
      child: Container(
        width: (number == "00") ? (resize * 2) : resize,
        padding: EdgeInsets.all(SizeConfig.safeBlockVertical * 1),
        height: (number == Strings.enter) ? (resize * 2) : resize,
        child: MaterialButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(color: Colors.grey)),
          child: number != Strings.enter
              ? Text(number,
                  textAlign: TextAlign.center, style: Styles.blackMediumBold())
              : Icon(Icons.subdirectory_arrow_left, size: 30),
          textColor: Colors.black,
          color: Colors.grey[100],
          onPressed: f,
        ),
      ),
    );
  }

  Widget _backbutton(Function() f) {
    var size = MediaQuery.of(context).size.width / 2.3;
    double resize = size / 6;
    return Container(
      width: resize,
      padding: EdgeInsets.all(5),
      height: resize,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: BorderSide(color: Colors.grey)),
        child: Icon(
          Icons.backspace,
          color: Colors.black,
          size: SizeConfig.safeBlockVertical * 4,
        ),
        textColor: Colors.black,
        color: Colors.grey[100],
        onPressed: f,
      ),
    );
  }

  Widget _clearbutton(String number, Function() f) {
    var size = MediaQuery.of(context).size.width / 2.3;
    double resize = size / 6;
    return Container(
      width: resize,
      padding: EdgeInsets.all(5),
      height: resize,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: BorderSide(color: Colors.grey)),
        // child: Icon(
        //   Icons.highlight_remove_sharp,
        //   color: Colors.black,
        //   size: SizeConfig.safeBlockVertical * 4,
        // ),
        child: Text(number),
        textColor: Colors.black,
        color: Colors.grey[100],
        onPressed: f,
      ),
    );
  }

  Widget getNumbers(context) {
    return Container(
      width: MediaQuery.of(context).size.width * .4,
      child: SingleChildScrollView(
          child: Table(
        border: TableBorder.all(color: Colors.white, width: 0.6),
        columnWidths: {
          0: FractionColumnWidth(.0),
          1: FractionColumnWidth(.7),
        },
        children: [
          TableRow(children: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 1),
                child: Column(
                  children: [],
                )),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 00),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _totalbutton(currentNumber, () {}),
                    ],
                  ),
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _button("7", () {
                        numberClick('7');
                      }), // using custom widget button
                      _button("8", () {
                        numberClick('8');
                      }),
                      _button("9", () {
                        numberClick('9');
                      }),
                      _backbutton(() {
                        backspaceClick();
                      }),
                    ],
                  ),
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _button("4", () {
                        numberClick('4');
                      }), // using custom widget button
                      _button("5", () {
                        numberClick('5');
                      }),
                      _button("6", () {
                        numberClick('6');
                      }),
                      _clearbutton("CLR", () {
                        clearClick();
                      }),
                    ],
                  ),
                  Row(children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _button("1", () {
                              numberClick('1');
                            }),
                            _button("2", () {
                              numberClick('2');
                            }),
                            _button("3", () {
                              numberClick('3');
                            }),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            _button("0", () {
                              numberClick('0');
                            }),
                          ],
                        ),
                      ],
                    ),
                    _button(Strings.enter, () {
                      submitQuantity(currentNumber);
                    }),
                  ]),
                ],
              ),
            )
          ])
        ],
      )),
    );
  }

  Widget notesInput() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10)),
        height: 200,
        padding: EdgeInsets.all(10),
        child: TextField(
          controller: extraNotes,
          keyboardType: TextInputType.multiline,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
              fontSize: SizeConfig.safeBlockVertical * 3, height: 1.2),
          maxLines: 10,
          decoration: new InputDecoration(
            border: InputBorder.none,
          ),
          onChanged: (val) {},
        ),
      ),
    );
  }

  Widget inputNotesView() {
    return Container(
        padding: EdgeInsets.all(0),
        width: MediaQuery.of(context).size.width,
        child: Card(
          color: StaticColor.lightGrey100,
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

  Widget _extraNotesTitle() {
    return Text(
      Strings.notesAndQty,
      style: TextStyle(
          fontSize: SizeConfig.safeBlockVertical * 3,
          fontWeight: FontWeight.w400,
          color: StaticColor.colorGrey800),
    );
  }

  Widget _totalbutton(String number, Function() f) {
    var size = MediaQuery.of(context).size.width / 2.3;
    double resize = size / 6;
    return Container(
      width: (resize * 4),
      padding: EdgeInsets.all(SizeConfig.safeBlockVertical * 1),
      height: (number == Strings.enter) ? (resize * 2) : resize,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.grey)),
        child: Text(number,
            textAlign: TextAlign.center, style: Styles.whiteMediumBold()),
        textColor: Colors.black,
        color: Colors.blue[900],
        onPressed: f,
      ),
    );
  }
}
