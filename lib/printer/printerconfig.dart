import 'dart:async';

import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/PorductDetails.dart';

class PrintReceipt {
  PaperSize paper = PaperSize.mm80;

  Future<Ticket> KOTReceipt(
      PaperSize paper, String tableName, List<MSTCartdetails> cartList) async {
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
    //ticket.text('Pax : ', styles: PosStyles(align: PosAlign.left));
    ticket.text('Table No : ' + tableName,
        styles: PosStyles(align: PosAlign.left));
    //ticket.text('Terminal Name : MCN002', styles: PosStyles(align: PosAlign.left));

    ticket.hr();
    ticket.row([
      PosColumn(text: 'Qty', width: 2),
      PosColumn(text: 'Item', width: 10),
    ]);
    ticket.hr();

    for (var i = 0; i < cartList.length; i++) {
      var item = cartList[i];
      if (item.isSendKichen == null) {
        ticket.row([
          PosColumn(text: item.productQty.toString(), width: 2),
          PosColumn(text: item.productName, width: 10),
        ]);
      }
    }
    ticket.feed(2);
    ticket.cut();
    return ticket;
  }

  void checkKOTPrint(String printerIp, String tableName, BuildContext ctx,
      List<MSTCartdetails> cartList) async {
    final PrinterNetworkManager printerManager = PrinterNetworkManager();
    printerManager.selectPrinter(printerIp, port: 9100);

    final PosPrintResult res = await printerManager
        .printTicket(await KOTReceipt(paper, tableName, cartList));

    print("PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP");
    print(res.msg);
    print(printerIp);

    CommunFun.showToast(ctx, res.msg);

    /*final snackBar =
        SnackBar(content: Text(res.msg, textAlign: TextAlign.center));
    Scaffold.of(ctx).showSnackBar(snackBar);*/
  }

  /*========================================================================
  ===========================Print Receipt==================================
  ========================================================================*/

  Future<Ticket> Receipt(
      PaperSize paper,
      Branch branchData,
      List<ProductDetails> orderdItem,
      List<OrderDetail> orderdetail,
      Orders orderData,
      OrderPayment paymentdata) async {
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

    final now = DateTime.now();
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
          text: 'ITEM', width: 6, styles: PosStyles(align: PosAlign.left)),
      PosColumn(
          text: 'QTY', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'PRICE', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'AMT', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
    ticket.hr();

    for (var i = 0; i < orderdetail.length; i++) {
      var item = orderdetail[i];
      var name = orderdItem[i];
      ticket.row([
        PosColumn(
            text: name.name, width: 6, styles: PosStyles(align: PosAlign.left)),
        PosColumn(
            text: item.detail_qty.toString(),
            width: 2,
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

  void checkReceiptPrint(
      String printerIp,
      BuildContext ctx,
      PaperSize paper,
      Branch branchData,
      List<ProductDetails> orderdItem,
      List<OrderDetail> orderdetail,
      Orders orderData,
      OrderPayment paymentdata) async {
    final PrinterNetworkManager printerManager = PrinterNetworkManager();
    printerManager.selectPrinter(printerIp, port: 9100);

    final PosPrintResult res = await printerManager.printTicket(await Receipt(
        paper, branchData, orderdItem, orderdetail, orderData, paymentdata));

    CommunFun.showToast(ctx, res.msg);

    /*final snackBar =
        SnackBar(content: Text(res.msg, textAlign: TextAlign.center));
    Scaffold.of(ctx).showSnackBar(snackBar);*/
  }

  /*========================================================================
  ===========================Print Draft print==================================
  ========================================================================*/

  Future<Ticket> DraftReceipt(
      PaperSize paper,
      Branch branchData,
      List<ProductDetails> orderdItem,
      List<OrderDetail> orderdetail,
      Orders orderData,
      OrderPayment paymentdata) async {
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

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);

    ticket.text('Processed by  : ' + branchData.contactPerson,
        styles: PosStyles(align: PosAlign.left));
    ticket.text("Invoice Date : " + timestamp,
        styles: PosStyles(align: PosAlign.left));
    ticket.text('Terminal Name : MCN002',
        styles: PosStyles(align: PosAlign.left));
    ticket.text('Name : Walk-in Customer',
        styles: PosStyles(align: PosAlign.left));

    ticket.hr();
    ticket.row([
      PosColumn(
          text: 'ITEM', width: 6, styles: PosStyles(align: PosAlign.left)),
      PosColumn(
          text: 'QTY', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'PRICE', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'AMT', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
    ticket.hr();

    for (var i = 0; i < orderdetail.length; i++) {
      var item = orderdetail[i];
      var name = orderdItem[i];
      ticket.row([
        PosColumn(
            text: name.name, width: 6, styles: PosStyles(align: PosAlign.left)),
        PosColumn(
            text: item.detail_qty.toString(),
            width: 2,
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

  void checkDraftPrint(
      String printerIp,
      BuildContext ctx,
      PaperSize paper,
      Branch branchData,
      List<ProductDetails> orderdItem,
      List<OrderDetail> orderdetail,
      Orders orderData,
      OrderPayment paymentdata) async {
    final PrinterNetworkManager printerManager = PrinterNetworkManager();
    printerManager.selectPrinter(printerIp, port: 9100);

    final PosPrintResult res = await printerManager.printTicket(
        await DraftReceipt(paper, branchData, orderdItem, orderdetail,
            orderData, paymentdata));

    CommunFun.showToast(ctx, res.msg);

    /*final snackBar =
        SnackBar(content: Text(res.msg, textAlign: TextAlign.center));
    Scaffold.of(ctx).showSnackBar(snackBar);*/
  }

  /*========================================================================
  ===========================Test print=====================================
  ========================================================================*/

  void testReceiptPrint(
      String printerIp, BuildContext ctx, String printerName) async {
    final PrinterNetworkManager printerManager = PrinterNetworkManager();
    printerManager.selectPrinter(printerIp, port: 9100);

    final PosPrintResult res = await printerManager
        .printTicket(await testPrintReceipt(paper, printerName, printerIp));

    CommunFun.showToast(ctx, res.msg);

    /* final snackBar = SnackBar(content: Text(res.msg, textAlign: TextAlign.center));
    Scaffold.of(ctx).showSnackBar(snackBar);*/
  }

  Future<Ticket> testPrintReceipt(
      PaperSize paper, String printerName, String printerIp) async {
    final profile = await CapabilityProfile.load();
    final Ticket ticket = Ticket(paper, profile);

    ticket.text("", linesAfter: 1);
    ticket.text(printerName + " Tested",
        styles: PosStyles(
            fontType: PosFontType.fontA,
            align: PosAlign.center,
            bold: true,
            width: PosTextSize.size1));

    ticket.text("Printer IP : " + printerIp,
        styles: PosStyles(
            fontType: PosFontType.fontA,
            align: PosAlign.center,
            bold: true,
            width: PosTextSize.size1));

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);

    ticket.text("Test Date time : " + timestamp,
        linesAfter: 2,
        styles: PosStyles(
            fontType: PosFontType.fontA, align: PosAlign.center, bold: true));

    ticket.feed(2);
    ticket.cut();
    return ticket;
  }
}
