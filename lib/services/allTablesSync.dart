import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/models/TerminalLog.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/services/CommunAPICall.dart';
import 'package:intl/intl.dart';
import 'package:mcncashier/services/LocalAPIs.dart';

class SyncAPICalls {
  static getDataServerBulk1(context) async {
    var apiurl = Configrations.appdata1;
    var terminalId = await Preferences.getStringValuesSF(Constant.TERMINAL_KEY);
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    var stringParams = {
      'datetime': '2020-05-05 11:41:50',
      'branchId': branchid,
      'terminal_id': terminalId
    };
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk2_1(context) async {
    var apiurl = Configrations.appdata2_1;
    var terminalId = await Preferences.getStringValuesSF(Constant.TERMINAL_KEY);
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);

    var stringParams = {
      'datetime': '2020-05-05 11:41:50', //serverTime,
      'branchId': branchid,
      'terminal_id': terminalId
    };
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk2_2(context) async {
    var apiurl = Configrations.appdata2_2;
    var terminalId = await Preferences.getStringValuesSF(Constant.TERMINAL_KEY);
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);
    var stringParams = {
      'datetime': '2020-05-05 11:41:50', //serverTime,
      'branchId': branchid,
      'terminal_id': terminalId
    };
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk2_3(context) async {
    var apiurl = Configrations.appdata2_3;
    var terminalId = await Preferences.getStringValuesSF(Constant.TERMINAL_KEY);
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);
    var stringParams = {
      'datetime': '2020-05-05 11:41:50', // serverTime,
      'branchId': branchid,
      'terminal_id': terminalId
    };
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk3(context) async {
    var apiurl = Configrations.appdata3;
    var terminalId = await Preferences.getStringValuesSF(Constant.TERMINAL_KEY);
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);
    var stringParams = {
      'datetime': '2020-05-05 11:41:50',
      'branchId': branchid,
      'terminal_id': terminalId
    };
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk4_1(context) async {
    var apiurl = Configrations.appdata4_1;
    var terminalId = await Preferences.getStringValuesSF(Constant.TERMINAL_KEY);
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);
    var stringParams = {
      'datetime': '2020-05-05 11:41:50', //serverTime,
      'branchId': branchid,
      'terminal_id': terminalId
    };
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk4_2(context) async {
    var apiurl = Configrations.appdata4_2;
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    var terminalId = await Preferences.getStringValuesSF(Constant.TERMINAL_KEY);
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);

    var stringParams = {
      'datetime': '2020-05-05 11:41:50', //serverTime
      'branchId': branchid,
      'terminal_id': terminalId
    };
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getAssets(context) async {
    var apiurl = Configrations.product_image;
    var terminalId = await Preferences.getStringValuesSF(Constant.TERMINAL_KEY);
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);
    var stringParams = {
      'datetime': '2020-05-05 11:41:50',
      'branchId': branchid, // serverTime,
      'terminal_id': terminalId
    };
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static logActivity(moduleName, disc, tablename, eId) async {
    TerminalLog log = new TerminalLog();
    LocalAPI localAPI = LocalAPI();
    var uuid = await CommunFun.getLocalID();
    var terminalId = await Preferences.getStringValuesSF(Constant.TERMINAL_KEY);
    var branchid = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    User userdata = await CommunFun.getuserDetails();
    final DateTime now = DateTime.now();
    final String date = DateFormat('yyyy-MM-dd').format(now);
    final String time = DateFormat('HH:mm').format(now);
    var datetime =
        await CommunFun.getCurrentDateTime(DateTime.now()).toString();
    log.uuid = uuid;
    log.terminal_id = int.parse(terminalId);
    log.branch_id = int.parse(branchid);
    log.module_name = moduleName;
    log.discription = disc;
    log.activity_date = date;
    log.activity_time = time;
    log.table_name = tablename;
    log.entity_id = eId is int ? eId : int.parse(eId);
    log.status = 1;
    log.updated_at = datetime;
    log.updated_by = userdata.id;
    var logid = await localAPI.terminalLog(log);
    print(logid);
  }
}
