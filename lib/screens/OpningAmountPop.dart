import 'package:flutter/material.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';

class OpeningAmmountPage extends StatefulWidget {
  OpeningAmmountPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _OpeningAmmountPageState createState() => _OpeningAmmountPageState();
}

class _OpeningAmmountPageState extends State<OpeningAmmountPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Optinign ammount page"),
      ),
      body: Center(),
    );
  }
}
