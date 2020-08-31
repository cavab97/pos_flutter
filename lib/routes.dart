import 'package:flutter/widgets.dart';
import 'package:mcncashier/screens/Home.dart';
import 'package:mcncashier/screens/Login.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  "/": (BuildContext context) => LoginPage(),
  "/Login": (BuildContext context) => LoginPage(),
};
