import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/colors.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/helpers/CustomeIcons.dart';
import 'package:mcncashier/helpers/LocalAPI/CategoriesList.dart';
import 'package:mcncashier/helpers/LocalAPI/PrinterList.dart';
import 'package:mcncashier/helpers/Server.dart';
import 'package:mcncashier/models/Category.dart';
import 'package:mcncashier/models/Printer.dart';
import 'package:mcncashier/screens/PrinteTypeDailog.dart';
import 'package:mcncashier/screens/SelectPrinterDailog.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:mcncashier/printer/printerconfig.dart';

class SettingsPage extends StatefulWidget {
  // Transactions list
  SettingsPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  LocalAPI localAPI = LocalAPI();
  PrinterList printerAPI = new PrinterList();
  PrintReceipt testPrint = PrintReceipt();
  List<Printer> printerList = new List<Printer>();
  bool isAutoSync = false;
  bool isPrinterSettings = false;
  bool isGeneralSettings = true;
  bool isChangeTheme = false;
  bool isChangeLanguage = false;
  bool alwaysPrint = false;
  bool isLocalServer = false;
  var scanResult;
  bool isJoinLoaclServer = false;

  @override
  void initState() {
    super.initState();
    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
    setDefault();
  }

  setDefault() async {
    var isjoined = await Preferences.getStringValuesSF(Constant.IS_JOIN_SERVER);
    if (isjoined != null) {
      setState(() {
        isJoinLoaclServer = isjoined == "true" ? true : false;
      });
    }
    checkisAutoSync();
  }

  checkisAutoSync() async {
    var isSync = await Preferences.getStringValuesSF(Constant.IS_AUTO_SYNC);
    if (isSync != null) {
      setState(() {
        isAutoSync = isSync == "true" ? true : false;
      });
    }
  }

  setAutosync(issync) async {
    setState(() {
      isAutoSync = issync;
    });
    if (issync) {
      await Preferences.setStringToSF(Constant.IS_AUTO_SYNC, issync.toString());
      await CommunFun.checkisAutoSync(context);
    } else {
      await Preferences.removeSinglePref(Constant.IS_AUTO_SYNC);
      CommunFun.stopAutoSync();
    }
  }

  openSideData(side) {
    switch (side) {
      case "General":
        opneGeneralSettings();
        break;
      case "Printer":
        opnePrinterSettings();
        break;
      default:
    }
  }

  opneGeneralSettings() {
    // General settins
    setState(() {
      isPrinterSettings = false;
      isGeneralSettings = true;
    });
  }

  opnePrinterSettings() {
    setState(() {
      isGeneralSettings = false;
      isPrinterSettings = true;
    });
  }

  /*Get all Printer from DB*/
  getAllPrinter() async {
    List<Printer> printer = await printerAPI.getAllPrinterList(context, "0");
    setState(() {
      printerList = printer;
    });
  }

