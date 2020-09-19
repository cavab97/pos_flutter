import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/styles.dart';

class VoucherApplyconfirmPop extends StatefulWidget {
  // Opning ammount popup
  VoucherApplyconfirmPop({Key key, this.onEnter, this.onCancel})
      : super(key: key);
  Function onEnter;
  Function onCancel;
  @override
  VoucherApplyconfirmPopState createState() => VoucherApplyconfirmPopState();
}

class VoucherApplyconfirmPopState extends State<VoucherApplyconfirmPop> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.all(20),
      title: Text("Alert", style: Styles.blackBoldLarge()),
      content: Text(
        "Are you want apply voucher or Coupen code?",
        style: Styles.blackLarge(),
      ), // Popup body contents
      actions: <Widget>[
        FlatButton(
          child: Text("YES", style: Styles.orangeLarge()),
          onPressed: () {
            Navigator.of(context).pop();
            widget.onEnter();
          },
        ),
        FlatButton(
          child: Text("NO", style: Styles.orangeLarge()),
          onPressed: () {
            Navigator.of(context).pop();
            widget.onCancel();
          },
        ),
      ],
    );
  }
}
