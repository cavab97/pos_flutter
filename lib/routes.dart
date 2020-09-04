import 'package:flutter/widgets.dart';
import 'package:mcncashier/screens/Dashboard.dart';
import 'package:mcncashier/screens/Login.dart';
import 'package:mcncashier/screens/OpningAmountPop.dart';
import 'package:mcncashier/screens/PINPage.dart';
import 'package:mcncashier/screens/ProductQuantityDailog.dart';
import 'package:mcncashier/screens/TerminalScreen.dart';
import 'package:mcncashier/screens/Transactions.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  "/TerminalKeyPage": (BuildContext context) => TerminalKeyPage(),
  "/Login": (BuildContext context) => LoginPage(),
  "/PINPage": (BuildContext context) => PINPage(),
  "/Dashboard": (BuildContext context) => DashboradPage(),
  "/TansactionsPage": (BuildContext context) => TransactionsPage(),
};
