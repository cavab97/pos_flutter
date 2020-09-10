import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/routes.dart';
import 'package:mcncashier/theme/theme.dart';

import 'components/constant.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // main Product list page
  MyApp({Key key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  var intitialRoute;
  DatabaseHelper databaseHelper = DatabaseHelper();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkisLogin();
  }

  checkisLogin() async {
    var loginUser = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
    await databaseHelper.initializeDatabase();
    if (loginUser != null) {
      setState(() {
        intitialRoute = loginUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'cashierApp',
      theme: appTheme(),
      initialRoute: intitialRoute != null
          ? Constant.DashboardScreen
          : Constant.TerminalScreen,
      // terkey == null ? Constant.TerminalScreen : Constant.DashboardScreen,
      routes: routes,
    );
  }
}
