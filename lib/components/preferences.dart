import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
/*Base method for get shared pref*/
static baseMain() async {
SharedPreferences pref = await SharedPreferences.getInstance();
return pref;
}

/*Check for Pref is available or not
static checkIsAvailable(String key) async {
SharedPreferences pref= await SharedPreferences.getInstance();
int intValue= await pref.getInt(key) ?? 0;
if(intValue==0){
return true;
}
return false;
} */

/*set String shared pref*/
static setStringToSF(String key, String value) async {
SharedPreferences pref = await SharedPreferences.getInstance();
pref.setString(key, value);
}

/*set Bool shared pref*/
static setBoolToSF(String key, bool value) async {
SharedPreferences pref = await SharedPreferences.getInstance();
pref.setBool(key, value);
}

/*get String pref*/
static getStringValuesSF(String key) async {
SharedPreferences pref = await SharedPreferences.getInstance();
//final user = await checkIsAvailable(key);
// if (user) {
return pref.getString(key)?.toString() ?? null;
//} else {
// return "";
/// }
}

static getBoolValuesSF(String key) async {
SharedPreferences pref = await SharedPreferences.getInstance();

return pref.getString(key) ?? null;

/*final user = await checkIsAvailable(key);

if (user) {
return pref.getBool(key);
} else {
return false;
}*/
}

static removeSinglePref(String key) async {
SharedPreferences pref = await SharedPreferences.getInstance();
pref.remove(key);

/* final user = await checkIsAvailable(key);
if (user) {
pref.remove(key);
return true;
} else {
return false;
}*/
}
}