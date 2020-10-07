import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/colors.dart';
import 'package:mcncashier/components/styles.dart';
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
  PrintReceipt testPrint = PrintReceipt();

  List<Printer> printerList = new List<Printer>();

  bool isPrinterSettings = false;
  bool isGeneralSettings = false;
  bool isChangeTheme = false;
  bool isChangeLanguage = false;
  bool alwaysPrint = false;

  @override
  void initState() {
    super.initState();
    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
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
    List<Printer> printer = await localAPI.getAllPrinter();
    print(printer);
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
                print(selected);
                Printer table_printe = new Printer();
                table_printe.printerIp = ip;
                table_printe.printerIsCashier = selected;
                var result = await localAPI.insertTablePrinter(table_printe);
                print("Printer result");
                print(result);
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
                        shrinkWrap: true,
                        padding: EdgeInsets.only(left: 20, right: 20),
                        children: <Widget>[
                          ListTile(
                            contentPadding: EdgeInsets.only(left: 0, top: 20),
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
                              openSideData("General");
                            },
                            title: Text(
                              "General",
                              style: Styles.blackBoldsmall(),
                            ),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.only(left: 0, top: 10),
                            selected: isPrinterSettings,
                            onTap: () {
                              openSideData("Printer");
                              getAllPrinter();
                            },
                            title: Text(
                              "Printer",
                              style: Styles.blackBoldsmall(),
                            ),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.only(left: 0, top: 10),
                            selected: isChangeLanguage,
                            onTap: () {},
                            title: Text(
                              "Change Language",
                              style: Styles.blackBoldsmall(),
                            ),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.only(left: 0, top: 10),
                            selected: isChangeTheme,
                            onTap: () {},
                            title: Text(
                              "Change Theme",
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
      padding: EdgeInsets.all(20),
      shrinkWrap: true,
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Center(
          child: Text(
            "General",
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
              title: Text("Auto sync", style: Styles.whiteSimpleSmall()),
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
            padding: EdgeInsets.all(20),
            shrinkWrap: true,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  "Printing",
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
                    title: Text("Always Print Receipt",
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
                  shrinkWrap: true,
                  itemCount: printerList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () => testPrint.testReceiptPrint(
                          printerList[index].printerIp,
                          context,
                          printerList[index].printerName),
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
                                        'Click to print a test receipt',
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
            "Print Test Receipt",
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
            "Search Printer",
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
