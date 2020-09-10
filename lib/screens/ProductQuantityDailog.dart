import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/models/Attributes.dart';
import 'package:mcncashier/models/Product.dart';
import 'package:mcncashier/models/Product_Attribute.dart';
import 'package:mcncashier/services/LocalAPIs.dart';

class ProductQuantityDailog extends StatefulWidget {
  // quantity Dailog
  ProductQuantityDailog({Key key, this.product}) : super(key: key);
  final product;
  @override
  _ProductQuantityDailogState createState() => _ProductQuantityDailogState();
}

class _ProductQuantityDailogState extends State<ProductQuantityDailog> {
  final List<int> numbers = [1, 2, 3, 5, 8, 13, 21, 34, 55];
  TextEditingController productController = new TextEditingController();
  LocalAPI localAPI = LocalAPI();
  Product productItem;
  int product_qty = 1;
  int price = 0;
  @override
  void initState() {
    super.initState();
    setState(() {
      productItem = widget.product;
      price = productItem.price;
    });
    getAttributes();
    getModifire();
  }

  getAttributes() async {
    List<ProductAttribute> productAttr =
        await localAPI.getPorductAttributes(productItem);
    print(productAttr);
  }

  getModifire() {}
  increaseQty() {
    var prevproductqty = product_qty;
    setState(() {
      product_qty = prevproductqty + 1;
      price = productItem.price * product_qty;
    });
  }

  decreaseQty() {
    if (product_qty != 0) {
      var prevproductqty = product_qty;
      setState(() {
        product_qty = prevproductqty - 1;
        price = productItem.price * product_qty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      title: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
            height: 70,
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(productItem.name,
                    style: TextStyle(fontSize: 25, color: Colors.white)),
                addbutton(context)
              ],
            ),
          ),
          closeButton(context), // close button
        ],
      ),
      content: mainContent(), //main part of the popup
      actions: <Widget>[
        // Button div + - buttons
        Stack(
          children: <Widget>[
            Positioned(
                bottom: 10,
                right: 30,
                child: Text(price.toDouble().toString(),
                    style: TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 30,
                        fontWeight: FontWeight.bold))),
            Container(
              width: MediaQuery.of(context).size.width / 1.4,
              child: Column(children: <Widget>[
                CommunFun.divider(),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      buttonContainer(),
                    ]),
              ]),
            ),
          ],
        )
      ],
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

  Widget buttonContainer() {
    return Container(
      child: Row(
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
    );
  }

  Widget mainContent() {
    return SingleChildScrollView(
        child: Container(
      //  height: MediaQuery.of(context).size.height / 2.4,
      width: MediaQuery.of(context).size.width / 2.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _sizeTitle(),
          getSize(),
          SizedBox(height: 10),
          _extraNotesTitle(),
          SizedBox(height: 10),
          inputNotesView(),
        ],
      ),
    ));
  }

  Widget getSize() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10.0),
      height: 50, // MediaQuery.of(context).size.height /8,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: numbers.length,
          itemBuilder: (context, index) {
            return Container(
              width: 50, //MediaQuery.of(context).size.width * 0.6,
              height: 20,
              child: Card(
                color: Colors.grey[200],
                child: Container(
                  child: Center(
                      child: Text(
                    numbers[index].toString(),
                    style: TextStyle(color: Colors.black, fontSize: 18.0),
                  )),
                ),
              ),
            );
          }),
    );
  }

  Widget _sizeTitle() {
    return Text(
      Strings.size,
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w400, color: Colors.grey[800]),
    );
  }

  Widget _extraNotesTitle() {
    return Text(
      "Notes and Quantity",
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w400, color: Colors.grey[800]),
    );
  }

  Widget inputNotesView() {
    return Container(
        padding: EdgeInsets.all(10),
        //height: 170, // MediaQuery.of(context).size.height / 4,
        width: MediaQuery.of(context).size.width,
        child: Card(
          color: Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[notesInput()],
          ),
        ));
  }

  Widget notesInput() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        child: TextField(
          keyboardType: TextInputType.multiline,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(fontSize: 20, height: 1.4),
          maxLines: 3,
          decoration: new InputDecoration(
            border: InputBorder.none,
            // hintText: product_qty.toDouble().toString(),
          ),
          onChanged: (val) {},
        ),
      ),
    );
  }

  Widget _quantityTextInput() {
    return Container(
      height: 50,
      width: 90,
      decoration:
          BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
      child: Center(
        child: Text(product_qty.toDouble().toString(),
            style: TextStyle(color: Colors.grey, fontSize: 25)),
      ),
    );
  }

  Widget _button(String number, Function() f) {
    // Creating a method of return type Widget with number and function f as a parameter
    return Padding(
      padding: EdgeInsets.all(5),
      child: MaterialButton(
        height: 50,
        child: Text(number,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 40.0)),
        textColor: Colors.black,
        color: Colors.deepOrange,
        onPressed: f,
      ),
    );
  }

  Widget addbutton(context) {
    // Add button header rounded
    return RaisedButton(
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      onPressed: () {},
      child: Row(
        children: <Widget>[
          Icon(
            Icons.add_circle_outline,
            color: Colors.white,
            size: 30,
          ),
          SizedBox(width: 10),
          Text("Add",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              )),
        ],
      ),
      color: Colors.deepOrange,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
    );
  }
}
