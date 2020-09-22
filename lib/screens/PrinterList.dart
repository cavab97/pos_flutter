import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/services/LocalAPIs.dart';

import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:flutter/services.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:intl/intl.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:ping_discover_network/ping_discover_network.dart';
import 'package:wifi/wifi.dart';

class PrinterListDailog extends StatefulWidget {
  PrinterListDailog({Key key, this.onPress, this.cartList}) : super(key: key);
  Function onPress;
  List<MSTCartdetails> cartList;

  @override
  _PrinterListDailogState createState() => _PrinterListDailogState();
}

class _PrinterListDailogState extends State<PrinterListDailog> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  LocalAPI localAPI = LocalAPI();

  /*For printer */
  String localIp = '';
  List<String> devices = [];
  bool isDiscovering = false;
  int found = -1;
  // int portController = 1900;
  PaperSize paper = PaperSize.mm80;
  List<MSTCartdetails> itemList = [];
  @override
  void initState() {
    super.initState();
    setState(() {
      itemList = widget.cartList;
    });
    discover(context);
  }

  sendTokitched() async {
    List<String> ids = [];
    for (var i = 0; i < itemList.length; i++) {
      if (itemList[i].isSendKichen == null || itemList[i].isSendKichen == 0) {
        ids.add(itemList[i].id.toString());
      }
      if (i == itemList.length - 1) {
        dynamic send = await localAPI.sendToKitched(ids);
        print(send);
      }
    }
  }

  void discover(BuildContext ctx) async {
    setState(() {
      isDiscovering = true;
      devices.clear();
      found = -1;
    });

    String ip;
    try {
      ip = await Wifi.ip;
      print('local ip:\t$ip');
    } catch (e) {
      final snackBar = SnackBar(
          content:
              Text('WiFi is not connected $e', textAlign: TextAlign.center));
      Scaffold.of(ctx).showSnackBar(snackBar);
      return;
    }
    setState(() {
      localIp = ip;
    });

    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    int port = 9100;
    /* try {
      port = int.parse(portController.text);
    } catch (e) {
      portController.text = port.toString();
    }*/
    print('subnet:\t$subnet, port:\t$port');

    final stream = NetworkAnalyzer.discover2(subnet, port);

    stream.listen((NetworkAddress addr) {
      if (addr.exists) {
        print('Found device: ${addr.ip}');
        setState(() {
          devices.add(addr.ip);
          found = devices.length;
        });
      }
    })
      ..onDone(() {
        setState(() {
          isDiscovering = false;
          found = devices.length;
        });
      })
      ..onError((dynamic e) {
        final snackBar = SnackBar(
            content: Text('Unexpected exception', textAlign: TextAlign.center));
        Scaffold.of(ctx).showSnackBar(snackBar);
      });
  }

  Future<Ticket> KOTReceipt(PaperSize paper) async {
    final profile = await CapabilityProfile.load();
    final Ticket ticket = Ticket(paper, profile);

    ticket.text('K.O.T',
        styles: PosStyles(
          fontType: PosFontType.fontA,
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    ticket.text("Date : " + timestamp, styles: PosStyles(align: PosAlign.left));
    ticket.text('Pax : ', styles: PosStyles(align: PosAlign.left));
    ticket.text('Table No : MCN_TAB001',
        styles: PosStyles(align: PosAlign.left));
    ticket.text('Terminal Name : MCN002',
        styles: PosStyles(align: PosAlign.left));

    ticket.hr();
    ticket.row([
      PosColumn(text: 'Qty', width: 2),
      PosColumn(text: 'Item', width: 10),
    ]);
    ticket.hr();

    for (var i = 0; i < itemList.length; i++) {
      var item = itemList[i];
      if (item.isSendKichen == null) {
        ticket.row([
          PosColumn(text: item.productQty.toString(), width: 2),
          PosColumn(text: item.productName, width: 10),
        ]);
      }
    }
    // ticket.row([
    //   PosColumn(text: '2', width: 2),
    //   PosColumn(text: 'ONION RINGS', width: 10),
    // ]);
    // ticket.row([
    //   PosColumn(text: '1', width: 2),
    //   PosColumn(text: 'PIZZA', width: 10),
    // ]);
    // ticket.row([
    //   PosColumn(text: '1', width: 2),
    //   PosColumn(text: 'SPRING ROLLS', width: 10),
    // ]);
    // ticket.row([
    //   PosColumn(text: '3', width: 2),
    //   PosColumn(text: 'CRUNCHY STICKS', width: 10),
    // ]);

    ticket.feed(2);
    ticket.cut();
    return ticket;
  }

  void testPrint(String printerIp, BuildContext ctx) async {
    sendTokitched();
    final PrinterNetworkManager printerManager = PrinterNetworkManager();
    printerManager.selectPrinter(printerIp, port: 9100);

    // TODO Don't forget to choose printer's paper size
    // const PaperSize paper = PaperSize.mm80;

    // TEST PRINT
    // final PosPrintResult res =
    //     await printerManager.printTicket(await testTicket(paper));

    // DEMO RECEIPT
    final PosPrintResult res =
        await printerManager.printTicket(await KOTReceipt(paper));

    final snackBar =
        SnackBar(content: Text(res.msg, textAlign: TextAlign.center));
    Scaffold.of(ctx).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      title: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
            height: 70,
            color: Colors.black,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Select Printer",
                    style: TextStyle(fontSize: 30, color: Colors.white)),
              ],
            ),
          ),
          Positioned(
            right: 30,
            top: 10,
            child: Icon(
              Icons.print,
              color: Colors.white,
              size: 50,
            ),
          ),
          Positioned(
              left: 30,
              top: 15,
              child: IconButton(
                  icon: Icon(
                    Icons.sync,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: isDiscovering ? null : () => discover(context))),
          closeButton(context),
        ],
      ),
      content: mainContent(),
    );
  }

  Widget closeButton(context) {
    return Positioned(
        top: -30,
        right: -20,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(30.0)),
            child: Icon(
              Icons.clear,
              color: Colors.white,
              size: 30,
            ),
          ),
        ));
  }

  //widget.onPress;
  Widget mainContent() {
    return Container(
      height: MediaQuery.of(context).size.height / 1.5,
      width: MediaQuery.of(context).size.width / 2,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 10),
          // Text('Local ip: $localIp', style: TextStyle(fontSize: 16)),
          // SizedBox(height: 15),
          // RaisedButton(
          //     child: Text('${isDiscovering ? 'Discovering...' : 'Discover'}'),
          //     onPressed: isDiscovering ? null : () => discover(context)),
          SizedBox(height: 15),
          found >= 1
              ? Text('Found: $found device(s)', style: TextStyle(fontSize: 16))
              : Container(),
          Container(
            // height: MediaQuery.of(context).size.height / 2.2,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: devices.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () => testPrint(devices[index], context),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    '${devices[index]}:1900', //${portController.text}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Click to print a test receipt',
                                    style: TextStyle(color: Colors.grey[700]),
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
    );
  }
}
