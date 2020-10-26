import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:image/image.dart';

import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:image/image.dart';

class PrintReceipt {
  PaperSize paper = PaperSize.mm80;

  Future<Ticket> KOTReceipt(PaperSize paper, String tableName,
      List<MSTCartdetails> cartList, String pax) async {
    final profile = await CapabilityProfile.load();

    final Ticket ticket = Ticket(paper, profile);

    ticket.setStyles(
        PosStyles(align: PosAlign.center, fontType: PosFontType.fontA));
    /*ticket.text('K.O.T',
        styles: PosStyles(
          fontType: PosFontType.fontA,
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);*/
    ticket.text('Table : ' + tableName,
        styles: PosStyles(
          fontType: PosFontType.fontA,
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    ticket.text('Pax : ' + pax,
        styles: PosStyles(
          fontType: PosFontType.fontA,
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
        linesAfter: 1);

    ticket.setStyles(
        PosStyles(align: PosAlign.left, fontType: PosFontType.fontB));
    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    ticket.text("Date : " + timestamp,
        styles: PosStyles(
          align: PosAlign.left,
          bold: true,
          fontType: PosFontType.fontA,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));
    /* ticket.text('Table No : ' + tableName,
        styles: PosStyles(align: PosAlign.left));*/

    ticket.hr();
    ticket.setStyles(PosStyles(align: PosAlign.left));
    ticket.row([
      PosColumn(
          text: 'Item',
          width: 11,
          styles: PosStyles(
            align: PosAlign.left,
            bold: true,
            fontType: PosFontType.fontA,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: 'Qty',
          width: 1,
          styles: PosStyles(
            align: PosAlign.left,
            bold: true,
            fontType: PosFontType.fontA,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
    ]);
    ticket.hr();

    for (var i = 0; i < cartList.length; i++) {
      var item = cartList[i];
      if (item.isSendKichen == null) {
        ticket.row([
          PosColumn(
              text: item.productName,
              width: 11,
              styles: PosStyles(
                align: PosAlign.left,
                fontType: PosFontType.fontA,
                bold: true,
              )),
          PosColumn(
              text: item.productQty.toString(),
              width: 1,
              styles: PosStyles(
                align: PosAlign.left,
                fontType: PosFontType.fontA,
                bold: true,
              )),
        ]);
        if (item.productSecondName != null) {
          if (item.productSecondName.isNotEmpty) {
            ticket.row([
              PosColumn(
                  text: item.productSecondName.toString(),
                  width: 12,
                  containsChinese: true,
                  styles: PosStyles(
                    align: PosAlign.left,
                    fontType: PosFontType.fontA,
                  ))
            ]);
          }
        }
      }
    }
    ticket.feed(2);
    ticket.cut();
    return ticket;
  }

  void checkKOTPrint(String printerIp, String tableName, BuildContext ctx,
      List<MSTCartdetails> cartList, String pax) async {
    final PrinterNetworkManager printerManager = PrinterNetworkManager();
    printerManager.selectPrinter(printerIp, port: 9100);
    final PosPrintResult res = await printerManager
        .printTicket(await KOTReceipt(paper, tableName, cartList, pax));

    CommunFun.showToast(ctx, res.msg);
  }

/*========================================================================
  ===========================Print Receipt==================================
  ========================================================================*/

  Future<Ticket> Receipt(
      Branch branchData,
      List taxJson,
      List<OrderDetail> orderdetail,
      Orders orderData,
      Payments paymentdata,
      String customerName) async {
    final profile = await CapabilityProfile.load();
    final Ticket ticket = Ticket(paper, profile);

    // Print image
    ticket.setStyles(
        PosStyles(align: PosAlign.center, fontType: PosFontType.fontA));

    final ByteData data =
        await rootBundle.load('assets/headerlogo_receipt.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final image = decodeImage(bytes);
    ticket.image(image);

    ticket.emptyLines(1);

    ticket.text(branchData.address,
        styles: PosStyles(
            fontType: PosFontType.fontA,
            bold: true,
            width: PosTextSize.size1,
            align: PosAlign.center));
    ticket.text("Contact No : " + branchData.contactNo,
        styles: PosStyles(
            fontType: PosFontType.fontA, align: PosAlign.center, bold: true));

    ticket.emptyLines(1);

    ticket.setStyles(
        PosStyles(align: PosAlign.left, fontType: PosFontType.fontB));
    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);

    ticket.text('Processed by  : ' + branchData.contactPerson,
        styles: PosStyles(align: PosAlign.left));
    ticket.text("Invoice Date : " + timestamp,
        styles: PosStyles(align: PosAlign.left));
    ticket.text('Terminal Name : MCN002',
        styles: PosStyles(align: PosAlign.left));
    ticket.text('Name : ' + customerName,
        styles: PosStyles(align: PosAlign.left), linesAfter: 1);

    ticket.text("Order # : " + orderData.invoice_no,
        styles: PosStyles(
          fontType: PosFontType.fontA,
          bold: true,
          underline: true,
          align: PosAlign.right,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
        linesAfter: 1);

    ticket.hr();
    ticket.setStyles(PosStyles(align: null));
    ticket.row([
      PosColumn(
          text: 'Item',
          width: 8,
          styles: PosStyles(
              align: PosAlign.left, fontType: PosFontType.fontA, bold: true)),
      PosColumn(
          text: 'QTY',
          width: 2,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: true,
          )),
      PosColumn(
          text: 'AMT',
          width: 2,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: true,
          )),
    ]);
    ticket.hr();
    for (var i = 0; i < orderdetail.length; i++) {
      var item = orderdetail[i];
      var name = jsonDecode(item.product_detail);
      ticket.row([
        PosColumn(
            text: name["name"],
            width: 8,
            styles: PosStyles(align: PosAlign.left)),
        PosColumn(
            text: item.detail_qty.toString(),
            width: 2,
            styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text: item.product_price.toStringAsFixed(2),
            width: 2,
            styles: PosStyles(align: PosAlign.right)),
      ]);
      if (name["name_2"] != null) {
        if (name["name_2"].isNotEmpty) {
          ticket.row([
            PosColumn(
                text: name["name_2"].toString(),
                width: 12,
                containsChinese: true,
                styles: PosStyles(
                  align: PosAlign.left,
                  fontType: PosFontType.fontA,
                ))
          ]);
        }
      }
    }
    ticket.hr();
    ticket.setStyles(PosStyles(align: PosAlign.right));
    ticket.row([
      PosColumn(
          text: "SUB TOTAL(MYR)",
          width: 8,
          styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: orderData.sub_total.toStringAsFixed(2),
          width: 4,
          styles: PosStyles(align: PosAlign.right)),
    ]);
    ticket.hr();

    if (taxJson.length > 0) {
      taxJson.forEach((element) {
        ticket.row([
          PosColumn(
              text: Strings.tax.toUpperCase() +
                  " " +
                  element["taxCode"] +
                  "(" +
                  element["rate"] +
                  "%)",
              width: 8,
              styles: PosStyles(align: PosAlign.right)),
          PosColumn(
              text: element["taxAmount"].toString(),
              width: 4,
              styles: PosStyles(align: PosAlign.right))
        ]);
      });
    }

    ticket.row([
      PosColumn(
          text: "GRAND TOTAL(MYR)",
          width: 8,
          styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: orderData.grand_total.toStringAsFixed(2),
          width: 4,
          styles: PosStyles(align: PosAlign.right))
    ]);
    ticket.row([
      PosColumn(
          text: "PAYMENT TYPE",
          width: 8,
          styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: paymentdata.name.toString(),
          width: 4,
          styles: PosStyles(align: PosAlign.right))
    ]);

    ticket.setStyles(PosStyles(align: PosAlign.center));
    ticket.emptyLines(1);
    ticket.qrcode('www.MCN.com', size: QRSize.Size5, align: PosAlign.center);
    ticket.emptyLines(1);

    ticket.text('Thank you!',
        styles: PosStyles(bold: true, align: PosAlign.center));
    ticket.text('Please visit us again',
        styles: PosStyles(bold: true, align: PosAlign.center));

    ticket.feed(1);
    ticket.cut();

    /*Open Drawer only when select payment method cash*/
    if (paymentdata.name.toString().toLowerCase() == "cash") {
      ticket.drawer();
    }
    return ticket;
  }

  void checkReceiptPrint(
      String printerIp,
      BuildContext ctx,
      Branch branchData,
      List taxJson,
      List<OrderDetail> orderdetail,
      Orders orderData,
      Payments paymentdata,
      String customerName) async {
    final PrinterNetworkManager printerManager = PrinterNetworkManager();
    printerManager.selectPrinter(printerIp, port: 9100);

    final PosPrintResult res = await printerManager.printTicket(await Receipt(
        branchData,
        taxJson,
        orderdetail,
        orderData,
        paymentdata,
        customerName));

    CommunFun.showToast(ctx, res.msg);

/*final snackBar =
        SnackBar(content: Text(res.msg, textAlign: TextAlign.center));
    Scaffold.of(ctx).showSnackBar(snackBar);*/
  }

/*========================================================================
  ===========================Print Draft print==================================
  ========================================================================*/

  Future<Ticket> DraftReceipt(
      List taxJson,
      List<MSTCartdetails> cartList,
      String tableName,
      double subTotal,
      double grandTotal,
      double tax,
      Branch branchData,
      String custName) async {
    final profile = await CapabilityProfile.load();
    final Ticket ticket = Ticket(paper, profile);

    // Print image
    ticket.setStyles(
        PosStyles(align: PosAlign.center, fontType: PosFontType.fontA));
    final ByteData data =
        await rootBundle.load('assets/headerlogo_receipt.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final image = decodeImage(bytes);
    ticket.image(image);
    ticket.emptyLines(1);

    ticket.text(branchData.address,
        styles: PosStyles(
            fontType: PosFontType.fontA,
            bold: true,
            align: PosAlign.center,
            width: PosTextSize.size1));
    ticket.text("Contact No : " + branchData.contactNo,
        styles: PosStyles(
            fontType: PosFontType.fontA, align: PosAlign.center, bold: true));

    ticket.emptyLines(1);

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);

    ticket.setStyles(
        PosStyles(align: PosAlign.left, fontType: PosFontType.fontB));
    ticket.text('Processed by  : ' + branchData.contactPerson,
        styles: PosStyles(align: PosAlign.left));
    ticket.text("Invoice Date : " + timestamp,
        styles: PosStyles(align: PosAlign.left));
    ticket.text('Terminal Name : MCN002',
        styles: PosStyles(align: PosAlign.left));
    ticket.text('Name : ' + custName, styles: PosStyles(align: PosAlign.left));

    ticket.hr();
    ticket.setStyles(PosStyles(align: null));
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

    for (var i = 0; i < cartList.length; i++) {
      var total = cartList[i].productQty * cartList[i].productPrice;

      ticket.row([
        PosColumn(
            text: cartList[i].productName,
            width: 6,
            styles: PosStyles(align: PosAlign.left)),
        PosColumn(
            text: cartList[i].productQty.toString(),
            width: 2,
            styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text: cartList[i].productPrice.toStringAsFixed(2),
            width: 2,
            styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text: total.toStringAsFixed(2),
            width: 2,
            styles: PosStyles(align: PosAlign.right)),
      ]);
    }
    ticket.hr();
    ticket.setStyles(PosStyles(align: PosAlign.right));
    ticket.row([
      PosColumn(
          text: "SUB TOTAL(MYR)",
          width: 8,
          styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: subTotal.toStringAsFixed(2),
          width: 4,
          styles: PosStyles(align: PosAlign.right)),
    ]);
    ticket.hr();
    if (taxJson.length > 0) {
      taxJson.forEach((element) {
        ticket.row([
          PosColumn(
              text: Strings.tax.toUpperCase() +
                  " " +
                  element["taxCode"] +
                  "(" +
                  element["rate"] +
                  "%)",
              width: 8,
              styles: PosStyles(align: PosAlign.right)),
          PosColumn(
              text: element["taxAmount"].toString(),
              width: 4,
              styles: PosStyles(align: PosAlign.right))
        ]);
      });
    }
    /* ticket.row([
      PosColumn(
          text: "TAX(MYR)", width: 8, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: tax.toStringAsFixed(2),
          width: 4,
          styles: PosStyles(align: PosAlign.right)),
    ]);*/
    //ticket.hr();
    ticket.row([
      PosColumn(
          text: "GRAND TOTAL(MYR)",
          width: 8,
          styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: grandTotal.toStringAsFixed(2),
          width: 4,
          styles: PosStyles(align: PosAlign.right)),
    ]);

    ticket.setStyles(PosStyles(align: PosAlign.center));
    ticket.emptyLines(1);
    ticket.qrcode('www.MCN.com', size: QRSize.Size5, align: PosAlign.center);
    ticket.emptyLines(1);

    ticket.text('Thank you!',
        styles: PosStyles(bold: true, align: PosAlign.center));
    ticket.text('Please visit us again',
        styles: PosStyles(bold: true, align: PosAlign.center));

    ticket.feed(2);
    ticket.cut();
    return ticket;
  }

  void checkDraftPrint(
      List taxJson,
      String printerIp,
      BuildContext ctx,
      List<MSTCartdetails> cartList,
      String tableName,
      double subTotal,
      double grandTotal,
      double tax,
      Branch branchData,
      String custName) async {
    final PrinterNetworkManager printerManager = PrinterNetworkManager();
    printerManager.selectPrinter(printerIp, port: 9100);

    final PosPrintResult res = await printerManager.printTicket(
        await DraftReceipt(taxJson, cartList, tableName, subTotal, grandTotal,
            tax, branchData, custName));

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

    ticket.setStyles(
        PosStyles(align: PosAlign.center, fontType: PosFontType.fontB));
    ticket.text(printerName + " Tested",
        styles: PosStyles(
            align: PosAlign.center, bold: true, width: PosTextSize.size1));

    ticket.text("Printer IP : " + printerIp,
        styles: PosStyles(
            align: PosAlign.center, bold: true, width: PosTextSize.size1));

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);

    ticket.text("Test Date time : " + timestamp,
        styles: PosStyles(align: PosAlign.center, bold: true));

    ticket.feed(2);
    ticket.cut();
    ticket.drawer();
    return ticket;
  }
}
