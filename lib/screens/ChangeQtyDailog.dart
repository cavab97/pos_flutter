import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/theme/Sized_Config.dart';

class ChangeQtyDailog extends StatefulWidget {
  ChangeQtyDailog({Key key, this.qty, this.onClose}) : super(key: key);
  final qty;
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
  }

  increaseQty() {
    if (productQty < widget.qty) {
      productQty = productQty + 1;
      setState(() {
        productQty = productQty;
      });
    }
  }

  decreaseQty() {
    if (productQty > 1) {
      productQty = productQty - 1;
      setState(() {
        productQty = productQty;
      });
    }
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
                Text("Enter Qty",
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
                "Remark :",
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
        )
      ],
    );
  }

  Widget remarkfield() {
    return Card(
        color: Colors.grey[200],
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

  Widget addbutton(context) {
    return RaisedButton(
      onPressed: () {
        widget.onClose(productQty, remarkText.text);
      },
      child: Row(
        children: <Widget>[
          Text(
            "Done",
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeConfig.safeBlockVertical * 3,
            ),
          ),
        ],
      ),
      color: Colors.deepOrange,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
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

  Widget _quantityTextInput() {
    return Container(
      height: 40,
      width: 100,
      decoration:
          BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
      child: Center(
          child: Text(productQty.toString(),
              style: TextStyle(color: Colors.grey, fontSize: 20))),
    );
  }
}
