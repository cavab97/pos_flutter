import 'package:flutter/material.dart';
import 'package:mcncashier/components/communText.dart';
//import 'package:flutter_lock_screen/flutter_lock_screen.dart';
import 'package:mcncashier/screens/Home.dart';

class PINPage extends StatefulWidget {
  PINPage({Key key}) : super(key: key);
  @override
  _PINPageState createState() => _PINPageState();
}

class _PINPageState extends State<PINPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var myPass = [1, 2, 3, 4];
    return Scaffold(
        body: Center(
            child: Container(
                width: MediaQuery.of(context).size.width / 1.5,
                height: MediaQuery.of(context).size.height,
                child: Text("test"))));
  }
}
