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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      titlePadding: EdgeInsets.all(20),
      title: Center(child: Text("Enter Qty")),
      content: Container(
        width: MediaQuery.of(context).size.width / 3,
        height: MediaQuery.of(context).size.height / 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Select qty for free product :",
              style: Styles.greysmall(),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
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
        ),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cancel", style: Styles.orangeSmall()),
        ),
        FlatButton(
          onPressed: () {
            widget.onClose(productQty);
          },
          child: Text("Done", style: Styles.orangeSmall()),
        )
      ],
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
