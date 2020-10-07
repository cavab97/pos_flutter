import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/Product_Categroy.dart';
import 'package:mcncashier/models/Voucher.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:intl/intl.dart';

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
    super.initState();
    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
  }

  checkMinMaxValue(vaocher) async {
    // Check in minimum  max value with cart value
    var isReturn;
    if (vaocher.minimumAmount == 0.0 ||
        vaocher.minimumAmount <= widget.subTotal) {
      isReturn = true;
    } else {
      CommunFun.showToast(
          context,
          "Required minimum cart amount " +
              vaocher.minimumAmount.toString() +
              " for this voucher.");
    }

    if (vaocher.maximumAmount == 0.0 ||
        vaocher.maximumAmount >= widget.subTotal) {
      isReturn = true;
    } else {
      CommunFun.showToast(
          context,
          "Required maximum cart amount " +
              vaocher.maximumAmount.toString() +
              " for this voucher.");
    }
    return await isReturn;
  }

  checkisExpired(vaocher) {
    DateTime fromDate = DateTime.parse(vaocher.voucherApplicableFrom);
    DateTime toDate = DateTime.parse(vaocher.voucherApplicableTo);
    DateTime now = new DateTime.now();
    String nowDate = DateFormat('yyyy-MM-dd').format(now);
    String fromtonow = DateFormat('yyyy-MM-dd').format(toDate);
    print(now.isBefore(fromDate));
    print(now.isAfter(toDate));
    if (now.isBefore(toDate) && now.isAfter(fromDate) || nowDate == fromtonow) {
      return true;
    } else {
      return false;
    }
  }

  checkitsUsableorNot(vaocher) async {
    var count = await localAPI.getVoucherusecount(vaocher.voucherId);
    return count;
  }

  checkValidVoucher(vaocher) async {
    Voucher selectedvoucher;
    var chheckIsExpired = await checkisExpired(vaocher);
    if (chheckIsExpired == true) {
      var isminmaxValid = await checkMinMaxValue(vaocher);
      if (isminmaxValid == true) {
        var count = await checkitsUsableorNot(vaocher);
        if (vaocher.usesTotal == 0 || count < vaocher.usesTotal) {
          //check product
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
                  await localAPI.getProductCategory(cartitem.productId);
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
              var result =
                  await localAPI.updateVoucher(cartitem, vaocher.voucherId);
              selectedvoucher = vaocher;
            }
          }
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
          await localAPI.checkVoucherIsExit(codeConteroller.text);
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
              padding:
                  EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
              height: 70,
              color: Colors.black,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(Strings.applycoupen, style: Styles.whiteBoldsmall()),
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
      child: Container(
        width: MediaQuery.of(context).size.width / 2.8,
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
                errorStyle: TextStyle(color: Colors.red, fontSize: 20),
                errorText: errorMSG != "" ? errorMSG : "",
                hintText: Strings.enter_Code,
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
                contentPadding: EdgeInsets.only(left: 20, top: 20, bottom: 20),
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
        ),
      ),
    );
  }
}
