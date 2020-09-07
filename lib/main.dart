import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mcncashier/routes.dart';
import 'package:mcncashier/theme/theme.dart';

import 'components/constant.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'cashierApp',
      theme: appTheme(),
      initialRoute: Constant.TerminalScreen,
      routes: routes,
    );
  }
}
