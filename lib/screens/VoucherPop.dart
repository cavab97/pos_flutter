import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/Product_Categroy.dart';
import 'package:mcncashier/models/Voucher.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:intl/intl.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import '../components/communText.dart';
import '../components/communText.dart';

class VoucherPop extends StatefulWidget {
  // Opning ammount popup
  VoucherPop({Key key, this.cartList, this.cartData, this.cartId, this.onEnter})
      : super(key: key);
  final cartId;
  Function onEnter;
  MST_Cart cartData;
  List<MSTCartdetails> cartList;

  @override
  VoucherPopState createState() => VoucherPopState();
}

class VoucherPopState extends State<VoucherPop> {
  TextEditingController codeConteroller = new TextEditingController();
  LocalAPI localAPI = LocalAPI();
  bool isLoading = false;
  var productIDs = '';
  MST_Cart cartData;
  List<ProductCategory> productcateIDS = [];
  var errorMSG = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      cartData = widget.cartData;
    });
    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
  }

  checkMinMaxValue(vaocher) async {
    // Check in minimum  max value with cart value
   bool isReturn = false;
    if (vaocher.voucherDiscount < cartData.sub_total) {
      if (vaocher.minimumAmount == 0.0 ||
          vaocher.minimumAmount <= cartData.sub_total) {
        isReturn = true;
      } else {
        isReturn = false;
        CommunFun.showToast(
            context,
            "Required minimum cart amount " +
                vaocher.minimumAmount.toString() +
                " for this voucher.");
      }

      if (vaocher.maximumAmount == 0.0 ||
          vaocher.maximumAmount >= cartData.sub_total) {
        isReturn = true;
      } else {
        isReturn = false;
        CommunFun.showToast(
            context,
            "Required maximum cart amount " +
                vaocher.maximumAmount.toString() +
                " for this voucher.");
      }
    } else {
      isReturn = false;
      CommunFun.showToast(
          context,
          "Required cart amount more than discount ammount " +
              vaocher.voucherDiscount.toString() +
              ".");
    }
    return isReturn;
  }

  checkisExpired(vaocher) {
    DateTime fromDate = DateTime.parse(vaocher.voucherApplicableFrom);
    DateTime toDate = DateTime.parse(vaocher.voucherApplicableTo);
    DateTime now = new DateTime.now();
    String nowDate = DateFormat('yyyy-MM-dd').format(now);
    String fromtonow = DateFormat('yyyy-MM-dd').format(toDate);

    if (now.isBefore(toDate) && now.isAfter(fromDate) || nowDate == fromtonow) {
      return true;
    } else {
      return false;
    }
  }

  // checkitsUsableorNot(vaocher) async {
  //   var count = await localAPI.getVoucherusecount(vaocher.voucherId);
  //   return count;
  // }

  checkValidVoucher(vaocher) async {
    Voucher selectedvoucher;
    var chheckIsExpired = await checkisExpired(vaocher);
    if (chheckIsExpired == true) {
      var isminmaxValid = await checkMinMaxValue(vaocher);
      if (isminmaxValid == true) {
        //var count = await checkitsUsableorNot(vaocher);
        if (vaocher.usesTotal == 0 || vaocher.totalUsed < vaocher.usesTotal) {
          //check product
          bool isadded = false;
          double totaldiscount = 0;
          List<MSTCartdetails> cartitemList = [];
          for (int i = 0; i < widget.cartList.length; i++) {
            var cartitem = widget.cartList[i];
            // product
            if (vaocher.voucherProducts != "") {
              vaocher.voucherProducts.split(',').forEach((tag) {
                if (cartitem.productId.toString() == tag) {
                  if (vaocher.voucherDiscountType == 1) {
                    cartitem.discount = vaocher.voucherDiscount;
                    cartitem.discountType = vaocher.voucherDiscountType;
                  } else {
                    cartitem.discount =
                        (cartitem.productPrice * vaocher.voucherDiscount) / 100;
                    cartitem.discountType = vaocher.voucherDiscountType;
                  }
                }
              });
            }
            // categorys
            if (vaocher.voucherCategories != "") {
              List<ProductCategory> produtCategory =
                  await cartapi.getProductCategory(cartitem.productId);
              vaocher.voucherCategories.split(',').forEach((tag) {
                for (int j = 0; j < produtCategory.length; j++) {
                  ProductCategory cat = produtCategory[j];
                  if (cat.categoryId.toString() == tag) {
                    cartitem.discount = vaocher.voucherDiscount;
                    cartitem.discountType = vaocher.voucherDiscountType;
                  }
                }
              });
            }
            if (cartitem.discount != null && cartitem.discount != 0.0) {
              totaldiscount += cartitem.discount;
              // var result = await cartapi.addVoucherIndetail(
              //   cartitem,
              //   vaocher.voucherId,
              // );
              cartitemList.add(cartitem);
            } else {
              totaldiscount = vaocher.voucherDiscount;
            }
          }
          cartData.grand_total = cartData.grand_total + cartData.discount;
          cartData.discount = totaldiscount;
          cartData.discount_type = vaocher.voucherDiscountType;
          cartData.grand_total =
              cartData.grand_total = cartData.grand_total - cartData.discount;
          cartData.voucher_detail = json.encode(vaocher);
          cartData.voucher_id = vaocher.voucherId;
          var result1 = await cartapi.addVoucherInOrder(cartData, cartitemList);
          selectedvoucher = vaocher;
          isadded = true;
          selectedvoucher = vaocher;
          widget.onEnter(selectedvoucher);
          Navigator.of(context).pop(); // close Pop
        } else {
          CommunFun.showToast(
              context,
              "Voucher already used " +
                  vaocher.usesTotal.toString() +
                  " times.");
        }
      }
    } else {
      CommunFun.showToast(context, Strings.voucher_expired);
    }
  }

  validateCode() async {
    if (codeConteroller.text.length != 0) {
      List<Voucher> vaocher =
          await cartapi.checkVoucherIsExit(codeConteroller.text);
      if (vaocher.length > 0) {
        checkValidVoucher(vaocher[0]);
      } else {
        setState(() {
          errorMSG = Strings.voucher_not_exit;
        });
      }
    } else {
      setState(() {
        errorMSG = Strings.voucher_code_msg;
      });
    }
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
              height: SizeConfig.safeBlockVertical * 9,
              color: Colors.black,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(Strings.applycoupen,
                      style: TextStyle(
                          fontSize: SizeConfig.safeBlockVertical * 3,
                          color: Colors.white)),
                ],
              ),
            ),
            closeButton(context), //popup close btn
          ],
        ),
        content: mainContent(),
        actions: <Widget>[
          isLoading ? CommunFun.loader(context) : SizedBox(),
          FlatButton(
            child: Text(Strings.cancel, style: Styles.orangeSmall()),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text(Strings.apply, style: Styles.orangeSmall()),
            onPressed: () {
              validateCode();
            },
          ),
        ] // Popup body contents
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

  Widget mainContent() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        width: MediaQuery.of(context).size.width / 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Strings.vauchercode, style: Styles.blackMediumBold()),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: codeConteroller,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                errorStyle: TextStyle(
                    color: Colors.red,
                    fontSize: SizeConfig.safeBlockVertical * 3),
                errorText: errorMSG != "" ? errorMSG : "",
                hintText: Strings.enter_Code,
                hintStyle: TextStyle(
                    fontSize: SizeConfig.safeBlockVertical * 2,
                    color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(width: 3, color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(width: 3, color: Colors.grey),
                ),
                filled: true,
                contentPadding: EdgeInsets.all(15),
                fillColor: Colors.white,
              ),
              style: Styles.greysmall(),
              onChanged: (e) {
                setState(() {
                  errorMSG = "";
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
