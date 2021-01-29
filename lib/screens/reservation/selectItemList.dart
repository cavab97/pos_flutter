import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/models/PorductDetails.dart';

class SelectItemList extends StatefulWidget {
  SelectItemList({Key key, this.onClose}) : super(key: key);
  final Function onClose;
  List<ProductDetails> productList = [];
  @override
  SelectItemListState createState() => SelectItemListState();
}

class SelectItemListState extends State<SelectItemList> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(),
      actionsPadding: EdgeInsets.symmetric(horizontal: 20),
      actions: [
        FlatButton.icon(
          color: Colors.green,
          icon: Icon(Icons.check),
          label: Text(Strings.confirm),
          onPressed: () {
            widget.onClose([]);
            Navigator.of(context).pop();
          },
        ),
        FlatButton.icon(
          color: Colors.red,
          icon: Icon(Icons.close),
          label: Text(Strings.cancel),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
