import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BaseLocalization {
  BaseLocalization(this.locale);

  final Locale locale;
  static BaseLocalization of(BuildContext context) {
    return Localizations.of<BaseLocalization>(context, BaseLocalization);
  }

  Map<String, String> _localizedValues;

  Future<void> load() async {
    String jsonStringValues =
    await rootBundle.loadString('lib/lang/${locale.languageCode}.json');
    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
    _localizedValues =
        mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  String translate(String key) {
    return _localizedValues[key];
  }

  // static member to have simple access to the delegate from Material App
  static const LocalizationsDelegate<BaseLocalization> delegate =
  _BaseLocalizationsDelegate();
}

class _BaseLocalizationsDelegate
    extends LocalizationsDelegate<BaseLocalization> {
  const _BaseLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fa', 'ar', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<BaseLocalization> load(Locale locale) async {
    BaseLocalization localization = new BaseLocalization(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate<BaseLocalization> old) => false;
}
