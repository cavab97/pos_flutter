import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/communText.dart';
import '../main.dart';
import 'environment_config.dart';

enum AppEnvironment {
  development,
  staging,
  production,
  local,
}

class FlutterAppConfig {
  FlutterAppConfig({@required this.environment});

  final AppEnvironment environment;

  static Map<String, dynamic> _config;

  static void setEnvironment(AppEnvironment env) {
    switch (env) {
      case AppEnvironment.local:
        _config = Config.localConstants;
        break;
      case AppEnvironment.development:
        _config = Config.developmentConstants;
        break;
      case AppEnvironment.staging:
        _config = Config.stagingConstants;
        break;
      case AppEnvironment.production:
        _config = Config.productionConstants;
        break;
    }
  }

  static get CONFIG {
    return _config;
  }

  Future run() async {
    setEnvironment(environment);
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsFlutterBinding.ensureInitialized();
    final bool isLogged = await CommunFun.isLogged();
    runApp(MyApp(islogin: isLogged));
  }
}
