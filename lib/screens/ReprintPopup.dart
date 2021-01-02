import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/services/allTablesSync.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:mcncashier/components/colors.dart';
import 'package:mcncashier/widget/CloseButtonWidget.dart';

class ReprintKitchenPirntPop extends StatefulWidget {
  // quantity Dailog
  ReprintKitchenPirntPop({Key key, this.cartList, this.onClose})
      : super(key: key);

  final cartList;
  Function onClose;

  @override
  _ReprintKitchenPirntPopState createState() => _ReprintKitchenPirntPopState();
}

class _ReprintKitchenPirntPopState extends State<ReprintKitchenPirntPop> {
  List<MSTCartdetails> cartList = new List<MSTCartdetails>();
  List<MSTCartdetails> tempCart = new List<MSTCartdetails>();
  @override
  void initState() {
    super.initState();
    setState(() {
      cartList = widget.cartList;
    });
  }

  _setSelectUnselect(MSTCartdetails product) {
    var contain = tempCart.where((element) => element.id == product.id);
    if (contain.isNotEmpty) {
      tempCart.remove(product);
    } else if (contain.isEmpty) {
      tempCart.add(product);
    }
    setState(() {
      tempCart = tempCart;
    });
  }

  Widget print(context) {
    return RaisedButton(
      onPressed: tempCart.length < 1
          ? null
          : () async {
              await SyncAPICalls.logActivity(
                  "Reprint kitchen",
                  "Print Reprint kitchen reciept for selected items",
                  "Reprint kitchen",
                  1);
              widget.onClose(tempCart);
            },
      child: Text(Strings.reprint + " " + Strings.selectedItem,
          style: TextStyle(
            color: StaticColor.colorWhite,
            fontSize: SizeConfig.safeBlockVertical * 3,
          )),
      color: StaticColor.deepOrange,
      textColor: StaticColor.colorWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
    );
  }

  Widget printAll(context) {
    return RaisedButton(
      onPressed: () async {
        await SyncAPICalls.logActivity("Reprint kitchen",
            "Selected all items for reprint reciept", "Reprint kitchen", 1);
        widget.onClose(cartList);
      },
      child: Text(Strings.reprintAll,
          style: TextStyle(
            color: StaticColor.colorWhite,
            fontSize: SizeConfig.safeBlockVertical * 3,
          )),
      color: StaticColor.deepOrange,
      textColor: StaticColor.colorWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
    );
  }

  Widget productList() {
    return Column(
      children: [
        Container(
          height: (MediaQuery.of(context).size.height / 1.8 * 0.9),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: 200),
            child: Column(
              children: cartList.map((product) {
                return InkWell(
                  onTap: () {
                    _setSelectUnselect(product);
                  },
                  child: Container(
                    color: tempCart
                            .where((element) => element.id == product.id)
                            .isNotEmpty
                        ? Colors.grey[300]
                        : StaticColor.colorWhite,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              IconButton(
                                  icon: Icon(Icons.add_circle_outline),
                                  onPressed: tempCart
                                          .where((element) =>
                                              element.id == product.id)
                                          .isNotEmpty
                                      ? () {}
                                      : null),
                              Text(product.productName.toString().toUpperCase(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.start,
                                  style: Styles.smallBlack()),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              IconButton(
                                  icon: Icon(
                                    Icons.remove_circle,
                                    color: StaticColor.deepOrange,
                                  ),
                                  onPressed: null),
                              Text(
                                product.productQty.toString(),
                                style: Styles.smallBlack(),
                              ),
                              IconButton(
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: StaticColor.deepOrange,
                                  ),
                                  onPressed: null),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Container(
          height: (MediaQuery.of(context).size.height / 1.8 * 0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              printAll(context),
              SizedBox(width: 15),
              print(context)
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(5),
      titlePadding: EdgeInsets.all(0),
      title: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 30, right: 10, top: 10, bottom: 10),
            height: SizeConfig.safeBlockVertical * 9,
            color: StaticColor.colorBlack,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  Strings.rePrintKitchenPrint,
                  style: TextStyle(
                      fontSize: SizeConfig.safeBlockVertical * 3,
                      color: StaticColor.colorWhite),
                ),
                Spacer(),
                CloseButtonWidget(inputContext: context),
              ],
            ),
          ), // close button
        ],
      ),
      content: Container(
        width: MediaQuery.of(context).size.width / 2,
        height: MediaQuery.of(context).size.height / 1.8,
        child: productList(),
      ),
    );
  }
}
