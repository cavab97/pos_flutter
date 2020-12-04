/*
import 'dart:convert';
import 'dart:typed_data';

import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:image/image.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/models/PorductDetails.dart';

class PrintReceipt {
  void checkKOTPrint(String printerIp, String tableName, BuildContext ctx,
      List<MSTCartdetails> cartList) async {
    Printer.connect(printerIp, port: 9100).then((printer) async {
      //  await printer.printQRCode('nhancv.com');
      printer.println('K.O.T',
          styles: PosStyles(
            fontType: PosFontType.fontA,
            bold: true,
            align: PosTextAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
          linesAfter: 1);

      final now = DateTime.now();
      final formatter = DateFormat('MM/dd/yyyy H:m');
      final String timestamp = formatter.format(now);
      printer.println("Date : " + timestamp,
          styles:
          PosStyles(align: PosTextAlign.left, fontType: PosFontType.fontB));
      printer.println('Table No : ' + tableName,
          styles:
          PosStyles(align: PosTextAlign.left, fontType: PosFontType.fontB));

      printer.println(Strings.print64line,
          styles: PosStyles(fontType: PosFontType.fontB));
      printer.printRow([
        PosColumn(
            text: 'Qty'.toUpperCase(),
            width: 2,
            styles: PosStyles(
                align: PosTextAlign.left, fontType: PosFontType.fontB)),
        PosColumn(
            text: 'Item'.toUpperCase(),
            width: 10,
            styles: PosStyles(
                align: PosTextAlign.left, fontType: PosFontType.fontB)),
      ]);

      printer.println(Strings.print64line,
          styles: PosStyles(fontType: PosFontType.fontB));

      for (var i = 0; i < cartList.length; i++) {
        var item = cartList[i];
        if (item.isSendKichen == null) {
          printer.printRow([
            PosColumn(
                text: item.productQty.toString(),
                width: 2,
                styles: PosStyles(
                    align: PosTextAlign.left, fontType: PosFontType.fontB)),
            PosColumn(
                text: item.productName,
                width: 10,
                styles: PosStyles(
                    align: PosTextAlign.left, fontType: PosFontType.fontB)),
          ]);
        }
      }
      printer.feed(2);
      printer.cut();
      printer.disconnect();
      //return ticket;
    }).catchError((error) {
      CommunFun.showToast(ctx, error.toString());
    });
  }

*/
/*========================================================================
  ===========================Print Receipt==================================
  ========================================================================*/ /*


  void checkReceiptPrint(
      String printerIp,
      BuildContext ctx,
      Branch branchData,
      List<ProductDetails> orderdItem,
      List<OrderDetail> orderdetail,
      Orders orderData,
      Payments paymentdata,
      String customerName) async {
    Printer.connect(printerIp, port: 9100).then((printer) async {
      final ByteData data =
      await rootBundle.load('assets/headerlogo_receipt.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final image = decodeImage(bytes);
      printer.printImage(image);

      printer.emptyLines(1);

      printer.println(branchData.address,
          styles: PosStyles(
              fontType: PosFontType.fontA,
              bold: true,
              width: PosTextSize.size1,
              align: PosTextAlign.center));
      printer.println("Contact No : " + branchData.contactNo,
          styles: PosStyles(
              fontType: PosFontType.fontA,
              align: PosTextAlign.center,
              bold: true));

      printer.emptyLines(1);

      final now = DateTime.now();
      final formatter = DateFormat('MM/dd/yyyy H:m');
      final String timestamp = formatter.format(now);

      printer.println('Processed by  : ' + branchData.contactPerson,
          styles:
          PosStyles(align: PosTextAlign.left, fontType: PosFontType.fontB));
      printer.println("Invoice Date : " + timestamp,
          styles:
          PosStyles(align: PosTextAlign.left, fontType: PosFontType.fontB));
      printer.println("Invoice No : " + orderData.invoice_no,
          styles:
          PosStyles(align: PosTextAlign.left, fontType: PosFontType.fontB));
      printer.println('Terminal Name : MCN002',
          styles:
          PosStyles(align: PosTextAlign.left, fontType: PosFontType.fontB));
      printer.println('Name : ' + customerName,
          styles:
          PosStyles(align: PosTextAlign.left, fontType: PosFontType.fontB));

      printer.println(Strings.print64line,
          styles:
          PosStyles(align: PosTextAlign.left, fontType: PosFontType.fontB));

      printer.printRow([
        PosColumn(
            text: 'ITEM',
            width: 5,
            styles: PosStyles(
                align: PosTextAlign.left, fontType: PosFontType.fontB)),
        PosColumn(
            text: 'QTY',
            width: 2,
            styles: PosStyles(
                align: PosTextAlign.right, fontType: PosFontType.fontB)),
        PosColumn(
            text: 'PRICE',
            width: 2,
            styles: PosStyles(
                align: PosTextAlign.right, fontType: PosFontType.fontB)),
        PosColumn(
            text: 'AMT',
            width: 3,
            styles: PosStyles(
                align: PosTextAlign.right, fontType: PosFontType.fontB)),
      ]);
      printer.println(Strings.print64line,
          styles:
          PosStyles(align: PosTextAlign.left, fontType: PosFontType.fontB));

      for (var i = 0; i < orderdetail.length; i++) {
        var item = orderdetail[i];
        var name = jsonDecode(item.product_detail);

        printer.printRow([
          PosColumn(
              text: name["name"],
              width: 5,
              styles: PosStyles(
                  align: PosTextAlign.left, fontType: PosFontType.fontB)),
          PosColumn(
              text: item.detail_qty.toString(),
              width: 2,
              styles: PosStyles(
                  align: PosTextAlign.right, fontType: PosFontType.fontB)),
          PosColumn(
              text: item.product_old_price.toStringAsFixed(2),
              width: 2,
              styles: PosStyles(
                  align: PosTextAlign.right, fontType: PosFontType.fontB)),
          PosColumn(
              text: item.product_price.toStringAsFixed(2),
              width: 3,
              styles: PosStyles(
                  align: PosTextAlign.right, fontType: PosFontType.fontB)),
        ]);
      }
      printer.println(Strings.print64line,
          styles:
          PosStyles(align: PosTextAlign.left, fontType: PosFontType.fontB));

      printer.printRow([
        PosColumn(
            text: "SUB TOTAL(MYR)",
            width: 8,
            styles: PosStyles(
                align: PosTextAlign.right, fontType: PosFontType.fontB)),
        PosColumn(
            text: orderData.sub_total.toStringAsFixed(2),
            width: 4,
            styles: PosStyles(
                align: PosTextAlign.right, fontType: PosFontType.fontB)),
      ]);
      printer.println(Strings.print64line,
          styles:
          PosStyles(align: PosTextAlign.left, fontType: PosFontType.fontB));

      printer.printRow([
        PosColumn(
            text: "TAX(MYR)",
            width: 8,
            styles: PosStyles(
                align: PosTextAlign.right, fontType: PosFontType.fontB)),
        PosColumn(
            text: orderData.tax_amount.toStringAsFixed(2),
            width: 4,
            styles: PosStyles(
                align: PosTextAlign.right, fontType: PosFontType.fontB))
      ]);
      printer.printRow([
        PosColumn(
            text: "GRAND TOTAL(MYR)",
            width: 8,
            styles: PosStyles(
                align: PosTextAlign.right, fontType: PosFontType.fontB)),
        PosColumn(
            text: orderData.grand_total.toStringAsFixed(2),
            width: 4,
            styles: PosStyles(
                align: PosTextAlign.right, fontType: PosFontType.fontB))
      ]);
      printer.printRow([
        PosColumn(
            text: "CASH(MYR)",
            width: 8,
            styles: PosStyles(
                align: PosTextAlign.right, fontType: PosFontType.fontB)),
        PosColumn(
            text: paymentdata.name.toString(),
            width: 4,
            styles: PosStyles(
                align: PosTextAlign.right, fontType: PosFontType.fontB))
      ]);

      printer.emptyLines(1);
      await printer.printQRCode('www.MCN.com',imgSize: 150);
      printer.emptyLines(1);

      printer.println('Thank you!',
          styles: PosStyles(
              bold: true,
              align: PosTextAlign.center,
              fontType: PosFontType.fontB));
      printer.println('Please visit us again',
          styles: PosStyles(
              bold: true,
              align: PosTextAlign.center,
              fontType: PosFontType.fontB));

      printer.feed(2);
      printer.cut();
      printer.openCashDrawer();
      printer.disconnect();
    }).catchError((error) {
      CommunFun.showToast(ctx, error.toString());
    });
  }

*/
/*========================================================================
  ===========================Print Draft print==================================
  ========================================================================*/ /*


  void checkDraftPrint(
      String printerIp,
      BuildContext ctx,
      List<MSTCartdetails> cartList,
      String tableName,
      double subTotal,
      double grandTotal,
      double tax,
      Branch branchData,
      String custName) async {
    // Print image
    Printer.connect(printerIp, port: 9100).then((printer) async {
      final ByteData data =
      await rootBundle.load('assets/headerlogo_receipt.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final image = decodeImage(bytes);

      printer.printImage(image);
      printer.emptyLines(1);

      printer.println(branchData.address,
          styles: PosStyles(
              fontType: PosFontType.fontA,
              bold: true,
              align: PosTextAlign.center,
              width: PosTextSize.size1));
      printer.println("Contact No : " + branchData.contactNo,
          styles: PosStyles(
              fontType: PosFontType.fontA,
              align: PosTextAlign.center,
              bold: true));

      printer.emptyLines(1);

      final now = DateTime.now();
      final formatter = DateFormat('MM/dd/yyyy H:m');
      final String timestamp = formatter.format(now);

      printer.println('Processed by  : ' + branchData.contactPerson,
          styles:
          PosStyles(align: PosTextAlign.left, fontType: PosFontType.fontB));
      printer.println("Invoice Date : " + timestamp,
          styles:
          PosStyles(align: PosTextAlign.left, fontType: PosFontType.fontB));
      printer.println('Terminal Name : MCN002',
          styles:
          PosStyles(align: PosTextAlign.left, fontType: PosFontType.fontB));
      printer.println('Name : ' + custName,
          styles:
          PosStyles(align: PosTextAlign.left, fontType: PosFontType.fontB));

      printer.println(Strings.print64line,
          styles:
          PosStyles(align: PosTextAlign.left, fontType: PosFontType.fontB));

      printer.printRow([
        PosColumn(
            text: 'ITEM',
            width: 6,
            styles: PosStyles(
                align: PosTextAlign.left, fontType: PosFontType.fontB)),
        PosColumn(
            text: 'QTY',
            width: 2,
            styles: PosStyles(
                align: PosTextAlign.right, fontType: PosFontType.fontB)),
        PosColumn(
            text: 'PRICE',
            width: 2,
            styles: PosStyles(
                align: PosTextAlign.right, fontType: PosFontType.fontB)),
        PosColumn(
            text: 'AMT',
            width: 2,
            styles: PosStyles(
                align: PosTextAlign.right, fontType: PosFontType.fontB)),
      ]);
      printer.println(Strings.print64line,
          styles:
          PosStyles(align: PosTextAlign.left, fontType: PosFontType.fontB));

      for (var i = 0; i < cartList.length; i++) {
        var total = cartList[i].productQty * cartList[i].productPrice;

        printer.printRow([
          PosColumn(
              text: cartList[i].productName,
              width: 6,
              styles: PosStyles(
                  align: PosTextAlign.left, fontType: PosFontType.fontB)),
          PosColumn(
              text: cartList[i].productQty.toString(),
              width: 2,
              styles: PosStyles(
                  align: PosTextAlign.right, fontType: PosFontType.fontB)),
          PosColumn(
              text: cartList[i].productPrice.toStringAsFixed(2),
              width: 2,
              styles: PosStyles(
                  align: PosTextAlign.right, fontType: PosFontType.fontB)),
          PosColumn(
              text: total.toStringAsFixed(2),
              width: 2,
              styles: PosStyles(
                  align: PosTextAlign.right, fontType: PosFontType.fontB)),
        ]);
      }
      printer.println(Strings.print64line,
          styles:
          PosStyles(align: PosTextAlign.left, fontType: PosFontType.fontB));

      printer.printRow([
        PosColumn(
            text: "SUB TOTAL(MYR)",
            width: 8,
            styles: PosStyles(
                align: PosTextAlign.right, fontType: PosFontType.fontB)),
        PosColumn(
            text: subTotal.toStringAsFixed(2),
            width: 4,
            styles: PosStyles(
                align: PosTextAlign.right, fontType: PosFontType.fontB)),
      ]);
      printer.println(Strings.print64line,
          styles:
          PosStyles(align: PosTextAlign.left, fontType: PosFontType.fontB));

      printer.printRow([
        PosColumn(
            text: "TAX(MYR)",
            width: 8,
            styles: PosStyles(
                align: PosTextAlign.right, fontType: PosFontType.fontB)),
        PosColumn(
            text: tax.toStringAsFixed(2),
            width: 4,
            styles: PosStyles(
                align: PosTextAlign.right, fontType: PosFontType.fontB)),
      ]);
      //ticket.hr();
      printer.printRow([
        PosColumn(
            text: "GRAND TOTAL(MYR)",
            width: 8,
            styles: PosStyles(
                align: PosTextAlign.right, fontType: PosFontType.fontB)),
        PosColumn(
            text: grandTotal.toStringAsFixed(2),
            width: 4,
            styles: PosStyles(
                align: PosTextAlign.right, fontType: PosFontType.fontB)),
      ]);

      printer.emptyLines(1);
      await printer.printQRCode('www.MCN.com', imgSize: 150);
      printer.emptyLines(1);

      printer.println('Thank you!',
          styles: PosStyles(
              bold: true,
              align: PosTextAlign.center,
              fontType: PosFontType.fontB));
      printer.println('Please visit us again',
          styles: PosStyles(
              bold: true,
              align: PosTextAlign.center,
              fontType: PosFontType.fontB));

      printer.feed(2);
      printer.cut();
      printer.disconnect();
    }).catchError((error) {
      CommunFun.showToast(ctx, error.toString());
    });
  }

*/
/*========================================================================
  ===========================Test print=====================================
  ========================================================================*/ /*


  void testReceiptPrint(
      String printerIp, BuildContext ctx, String printerName) async {
    Printer.connect(printerIp, port: 9100).then((printer) async {
      printer.println(printerName + " Tested",
          styles: PosStyles(
              align: PosTextAlign.center,
              bold: true,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB));

      printer.println("Printer IP : " + printerIp,
          styles: PosStyles(
              align: PosTextAlign.center,
              bold: true,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB));

      final now = DateTime.now();
      final formatter = DateFormat('MM/dd/yyyy H:m');
      final String timestamp = formatter.format(now);

      printer.println("Test Date time : " + timestamp,
          styles: PosStyles(
              align: PosTextAlign.center,
              bold: true,
              fontType: PosFontType.fontB));

      printer.feed(2);
      printer.cut();
      printer.openCashDrawer();
      printer.disconnect();
    }).catchError((error) {
      CommunFun.showToast(ctx, error.toString());
    });
  }
}
*/
