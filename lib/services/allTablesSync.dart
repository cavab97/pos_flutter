import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/services/CommunAPICall.dart';

class SyncAPICalls {
  static getDataServerBulk1(context) async {
    var apiurl =  Configrations.appdata1;
    var stringParams = {'datetime': '2020-09-01 12:30:25', 'branchId': 1};
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk2_1(context) async {
    var apiurl = Configrations.appdata2_1;
    var stringParams = {'datetime': '2020-09-01 12:30:25', 'branchId': 1};
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk2_2(context) async {
    var apiurl = Configrations.appdata2_2;
    var stringParams = {'datetime': '2020-09-01 12:30:25', 'branchId': 1};
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk2_3(context) async {
    var apiurl = Configrations.appdata2_3;
    var stringParams = {'datetime': '2020-09-01 12:30:25', 'branchId': 1};
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk3(context) async {
    var apiurl = Configrations.appdata3;
    var stringParams = {'datetime': '2020-09-01 12:30:25', 'branchId': 1};
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk4_1(context) async {
    var apiurl = Configrations.appdata4_1;
    var stringParams = {'datetime': '2020-09-01 12:30:25', 'branchId': 1};
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk4_2(context) async {
    var apiurl = Configrations.appdata4_2;
    var stringParams = {'datetime': '2020-09-01 12:30:25', 'branchId': 1};
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getAssets(context) async {
    var apiurl = Configrations.product_image;
    var stringParams = {'datetime': '2020-09-01 12:30:25', 'branchId': 1};
    return await APICalls.apiCall(apiurl, context, stringParams);
  }
}
