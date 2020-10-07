import 'package:flutter/material.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';

class SplashScreen extends StatefulWidget {
// PIN Enter PAGE
  SplashScreen({Key key}) : super(key: key);

  @override
  SplashScreenstate createState() => SplashScreenstate();
}

class SplashScreenstate extends State<SplashScreen> {
  @override
  void initState() {
// TODO: implement initState
    super.initState();
    navigatePage();
  }

  navigatePage() {
    Future.delayed(const Duration(seconds: 4), () async {
      final bool isLogged = await CommunFun.isLogged();
      if (isLogged) {
        await Navigator.of(context).pushNamed(Constant.DashboardScreen);
      } else {
        await Navigator.of(context).pushNamed(Constant.TerminalScreen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          child: Image.asset("assets/splash_screen.png",
              fit: BoxFit.cover,
              gaplessPlayback: false,
              height: double.infinity,
              width: double.infinity),
        ),
      ),
    );
  }
}
