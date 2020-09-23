import 'package:flutter/widgets.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/screens/Dashboard.dart';
import 'package:mcncashier/screens/Login.dart';
import 'package:mcncashier/screens/PINPage.dart';
import 'package:mcncashier/screens/SelectTable.dart';
import 'package:mcncashier/screens/Settings.dart';
import 'package:mcncashier/screens/TerminalScreen.dart';
import 'package:mcncashier/screens/Transactions.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  Constant.TerminalScreen: (BuildContext context) => TerminalKeyPage(),
  Constant.LoginScreen: (BuildContext context) => LoginPage(),
  Constant.PINScreen: (BuildContext context) => PINPage(),
  Constant.DashboardScreen: (BuildContext context) => DashboradPage(),
  Constant.TransactionScreen: (BuildContext context) => TransactionsPage(),
  Constant.SelectTableScreen: (BuildContext context) => SelectTablePage(),
  Constant.SettingsScreen: (BuildContext context) => SettingsPage(),
};
