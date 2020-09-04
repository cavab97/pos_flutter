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
        body: Center(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0), color: Colors.white),
          width: MediaQuery.of(context).size.width / 1.2,
          height: MediaQuery.of(context).size.height / 1.2,
          child: Row(
            children: <Widget>[
              Expanded(flex: 1, child: getImages()),
              Expanded(flex: 2, child: getNumbers())
            ],
          ),
        )
      ],
    )));
  }
}

Widget getImages() {
  return Container(
      child: Stack(
    children: [
      Align(
        child: new Image.network(
          "https://repository-images.githubusercontent.com/205373971/def40d80-cb4c-11e9-971a-7434089990ed",
          fit: BoxFit.fill,
        ),
      ),
      Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: 100.0,
          child: Image.asset(
            "assets/headerlogo.png",
            fit: BoxFit.contain,
          ),
        ),
      ),
    ],
  ));
}

Widget getNumbers() {
  return Container(
      child: Column(
    children: [
      Expanded(
          flex: 1,
          child: Text(
            "Pin Number",
            style: TextStyle(fontSize: 25),
          )),
      Expanded(
          flex: 6,
          child: GridView.count(
            crossAxisCount: 3,
            children: <Widget>[
              Container(

              margin: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.black12),
                child: Center(
                  child: Text(
                    "1",
                    style: TextStyle(fontSize: 50.0),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.black12),
                child: Center(
                  child: Text(
                    "2",
                    style: TextStyle(fontSize: 50.0),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.black12),
                child: Center(
                  child: Text(
                    "3",
                    style: TextStyle(fontSize: 50.0),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.black12),
                child: Center(
                  child: Text(
                    "4",
                    style: TextStyle(fontSize: 50.0),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.black12),
                child: Center(
                  child: Text(
                    "5",
                    style: TextStyle(fontSize: 50.0),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.black12),
                child: Center(
                  child: Text(
                    "6",
                    style: TextStyle(fontSize: 50.0),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.black12),
                child: Center(
                  child: Text(
                    "7",
                    style: TextStyle(fontSize: 50.0),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.black12),
                child: Center(
                  child: Text(
                    "8",
                    style: TextStyle(fontSize: 50.0),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.black12),
                child: Center(
                  child: Text(
                    "9",
                    style: TextStyle(fontSize: 50.0),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.black12),
                child: Center(
                  child: Text(
                    "1",
                    style: TextStyle(fontSize: 50.0),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.black12),
                child: Center(
                  child: Text(
                    "0",
                    style: TextStyle(fontSize: 50.0),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.black12),
                child: Center(
                  child: Text(
                    "1",
                    style: TextStyle(fontSize: 50.0),
                  ),
                ),
              ),
            ],
          )),
    ],
  ));
}