  openSelectType(ip) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ChoosePrinterDailog(
              selectedIP: ip,
              onClose: (selected) async {
                Navigator.of(context).pop();
                //TODO: Save Printer

                Printer table_printe = new Printer();
                table_printe.printerIp = ip;
                table_printe.printerIsCashier = selected;
                //var result = await localAPI.insertTablePrinter(table_printe);
                var result = await localAPI.insertTablePrinter(table_printe);
              });
        });
  }

  openPrinterOption() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SelectPrinterDailog(
            onClose: (ip) {
              Navigator.of(context).pop();
              openSelectType(ip);
            },
          );
        });
  }

  joinLocalServer(value) async {
    var isOpen = await Preferences.getStringValuesSF(Constant.IS_SHIFT_OPEN);
    // if (isOpen != null && isOpen == "true") {
    //   CommunFun.showToast(context, Strings.shift_close_msg);
    // } else {
    setState(() {
      isJoinLoaclServer = value;
    });
    if (value == true) {
      scanQRCode();
    } else {
      remvoveLocalServer();
    }
    //}
  }

  remvoveLocalServer() async {
    await Preferences.removeSinglePref(Constant.IS_JOIN_SERVER);
    await Preferences.removeSinglePref(Constant.SERVER_IP);
  }

  opneqrcodePop() async {
    var wifiData = await CommunFun.wifiDetails();
    if (wifiData.ip != null) {
      await Server.createSetver(wifiData.ip, context);
    } else {
      CommunFun.showToast(context, "Error when getting device ip address");
    }
  }

  Future scanQRCode() async {
    try {
      var options = ScanOptions(
          // strings: {
          //   "cancel": _cancelController.text,
          //   "flash_on": _flashOnController.text,
          //   "flash_off": _flashOffController.text,
          // },
          // restrictFormat: selectedFormats,
          // useCamera: -1,
          // autoEnableFlash: _autoEnableFlash,
          // android: AndroidOptions(
          //   aspectTolerance: _aspectTolerance,
          //   useAutoFocus: _useAutoFocus,
          // ),
          );
      var result = await BarcodeScanner.scan(options: options);
      print(result);
      setState(() => scanResult = result);
      print(result.type);
      print(result.rawContent);
      print(result.format);
      print(result.formatNote);
      await checkIPisvalid(result.rawContent);
    } on PlatformException catch (e) {
      print(e);
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result.rawContent = 'The user did not grant the camera permission!';
        });
      } else {
        result.rawContent = 'Unknown error: $e';
      }
      setState(() {
        scanResult = result;
      });
    }
  }

  checkIPisvalid(ip) async {
    var branchid = await CommunFun.getbranchId();
    CategoriesList category = new CategoriesList();
    var ipadd = "http://" + ip + ":8080/";
    await Preferences.setStringToSF(Constant.SERVER_IP, ipadd);
    await Preferences.setStringToSF(Constant.IS_JOIN_SERVER, "true");
    try {
      List<Category> categorys =
          await category.getCategories(context, branchid);
      print(categorys);
      if (categorys != null) {
        await Preferences.setStringToSF(Constant.SERVER_IP, ipadd);
      }
    } catch (e) {
      print(e);
      CommunFun.showToast(context, "server not found");
      await Preferences.removeSinglePref(Constant.SERVER_IP);
      await Preferences.removeSinglePref(Constant.IS_JOIN_SERVER);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Table(
              columnWidths: {
                0: FractionColumnWidth(.2),
                1: FractionColumnWidth(.6),
              },
              children: [
                TableRow(children: [
                  TableCell(
                    // Part 1 white
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.white,
                      child: ListView(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        children: <Widget>[
                          ListTile(
                            contentPadding:
                                EdgeInsets.only(left: 10, right: 10, top: 20),
                            leading: IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                                size: 30,
                              ),
                            ),
                            title: Text(
                              "Settings",
                              style: Styles.blackBoldsmall(),
                            ),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.only(left: 0, top: 10),
                            selected: isGeneralSettings,
                            onTap: () {
                              openSideData(Strings.general);
                            },
                            title: Text(
                              Strings.general,
                              style: Styles.blackBoldsmall(),
                            ),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.only(left: 0, top: 10),
                            selected: isPrinterSettings,
                            onTap: () {
                              openSideData(Strings.printer);
                              getAllPrinter();
                            },
                            title: Text(
                              Strings.printer,
                              style: Styles.blackBoldsmall(),
                            ),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.only(left: 0, top: 10),
                            selected: isChangeLanguage,
                            onTap: () {},
                            title: Text(
                              Strings.change_lag,
                              style: Styles.blackBoldsmall(),
                            ),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.only(left: 0, top: 10),
                            selected: isChangeTheme,
                            onTap: () {},
                            title: Text(
                              Strings.change_theme,
                              style: Styles.blackBoldsmall(),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  TableCell(
                    // Part 2 transactions list
                    child: Center(
                      child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: isGeneralSettings
                              ? generalSettings()
                              : printingSetitngs()),
                    ),
                  )
                ]),
              ],
            )),
      ),
    );
  }

  Widget generalSettings() {
    return ListView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(20),
      shrinkWrap: true,
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Center(
          child: Text(
            Strings.general,
            style: Styles.whiteBold(),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          decoration:
              new BoxDecoration(border: new Border.all(color: Colors.white)),
          child: ListTile(
            title: Text(Strings.auto_sync, style: Styles.whiteSimpleSmall()),
            trailing: Transform.scale(
              scale: 1,
              child: CupertinoSwitch(
                activeColor: Colors.deepOrange,
                value: isAutoSync,
                onChanged: (bool value) {
                  setAutosync(value);
                },
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          decoration:
              new BoxDecoration(border: new Border.all(color: Colors.white)),
          child: ListTile(
            title:
                Text("Show logo in recipt", style: Styles.whiteSimpleSmall()),
            trailing: Transform.scale(
              scale: 1.2,
              child: CupertinoSwitch(
                activeColor: Colors.deepOrange,
                value: false,
                onChanged: (bool value) {
                  // setState(() {
                  //   _switchValue = value;
                  // });
                },
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          decoration:
              new BoxDecoration(border: new Border.all(color: Colors.white)),
          child: ListTile(
            title: Text("Show QR code in reciept",
                style: Styles.whiteSimpleSmall()),
            trailing: Transform.scale(
              scale: 1.2,
              child: CupertinoSwitch(
                activeColor: Colors.deepOrange,
                value: false,
                onChanged: (bool value) {
                  // setState(() {
                  //   _switchValue = value;
                  // });
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget printingSetitngs() {
    return Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height,
          child: ListView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(20),
            shrinkWrap: true,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  Strings.printing,
                  style: Styles.whiteBold(),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                decoration: new BoxDecoration(
                    border: new Border.all(color: Colors.white)),
                child: ListTile(
                    title: Text(Strings.always_print_msg,
                        style: Styles.whiteSimpleSmall()),
                    trailing: Transform.scale(
                      scale: 1,
                      child: CupertinoSwitch(
                        value: false,
                        onChanged: (bool value) {
                          // setState(() {
                          //   _switchValue = value;
                          // });
                        },
                      ),
                    )),
              ),
              Container(
                color: Colors.white,
                margin: EdgeInsets.only(top: 10),
                // height: MediaQuery.of(context).size.height / 2.2,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: printerList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () => testPrint.testReceiptPrint(
                          printerList[index].printerIp,
                          context,
                          printerList[index].printerName,
                          Strings.testing),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 60,
                            padding: EdgeInsets.only(left: 10),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.print),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        '${printerList[index].printerIp}',
                                        //${portController.text}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        Strings.click_to_print_test,
                                        style:
                                            TextStyle(color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                          Divider(),
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
        Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                searchPrinterBtn(() {
                  openPrinterOption();
                }),
                SizedBox(width: 50),
                printTestPrint(() {}),
              ],
            ))
      ],
    );
  }

  Widget printTestPrint(_onPress) {
    return Container(
        width: MediaQuery.of(context).size.width / 3.4,
        child: RaisedButton(
          padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
          onPressed: _onPress,
          child: Text(
            Strings.print_test_Rec,
            style: Styles.whiteSimpleSmall(),
          ),
          color: StaticColor.backgroundColor,
          textColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
                width: 1, style: BorderStyle.solid, color: Colors.white),
          ),
        ));
  }

  Widget searchPrinterBtn(_onPress) {
    return Container(
        width: MediaQuery.of(context).size.width / 3.4,
        child: RaisedButton(
          padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
          onPressed: _onPress,
          child: Text(
            Strings.search_printer,
            style: Styles.whiteSimpleSmall(),
          ),
          color: StaticColor.backgroundColor,
          textColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
                width: 1, style: BorderStyle.solid, color: Colors.white),
          ),
        ));
  }
}
