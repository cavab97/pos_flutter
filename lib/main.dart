import 'package:flutter/material.dart';
import 'package:mcncashier/routes.dart';
import 'package:mcncashier/theme/theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cashierApp',
      theme: appTheme(),
      initialRoute: '/',
      routes: routes,
    );
  }
}
