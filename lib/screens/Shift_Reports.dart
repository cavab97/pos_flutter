import 'package:flutter/material.dart';
import 'package:mcncashier/components/styles.dart';

class ShiftReports extends StatefulWidget {
  // PIN Enter PAGE
  ShiftReports({Key key}) : super(key: key);

  @override
  _ShiftReportsState createState() => _ShiftReportsState();
}

class _ShiftReportsState extends State<ShiftReports> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: scaffoldKey,
      appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(
              Icons.arrow_back,
              size: 30.0,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text("Shift Report", style: Styles.whiteBold())),
      body: SingleChildScrollView(
        child: Container(),
      ),
    );
  }
}
