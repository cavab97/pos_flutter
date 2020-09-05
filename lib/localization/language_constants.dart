import 'package:flutter/material.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/localization/LocalizationMain.dart';
import 'package:shared_preferences/shared_preferences.dart';


//languages code
const String ENGLISH = 'en';
const String FARSI = 'fa';
const String ARABIC = 'ar';
const String HINDI = 'hi';

Future<Locale> setLocale(String languageCode) async {
  Preferences.setStringToSF(Constant.LAGUAGE_CODE,languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  return Preferences.getStringValuesSF(Constant.LAGUAGE_CODE) ?? "en";
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case ENGLISH:
      return Locale(ENGLISH, 'US');
    case FARSI:
      return Locale(FARSI, "IR");
    case ARABIC:
      return Locale(ARABIC, "SA");
    case HINDI:
      return Locale(HINDI, "IN");
    default:
      return Locale(ENGLISH, 'US');
  }
}

String getTranslated(BuildContext context, String key) {
  return BaseLocalization.of(context).translate(key);
}