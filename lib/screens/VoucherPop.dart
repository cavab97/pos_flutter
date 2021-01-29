import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/BranchTax.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/Product_Categroy.dart';
import 'package:mcncashier/models/Voucher.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:intl/intl.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:mcncashier/components/colors.dart';
import 'package:mcncashier/services/allTablesSync.dart';
import 'package:mcncashier/widget/CloseButtonWidget.dart';

class VoucherPop extends StatefulWidget {
  // Opning ammount popup
  VoucherPop({
    Key key,
    this.cartList,
    this.cartData,
    this.cartId,
    this.taxlist,
    this.onEnter,
    this.onClose,
  }) : super(key: key);
  final cartId;
  final Function onClose;
  Function onEnter;
  MST_Cart cartData;
  List<MSTCartdetails> cartList;
  final List<BranchTax> taxlist;

  @override
  VoucherPopState createState() => VoucherPopState();
}

class VoucherPopState extends State<VoucherPop> {
  TextEditingController codeConteroller = new TextEditingController();
  FocusNode fcNode = new FocusNode();
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
    codeConteroller.clear();

    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    if (fcNode != null) fcNode.dispose();
    super.dispose();
  }

  checkMinMaxValue(voucher) async {
    // Check in minimum  max value with cart value
    bool isReturn = false;
    if (voucher.voucherDiscount < cartData.sub_total) {
      if (voucher.minimumAmount == 0.0 ||
          voucher.minimumAmount <= cartData.sub_total) {
        isReturn = true;
      } else {
        isReturn = false;
        CommunFun.showToast(
            context,
            "Required minimum cart amount " +
                voucher.minimumAmount.toString() +
                " for this voucher.");
      }
      if (voucher.maximumAmount == 0.0 ||
          voucher.maximumAmount >= cartData.sub_total) {
        isReturn = true;
      } else {
        isReturn = false;
        CommunFun.showToast(
            context,
            "Required maximum cart amount " +
                voucher.maximumAmount.toString() +
                " for this voucher.");
      }
    } else {
      isReturn = false;
      CommunFun.showToast(
          context,
          "Required cart amount more than discount ammount " +
              voucher.voucherDiscount.toString() +
              ".");
    }
    return isReturn;
  }

  checkisExpired(voucher) {
    DateTime fromDate = DateTime.parse(voucher.voucherApplicableFrom);
    DateTime toDate = DateTime.parse(voucher.voucherApplicableTo);
    DateTime now = new DateTime.now();
    String nowDate = DateFormat('yyyy-MM-dd').format(now);
    String fromtonow = DateFormat('yyyy-MM-dd').format(toDate);
    if (now.isBefore(toDate) && now.isAfter(fromDate) || nowDate == fromtonow) {
      return true;
    } else {
      return false;
    }
  }

  checkitsUsableorNot(voucher) async {
    var count = await localAPI.getVoucherusecount(voucher.voucherId);
    return count;
  }

  checkValidVoucher(Voucher voucher) async {
    Voucher selectedvoucher;
    var chheckIsExpired = await checkisExpired(voucher);
    if (chheckIsExpired == true) {
      var isminmaxValid = await checkMinMaxValue(voucher);
      if (isminmaxValid == true) {
        var count = await checkitsUsableorNot(voucher);
        if (voucher.usesTotal == 0 || count < voucher.usesTotal) {
          //check product
          bool isadded = false;
          double totaldiscount = 0.00;
          double currentSubtotal = 0.00;
          for (int i = 0;
              i < widget.cartList.length && voucher.voucherDiscountType == 1;
              i++) {
            MSTCartdetails cartitem = widget.cartList[i];

            //reverse discount item
            /* if (cartitem.discountAmount > 0) {
              if (cartitem.discountType == 1) {
                cartitem.productDetailAmount = cartitem.productDetailAmount /
                    (1 - (cartitem.discountAmount / 100));
              } else {
                cartitem.productDetailAmount =
                    cartitem.discountAmount + cartitem.productDetailAmount;
              }
            } */
            // product
            if (voucher.voucherProducts != "") {
              voucher.voucherProducts.split(',').forEach((tag) {
                if (cartitem.productId.toString() == tag) {
                  cartitem.discountAmount = voucher.voucherDiscount;
                  cartitem.discountType = voucher.voucherDiscountType;
                  cartitem.discountRemark = voucher.voucherName;
                }
              });
            }
            // categorys
            if (voucher.voucherCategories != "") {
              List<ProductCategory> produtCategory =
                  await localAPI.getProductCategory(cartitem.productId);
              voucher.voucherCategories.split(',').forEach((tag) {
                for (int j = 0; j < produtCategory.length; j++) {
                  ProductCategory cat = produtCategory[j];
                  if (cat.categoryId.toString() == tag) {
                    cartitem.discountAmount = voucher.voucherDiscount;
                    cartitem.discountType = voucher.voucherDiscountType;
                    cartitem.discountRemark = voucher.voucherName;
                  }
                }
              });
            }
            if (cartitem.discountAmount != null &&
                cartitem.discountAmount != 0.0) {
              double discountAmount =
                  cartitem.productPrice * (cartitem.discountAmount / 100);
              totaldiscount += discountAmount;

              await localAPI.addVoucherIndetail(
                cartitem,
                voucher.voucherId,
              );
            }
          }
          cartData.discountType = voucher.voucherDiscountType;
          cartData.discountRemark = voucher.voucherName;
          cartData.voucher_detail = json.encode(voucher);
          cartData.voucher_id = voucher.voucherId;
          double itemDiscount = 0.00;
          widget.cartList.forEach((cartdetail) {
            if (cartdetail.isFocProduct != 1) {
              currentSubtotal += cartdetail.productDetailAmount != null &&
                      cartdetail.productDetailAmount != 0.00
                  ? cartdetail.productDetailAmount
                  : cartdetail.productPrice;
              if (cartData.voucher_id != null) {
                if (cartData.voucher_id > 0 && cartdetail.discountType == 1) {
                  double originalPrice = cartdetail.productDetailAmount;
                  // (1 - (cartdetail.discountAmount / 100));
                  itemDiscount +=
                      originalPrice * (cartdetail.discountAmount / 100);
                } else if (cartData.voucher_id > 0) {
                  itemDiscount += cartdetail.discountAmount;
                }
              }
            }
          });
          cartData.serviceCharge = 0.00;
          if (cartData.serviceChargePercent != null) {
            cartData.serviceCharge =
                currentSubtotal * (cartData.serviceChargePercent / 100);
          }
          double taxval = 0.00;
          for (BranchTax tax in widget.taxlist) {
            taxval += tax.rate != null
                ? currentSubtotal * (double.tryParse(tax.rate) / 100)
                : 0.00;
          }
          cartData.tax = taxval;
          //cartData.discountAmount = totaldiscount;
          cartData.grand_total = (currentSubtotal - itemDiscount) +
              cartData.tax +
              cartData.serviceCharge;
          selectedvoucher = voucher;
          isadded = true;
          selectedvoucher = voucher;
          if (widget.onEnter != null) {
            widget.onEnter(selectedvoucher);
          }
          if (widget.onClose != null) {
            widget.onClose(cartData);
          }
          SyncAPICalls.logActivity(
              "add promocode",
              "Cashier Removed promocode form order",
              "voucher",
              voucher.voucherId);
          Navigator.of(context).pop(); // close Pop
        } else {
          await CommunFun.showToast(
              context,
              "Voucher already used " +
                  voucher.usesTotal.toString() +
                  " times.");
          SyncAPICalls.logActivity(
              "Voucher", "cashier choosed voucher already used", "Voucher", 1);
        }
      }
    } else {
      await CommunFun.showToast(context, Strings.voucherExpired);
      await SyncAPICalls.logActivity(
          "voucher", "voucher already expired", "voucher", 1);
    }
  }

  validateCode() async {
    if (codeConteroller.text.length != 0) {
      List<Voucher> voucher =
          await localAPI.checkVoucherIsExit(codeConteroller.text);
      if (voucher.length > 0) {
        checkValidVoucher(voucher[0]);
      } else {
        fcNode.requestFocus();
        codeConteroller.selection = TextSelection(
            baseOffset: 0, extentOffset: codeConteroller.text.length);
        setState(() {
          errorMSG = Strings.voucherNotExit;
        });
      }
    } else {
      fcNode.requestFocus();
      codeConteroller.selection = TextSelection(
          baseOffset: 0, extentOffset: codeConteroller.text.length);
      setState(() {
        errorMSG = Strings.voucherCodeMsg;
      });
    }
    await SyncAPICalls.logActivity("apply promocode",
        "Opened voucher popup for apply voucher", "voucher", 1);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: EdgeInsets.only(left: 30, right: 10, top: 10, bottom: 10),
          height: SizeConfig.safeBlockVertical * 9,
          color: StaticColor.colorBlack,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                Strings.applycoupen,
                style: TextStyle(
                    fontSize: SizeConfig.safeBlockVertical * 3,
                    color: StaticColor.colorWhite),
              ),
              Spacer(),
              CloseButtonWidget(
                inputContext: context,
                callback: widget.onClose,
              ),
            ],
          ),
        ), //popup close btn

        content: mainContent(),
        actions: <Widget>[
          isLoading ? CommunFun.loader(context) : SizedBox(),
          FlatButton(
            child: Text(Strings.cancel, style: Styles.orangeSmall()),
            onPressed: () {
              widget.onClose();
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
              color: StaticColor.colorRed,
              borderRadius: BorderRadius.circular(30.0)),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.clear,
              color: StaticColor.colorWhite,
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
              focusNode: fcNode,
              autofocus: true,
              controller: codeConteroller,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                errorStyle: TextStyle(
                    color: StaticColor.colorRed,
                    fontSize: SizeConfig.safeBlockVertical * 3),
                errorText: errorMSG != "" ? errorMSG : "",
                hintText: Strings.enterCode,
                hintStyle: TextStyle(
                    fontSize: SizeConfig.safeBlockVertical * 2,
                    color: StaticColor.colorBlack),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(width: 3, color: StaticColor.colorGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(width: 3, color: StaticColor.colorRed),
                ),
                filled: true,
                contentPadding: EdgeInsets.all(15),
                fillColor: StaticColor.colorWhite,
              ),
              style: Styles.greysmall(),
              onChanged: (e) {
                setState(() {
                  errorMSG = "";
                });
              },
              onSubmitted: (String text) async {
                await validateCode();
              },
            )
          ],
        ),
      ),
    );
  }
}
