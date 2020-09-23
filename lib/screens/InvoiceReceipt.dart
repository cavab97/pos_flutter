import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:intl/intl.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:ping_discover_network/ping_discover_network.dart';
import 'package:wifi/wifi.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

class InvoiceReceiptDailog extends StatefulWidget {
  InvoiceReceiptDailog({Key key, this.orderid}) : super(key: key);
  final int orderid;
  @override
  _InvoiceReceiptDailogState createState() => _InvoiceReceiptDailogState();
}

class _InvoiceReceiptDailogState extends State<InvoiceReceiptDailog> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  LocalAPI localAPI = LocalAPI();
  int orderid;

  /*For printer */
  String localIp = '';
  List<String> devices = [];
  bool isDiscovering = false;
  int found = -1;

  // int portController = 1900;
  PaperSize paper = PaperSize.mm80;
  Payments paymentMethod;
  Branch branchData;
  OrderPayment paymentdata;

  User userdata;
  List<ProductDetails> orderdItem;
  List<OrderDetail> orderdetail;
  Orders orderData;
  @override
  void initState() {
    super.initState();
    setState(() {
      orderid = widget.orderid;
    });
    discover(context);
    getOederData();
  }

  getOederData() async {
    var branchID = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    Branch branchAddress = await localAPI.getBranchData(branchID);
    OrderPayment orderpaymentdata = await localAPI.getOrderpaymentData(orderid);
    Payments paument_method =
        await localAPI.getOrderpaymentmethod(orderpaymentdata.op_method_id);
    User user = await localAPI.getPaymentUser(orderpaymentdata.op_by);
    List<ProductDetails> itemsList = await localAPI.getOrderDetails(orderid);
    List<OrderDetail> orderitem = await localAPI.getOrderDetailsList(orderid);
    Orders order = await localAPI.getcurrentOrders(orderid);
    print(branchAddress);
    print(orderpaymentdata);
    print(paument_method);
    print(user);
    print(itemsList);
    print(order);
    setState(() {
      branchData = branchAddress;
      paymentdata = orderpaymentdata;
      paymentMethod = paument_method;
      userdata = user;
      orderdItem = itemsList;
      orderData = order;
      orderdetail = orderitem;
    });
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
                Text(Strings.invoice_reciept.toUpperCase(),
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
                  onTap: () => Receipt(paper),
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
                                    '${devices[index]}:1900',
                                    //${portController.text}',
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

  Future<Ticket> Receipt(PaperSize paper) async {
    final profile = await CapabilityProfile.load();
    final Ticket ticket = Ticket(paper, profile);

    /* // Print image
    final ByteData data = await rootBundle.load('assets/headerlogo.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final image = decodeImage(bytes);
    ticket.image(image, align: PosAlign.center);
*/
    ticket.text("", linesAfter: 1);
    ticket.text(branchData.address,
        styles: PosStyles(
            fontType: PosFontType.fontA,
            align: PosAlign.center,
            bold: true,
            width: PosTextSize.size1));
    ticket.text("Contact No : " + branchData.contactNo,
        linesAfter: 2,
        styles: PosStyles(
            fontType: PosFontType.fontA, align: PosAlign.center, bold: true));

    ticket.emptyLines(1);

    final now = DateTime.parse(orderData.order_date);
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);

    ticket.text('Processed by  : ' + branchData.contactPerson,
        styles: PosStyles(align: PosAlign.left));
    ticket.text("Invoice Date : " + timestamp,
        styles: PosStyles(align: PosAlign.left));
    ticket.text("Invoice No : " + orderData.invoice_no,
        styles: PosStyles(align: PosAlign.left));
    ticket.text('Terminal Name : MCN002',
        styles: PosStyles(align: PosAlign.left));
    ticket.text('Name : Walk-in Customer',
        styles: PosStyles(align: PosAlign.left));

    ticket.hr();
    ticket.row([
      PosColumn(
          text: 'ITEM', width: 7, styles: PosStyles(align: PosAlign.left)),
      PosColumn(
          text: 'QTY', width: 1, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'PRICE', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'AMT', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
    ticket.hr();

    for (var i = 0; i < orderdetail.length; i++) {
      var item = orderdetail[i];
      //var name = orderdItem[i];
      ticket.row([
        PosColumn(
            text: "name.name", width: 7, styles: PosStyles(align: PosAlign.left)),
        PosColumn(
            text: item.detail_qty.toString(),
            width: 1,
            styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text: item.product_old_price.toString(),
            width: 2,
            styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text: item.product_price.toString(),
            width: 2,
            styles: PosStyles(align: PosAlign.right)),
      ]);
    }
    ticket.hr();
    ticket.row([
      PosColumn(
          text: "SUBTOTAL(MYR)",
          width: 8,
          styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: orderData.sub_total.toString(),
          width: 4,
          styles: PosStyles(align: PosAlign.right)),
    ]);
    ticket.hr();

    ticket.row([
      PosColumn(
          text: "TAX(MYR)", width: 8, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: orderData.tax_amount.toString(),
          width: 4,
          styles: PosStyles(align: PosAlign.right)),
    ]);
    ticket.hr();
    ticket.row([
      PosColumn(
          text: "GRANDTOTAL(MYR)",
          width: 8,
          styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: orderData.grand_total.toString(),
          width: 4,
          styles: PosStyles(align: PosAlign.right)),
    ]);
    ticket.row([
      PosColumn(
          text: "CASH(MYR)",
          width: 8,
          styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: paymentdata.op_amount.toString(),
          width: 4,
          styles: PosStyles(align: PosAlign.right)),
    ]);

    ticket.feed(2);
    ticket.text('Thank you!',
        styles: PosStyles(align: PosAlign.center, bold: true));
    ticket.text('Please visit us again',
        styles: PosStyles(align: PosAlign.center, bold: true));

    ticket.feed(2);
    ticket.cut();
    return ticket;
  }

  void testPrint(String printerIp, BuildContext ctx) async {
    final PrinterNetworkManager printerManager = PrinterNetworkManager();
    printerManager.selectPrinter(printerIp, port: 9100);

    // TODO Don't forget to choose printer's paper size
    // const PaperSize paper = PaperSize.mm80;

    // TEST PRINT
    // final PosPrintResult res =
    //     await printerManager.printTicket(await testTicket(paper));

    // DEMO RECEIPT
    final PosPrintResult res =
        await printerManager.printTicket(await Receipt(paper));

    final snackBar =
        SnackBar(content: Text(res.msg, textAlign: TextAlign.center));
    Scaffold.of(ctx).showSnackBar(snackBar);
  }
}
