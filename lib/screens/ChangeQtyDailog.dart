import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/services/allTablesSync.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:mcncashier/components/colors.dart';
import 'package:mcncashier/widget/CloseButtonWidget.dart';

class ChangeQtyDailog extends StatefulWidget {
  ChangeQtyDailog({Key key, this.type, this.qty, this.onClose})
      : super(key: key);
  final qty;
  final type;
  Function onClose;
  @override
  ChangeQtyDailogState createState() => ChangeQtyDailogState();
}

class ChangeQtyDailogState extends State<ChangeQtyDailog> {
  double productQty = 0;
  TextEditingController remarkText = new TextEditingController();
  @override
  void initState() {
    super.initState();
    setState(() {
      productQty = widget.qty;
    });
    qtydailog();
  }

  qtydailog() async {
    await SyncAPICalls.logActivity("foc product",
        "Opened foc product qty popup for make item for free", "cart", 1);
  }

  increaseQty() async {
    if (productQty < widget.qty) {
      productQty = productQty + 1;
      setState(() {
        productQty = productQty;
      });
    }
    await SyncAPICalls.logActivity(
        "cart item", "foc product qty increased", "cart", 1);
  }

  decreaseQty() async {
    if (productQty > 1) {
      productQty = productQty - 1;
      setState(() {
        productQty = productQty;
      });
    }
    await SyncAPICalls.logActivity(
        "cart item", "foc product qty decreased", "cart", 1);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: EdgeInsets.only(left: 30, right: 10, top: 10, bottom: 10),
        height: SizeConfig.safeBlockVertical * 9,
        color: StaticColor.colorBlack,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              Strings.enterQty,
              style: TextStyle(
                  fontSize: SizeConfig.safeBlockVertical * 3,
                  color: StaticColor.colorWhite),
            ),
            CloseButtonWidget(inputContext: context),
          ],
        ),
      ),
      content: Container(
        width: MediaQuery.of(context).size.width / 2,
        height: MediaQuery.of(context).size.height / 4,
        padding: EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                Strings.remark,
                style: Styles.greysmall(),
              ),
              remarkfield(),
              SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width / 2,
          child: Row(
            children: <Widget>[
              Spacer(),
              _button("-", () {
                decreaseQty();
              }),
              _quantityTextInput(),
              _button("+", () {
                increaseQty();
              }),
              Spacer(),
              addbutton(context)
            ],
          ),
        )
      ],
    );
  }

  Widget remarkfield() {
    return Card(
        color: StaticColor.lightGrey100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          child: TextField(
            controller: remarkText,
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
        ));
  }

  Widget addbutton(context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ),
      height: 40,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(Strings.done,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: StaticColor.colorWhite,
                fontWeight: FontWeight.bold,
                fontSize: 25.0)),
      ),
      textColor: StaticColor.colorBlack,
      color: StaticColor.deepOrange,
      onPressed: () {
        widget.onClose(productQty, remarkText.text);
      },
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
                color: StaticColor.colorWhite,
                fontWeight: FontWeight.bold,
                fontSize: 30.0)),
        textColor: StaticColor.colorBlack,
        color: StaticColor.deepOrange,
        onPressed: f,
      ),
    );
  }

  Widget _quantityTextInput() {
    String qtyString = "";
    if (widget.type == null) {
      qtyString = productQty.toInt().toString();
    } else {
      qtyString = productQty.toString();
    }
    return Container(
      height: 40,
      width: 100,
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: StaticColor.colorGrey)),
      child: Center(
          child: Text(
              qtyString + (widget.type != null ? " " + widget.type : ""),
              style: TextStyle(color: StaticColor.colorGrey, fontSize: 20))),
    );
  }
}
