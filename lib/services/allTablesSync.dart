import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/services/CommunAPICall.dart';

class SyncAPICalls {
  static getDataServerBulk1(context) async {
    var apiurl = Configrations.appdata1;
    var branchid = Preferences.getStringValuesSF(Constant.BRANCH_ID);
    var stringParams = {'datetime': '', 'branchId': branchid};
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk2_1(context) async {
    var apiurl = Configrations.appdata2_1;
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);
    var stringParams = {'datetime': serverTime, 'branchId': branchid};
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk2_2(context) async {
    var apiurl = Configrations.appdata2_2;
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);
    var stringParams = {'datetime': serverTime, 'branchId': branchid};
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk2_3(context) async {
    var apiurl = Configrations.appdata2_3;
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);
    var stringParams = {'datetime': serverTime, 'branchId': branchid};
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk3(context) async {
    var apiurl = Configrations.appdata3;
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);
    var stringParams = {'datetime': branchid, 'branchId': serverTime};
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk4_1(context) async {
    var apiurl = Configrations.appdata4_1;
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);
    var stringParams = {'datetime': serverTime, 'branchId': branchid};
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk4_2(context) async {
    var apiurl = Configrations.appdata4_2;
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);
    var stringParams = {'datetime': serverTime, 'branchId': branchid};
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getAssets(context) async {
    var apiurl = Configrations.product_image;
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);
    var stringParams = {'datetime': branchid, 'branchId': serverTime};
    return await APICalls.apiCall(apiurl, context, stringParams);
  }
}
