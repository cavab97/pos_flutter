import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/theme/Sized_Config.dart';

class SplitBillDialog extends StatefulWidget {
  SplitBillDialog({Key key, this.onClose, this.cartList}) : super(key: key);
  Function onClose;
  List<MSTCartdetails> cartList;

  @override
  _SplitBillDialog createState() => _SplitBillDialog();
}

class _SplitBillDialog extends State<SplitBillDialog> {
  GlobalKey<ScaffoldState> scaffoldKey;
  LocalAPI localAPI = LocalAPI();
  int selectedIndex = -1;
  List<MSTCartdetails> tempCart = new List<MSTCartdetails>();
  double subTotal = 00.00;
  double tax = 00.00;
  double grandTotal = 00.00;

  @override
  void initState() {
    super.initState();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      title: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
            height: SizeConfig.safeBlockVertical * 9,
            color: Colors.black,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Walk-in customer", style: Styles.whiteBoldsmall()),
              ],
            ),
          ),
          Positioned(
            left: 18,
            top: 18,
            child: GestureDetector(
              onTap: () {
                //addCustomer();
              },
              child: Text(
                Strings.pay.toUpperCase(),
                style: Styles.whiteSimpleSmall(),
              ),
            ),
          ),
          closeButton(context),
        ],
      ),
      content: mainContent(),
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

  setTotalSubTotal() {
    subTotal = 00.00;
    tax = 00.00;
    grandTotal = 00.00;

    tempCart.forEach((element) {
      subTotal = subTotal + element.productPrice;
      tax = tax + element.taxValue;
    });
    setState(() {
      subTotal = subTotal;
      tax = tax;
      grandTotal = subTotal + tax;
    });
  }

  Widget mainContent() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.5,
      height: MediaQuery.of(context).size.height / 1.5,
      child: Container(
        padding: EdgeInsets.all(0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Stack(children: <Widget>[
          productList(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.only(right: 0),
              child: Column(children: <Widget>[
                Divider(),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: 0,
                      ),
                      child: Text(
                        "Sub Total".toUpperCase(),
                        style: Styles.darkGray(),
                      ),
                    ),
                    SizedBox(width: 70),
                    Padding(
                        padding: EdgeInsets.only(
                          top: 0,
                        ),
                        child: Text(
                          subTotal.toStringAsFixed(2),
                          style: Styles.blackMediumbold(),
                        )),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: 0,
                      ),
                      child: Text(
                        "Tax".toUpperCase(),
                        style: Styles.darkGray(),
                      ),
                    ),
                    SizedBox(width: 70),
                    Padding(
                        padding: EdgeInsets.only(
                          top: 0,
                        ),
                        child: Text(
                          tax.toStringAsFixed(2),
                          style: Styles.blackMediumbold(),
                        )),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: 0,
                      ),
                      child: Text(
                        "Grand Total".toUpperCase(),
                        style: Styles.darkGray(),
                      ),
                    ),
                    SizedBox(width: 70),
                    Padding(
                        padding: EdgeInsets.only(
                          top: 0,
                        ),
                        child: Text(
                          grandTotal.toStringAsFixed(2),
                          style: Styles.blackMediumbold(),
                        )),
                  ],
                )
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget productList() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      //height: MediaQuery.of(context).size.height / 3.5,
      //width: MediaQuery.of(context).size.width / 1.7,
      child: SingleChildScrollView(
        child: Column(
            children: widget.cartList.map((product) {
          var index = widget.cartList.indexOf(product);
          var item = widget.cartList[index];
          //  var producrdata = json.decode(item.product_detail);
          // var image_Arr =
          //     producrdata["base64"].replaceAll("data:image/jpg;base64,", '');
          return InkWell(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Hero(
                        tag: product.productId,
                        child: GestureDetector(
                          // This does not give the tap position ...
                          onLongPress: () {},
                          onTap: () {
                            var contain = tempCart
                                .where((element) => element.id == product.id);

                            if (contain.isNotEmpty) {
                              setState(() {
                                tempCart.remove(product);
                              });
                            } else if (contain.isEmpty) {
                              setState(() {
                                tempCart.add(product);
                              });
                            }
                            setTotalSubTotal();
                          },
                          child: new Stack(
                            children: [
                              Container(
                                height: SizeConfig.safeBlockVertical * 8,
                                width: SizeConfig.safeBlockVertical * 9,
                                child:
                                    /* producrdata["base64"] != ""
                                ? CommonUtils.imageFromBase64String(
                                producrdata["base64"])
                                : */
                                    new Image.asset(
                                  Strings.no_imageAsset,
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                ),
                              ),
                              tempCart
                                      .where(
                                          (element) => element.id == product.id)
                                      .isNotEmpty
                                  ? Container(
                                      height: SizeConfig.safeBlockVertical * 8,
                                      width: SizeConfig.safeBlockVertical * 9,
                                      color: Colors.black12)
                                  : SizedBox()
                            ],
                          ),
                        )),
                    SizedBox(width: 15),
                    Flexible(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(product.productName.toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: Styles.smallBlack())
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(product.productQty.toString(),
                              style: Styles.smallBlack()),
                          SizedBox(width: 90),
                          Text(product.productPrice.toStringAsFixed(2),
                              style: Styles.smallBlack()),
                        ],
                      ),
                    )
                  ],
                ),
              ));
        }).toList()),
      ),
    );
  }
}
