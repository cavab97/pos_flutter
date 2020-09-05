import 'package:mcncashier/components/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
/*Base method for get shared pref*/
  static baseMain() async {
    return await SharedPreferences.getInstance();
  }

/*Check for Pref is available or not */
  static checkIsAvailable(String key) {
    return baseMain().containsKey(key);
  }

/*set String shared pref*/
  static setStringToSF(String key, String value) {
    baseMain().setString(key, value);
  }

/*set Bool  shared pref*/
  static setBoolToSF(String key, bool value) async {
    baseMain().setBool(key, value);
  }

/*get String pref*/
  static getStringValuesSF(String key) async {
//  int intValue = baseMain().getInt(key) ?? 0;
    if (checkIsAvailable(key)) {
      return baseMain().getString(key);
    } else {
      return null;
    }
  }

  static getBoolValuesSF(String key) async {
    if (checkIsAvailable(key)) {
      return baseMain().getBool(key);
    } else {
      return false;
    }
  }

  static removeSinglePref(String key) async {
    if (checkIsAvailable(key)) {
      baseMain().remove(key);
      return true;
    } else {
      return false;
    }
  }
}
