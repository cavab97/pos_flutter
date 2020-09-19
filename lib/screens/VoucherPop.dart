import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/Category.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/Product.dart';
import 'package:mcncashier/models/Product_Categroy.dart';
import 'package:mcncashier/models/Voucher.dart';
import 'package:mcncashier/services/LocalAPIs.dart';

class VoucherPop extends StatefulWidget {
  // Opning ammount popup
  VoucherPop({Key key, this.cartList, this.subTotal, this.onEnter})
      : super(key: key);
  Function onEnter;
  double subTotal;
  List<MSTCartdetails> cartList;
  @override
  VoucherPopState createState() => VoucherPopState();
}

class VoucherPopState extends State<VoucherPop> {
  TextEditingController codeConteroller = new TextEditingController();
  LocalAPI localAPI = LocalAPI();
  bool isLoading = false;
  var productIDs = '';
  List<ProductCategory> productcateIDS = [];
  var errorMSG = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saprateProductid();
  }

  saprateProductid() async {
    var productid;
    for (var i = 0; i < widget.cartList.length; i++) {
      var item = widget.cartList[i];
      if (productid == null) {
        productid = item.productId.toString();
      } else {
        productid += "," + item.productId.toString();
      }
    }
    setState(() {
      productIDs = productid;
    });
    // List<ProductCategory> getproductCat =
    //     await localAPI.getProductCategory(productIDs);
    // setState(() {
    //   productcateIDS = getproductCat.length > 0 ? getproductCat : [];
    // });
  }

  validateCode() async {
    Voucher selectedvoucher;
    if (codeConteroller.text.length != 0) {
      var customerData =
          await Preferences.getStringValuesSF(Constant.CUSTOMER_DATA);
      List<Voucher> vaocher =
          await localAPI.checkVoucherIsExit(codeConteroller.text);
      if (vaocher.length > 0) {
        // check min val
        if (vaocher[0].minimumAmount < widget.subTotal) {
          //check product
          for (int i = 0; i < widget.cartList.length; i++) {
            var cartitem = widget.cartList[i];
            // product
            vaocher[0].voucherProducts.split(',').forEach((tag) {
              if (cartitem.productId.toString() == tag) {
                widget.cartList[i].discount = vaocher[0].voucherDiscount;
                widget.cartList[i].discountType =
                    vaocher[0].voucherDiscountType;
              }
            });
            List<ProductCategory> produt_category =
                await localAPI.getProductCategory(cartitem.productId);
            vaocher[0].voucherCategories.split(',').forEach((tag) {
              for (int j = 0; j < produt_category.length; j++) {
                ProductCategory cat = produt_category[j];
                if (cat.categoryId.toString() == tag) {
                  widget.cartList[i].discount = vaocher[0].voucherDiscount;
                  widget.cartList[i].discountType =
                      vaocher[0].voucherDiscountType;
                }
              }
            });
            if (widget.cartList[i].discount != null &&
                widget.cartList[i].discount != 0.0) {
              var result = await localAPI.updateVoucher(
                  widget.cartList[i], vaocher[0].voucherId);
              selectedvoucher = vaocher[0];
            }
          }
          widget.onEnter(selectedvoucher);
          Navigator.of(context).pop();
        } else {
          CommunFun.showToast(
              context,
              "Required minimum cart amount " +
                  vaocher[0].minimumAmount.toString() +
                  " for this voucher.");
        }
      } else {
        setState(() {
          errorMSG = "Invalid code entered.";
        });
      }
    } else {
      setState(() {
        errorMSG = "code must be required.";
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
              padding:
                  EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
              height: 70,
              color: Colors.black,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Apply Coupon/Voucher", style: Styles.whiteBold()),
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
            child: Text("Cancel", style: Styles.orangeSmall()),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text("Apply", style: Styles.orangeSmall()),
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
            child: Icon(
              Icons.clear,
              color: Colors.white,
              size: 30,
            ),
          ),
        ));
  }

  Widget mainContent() {
    return SingleChildScrollView(
        child: Container(
            width: MediaQuery.of(context).size.width / 2.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Voucher code :", style: Styles.communBlack()),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: codeConteroller,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    errorStyle: TextStyle(color: Colors.red, fontSize: 20),
                    errorText: errorMSG != "" ? errorMSG : "",
                    hintText: "Enter code",
                    hintStyle: TextStyle(fontSize: 25.0, color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(width: 3, color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(width: 3, color: Colors.grey),
                    ),
                    filled: true,
                    contentPadding:
                        EdgeInsets.only(left: 20, top: 25, bottom: 25),
                    fillColor: Colors.white,
                  ),
                  style: TextStyle(color: Colors.black, fontSize: 25.0),
                  onChanged: (e) {
                    print(e);
                    setState(() {
                      errorMSG = "";
                    });
                  },
                )
              ],
            )));
  }
}
