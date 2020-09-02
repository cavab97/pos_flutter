import 'package:flutter/material.dart';

class PINPage extends StatefulWidget {
  PINPage({Key key}) : super(key: key);

  @override
  _PINPageState createState() => _PINPageState();
}

class _PINPageState extends State<PINPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        // color: Colors.grey.withOpacity(0.5),
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/bg.jpg"), fit: BoxFit.cover),
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Colors.white),
                width: MediaQuery.of(context).size.width / 1.2,
                height: MediaQuery.of(context).size.height / 1.2,
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[imageview(context), getNumbers(context)],
                ),
              ),
              Positioned(
                top: 100,
                right: 100,
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget imageview(context) {
  return Container(
      width: MediaQuery.of(context).size.width / 2.9,
      //constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30), topLeft: Radius.circular(30)),
          image: DecorationImage(
              image: AssetImage("assets/bg.jpg"), fit: BoxFit.cover)),
      child: Center(
        child: Text(
          '',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.brown, fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ));
}

Widget _button(String number, Function() f) {
  // Creating a method of return type Widget with number and function f as a parameter
  return Padding(
    padding: EdgeInsets.all(5),
    child: MaterialButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(color: Colors.grey)),
      height: 90.0,
      child: Text(number,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0)),
      textColor: Colors.black,
      color: Colors.grey[100],
      onPressed: f,
    ),
  );
}

Widget getNumbers(context) {
  return Center(
    child: Container(
      width: MediaQuery.of(context).size.width / 2.8,
      margin: EdgeInsets.only(left: 70),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  "PIN Number",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                )
              ]),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.check_circle,
                color: Colors.deepOrange,
                size: 40,
              ),
              Icon(
                Icons.check_circle,
                color: Colors.deepOrange,
                size: 40,
              ),
              Icon(
                Icons.check_circle,
                color: Colors.deepOrange,
                size: 40,
              ),
              Icon(
                Icons.check_circle,
                color: Colors.deepOrange,
                size: 40,
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _button("1", () {}), // using custom widget _button
              _button("2", () {}),
              _button("3", () {}),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _button("1", () {}), // using custom widget _button
              _button("2", () {}),
              _button("3", () {}),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _button("1", () {}), // using custom widget _button
              _button("2", () {}),
              _button("3", () {}),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _button("Clock\nIN", () {
                Navigator.pushNamed(context, '/Dashboard');
              }),
              _button("0", () {}),
              _button("Clock\nOUT", () {}),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text("Clear",
                    style: TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 30,
                        fontWeight: FontWeight.w600))
              ])
        ],
      ),
    ),
  );
}
