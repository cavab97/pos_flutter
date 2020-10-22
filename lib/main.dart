import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/routes.dart';
import 'package:mcncashier/screens/SplashScreen.dart';
import 'package:mcncashier/theme/theme.dart';

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
  var intitialRoute;
  DatabaseHelper databaseHelper = DatabaseHelper();
  @override
  void initState() {
    super.initState();
    databaseHelper.initializeDatabase();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      title: 'cashierApp',
      theme: appTheme(),
      initialRoute:
          widget.islogin ? Constant.DashboardScreen : Constant.TerminalScreen,
      routes: routes,
    );
  }
}
