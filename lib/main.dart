import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/routes.dart';
import 'package:mcncashier/theme/theme.dart';

import 'components/constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bool isLogged = await CommunFun.isLogged();
  runApp(MyApp(islogin: isLogged));
}

class MyApp extends StatefulWidget {
  // main Product list page
  MyApp({Key key, this.islogin}) : super(key: key);
  final bool islogin;
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
    databaseHelper.initializeDatabase();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: SplashScreen(),
      title: 'cashierApp',
      theme: appTheme(),
      initialRoute:
          widget.islogin ? Constant.DashboardScreen : Constant.TerminalScreen,
      routes: routes,
    );
  }
}
