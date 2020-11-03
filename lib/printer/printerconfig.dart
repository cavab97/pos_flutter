import 'dart:async';
import 'dart:convert';
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
import 'package:mcncashier/models/OrderAttributes.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/Order_Modifire.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:image/image.dart';

class PrintReceipt {
  PaperSize paper = PaperSize.mm80;

  Future<Ticket> KOTReceipt(
      String tableName, List<MSTCartdetails> cartList, String pax) async {
    final profile = await CapabilityProfile.load();

    final Ticket ticket = Ticket(paper, profile);

    ticket.setStyles(
        PosStyles(align: PosAlign.center, fontType: PosFontType.fontA));

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
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    ticket.setStyles(PosStyles(align: PosAlign.left));
    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    ticket.text("Date : " + timestamp,
        styles: PosStyles(
          align: PosAlign.left,
          bold: true,
          fontType: PosFontType.fontB,
          width: PosTextSize.size2,
        ));

    ticket.hr();
    ticket.setStyles(PosStyles(align: PosAlign.left));
    ticket.row([
      PosColumn(
          text: 'Item',
          width: 10,
          styles: PosStyles(
            align: PosAlign.left,
            bold: true,
            fontType: PosFontType.fontA,
            width: PosTextSize.size2,
          )),
      PosColumn(
          text: 'Qty',
          width: 2,
          styles: PosStyles(
            align: PosAlign.left,
            bold: true,
            fontType: PosFontType.fontA,
            width: PosTextSize.size2,
          )),
    ]);
    ticket.hr();

    for (var i = 0; i < cartList.length; i++) {
      var item = cartList[i];
      if (item.isSendKichen == null) {
        ticket.row([
          PosColumn(
              text: item.productName,
              width: 10,
              styles: PosStyles(
                align: PosAlign.left,
                fontType: PosFontType.fontA,
                bold: false,
                width: PosTextSize.size2,
                height: PosTextSize.size1,
              )),
          PosColumn(
              text: item.productQty.toString(),
              width: 2,
              styles: PosStyles(
                align: PosAlign.left,
                fontType: PosFontType.fontA,
                width: PosTextSize.size2,
                bold: false,
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
                    width: PosTextSize.size2,
                    bold: false,
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
        .printTicket(await KOTReceipt(tableName, cartList, pax));

    CommunFun.showToast(ctx, res.msg);
  }

/*========================================================================
  ===========================Print Receipt==================================
  ========================================================================*/

  Future<Ticket> Receipt(
      Branch branchData,
      List taxJson,
      List<OrderDetail> orderdetail,
      List<OrderAttributes> orderAttr,
      List<OrderModifire> orderModifire,
      Orders orderData,
      Payments paymentdata,
      String tableName,
      var currency,
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

    ticket.setStyles(PosStyles(align: PosAlign.left));
    ticket.hr();
    ticket.setStyles(PosStyles(align: PosAlign.left));

    ticket.row([
      PosColumn(
          text: "Document No.",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: true,
          )),
      PosColumn(
          text: " : " + orderData.invoice_no,
          width: 8,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: true,
          )),
    ]);
    ticket.row([
      PosColumn(
          text: "Table",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: true,
          )),
      PosColumn(
          text: " : " + tableName,
          width: 8,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: true,
          )),
    ]);
    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    ticket.row([
      PosColumn(
          text: "Date",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: " : " + timestamp,
          width: 8,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);
    ticket.row([
      PosColumn(
          text: "Cashier",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: " : " + branchData.contactPerson,
          width: 8,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);
    ticket.row([
      PosColumn(
          text: "Customer",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: " : " + customerName,
          width: 8,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);

    ticket.setStyles(PosStyles(align: PosAlign.left));
    ticket.hr();
    ticket.row([
      PosColumn(
          text: 'Description',
          width: 5,
          styles: PosStyles(
              align: PosAlign.left, fontType: PosFontType.fontA, bold: true)),
      PosColumn(
          text: 'Qty',
          width: 1,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: true,
          )),
      PosColumn(
          text: 'Price',
          width: 3,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: true,
          )),
      PosColumn(
          text: 'Amount',
          width: 3,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: true,
          )),
    ]);
    ticket.row([
      PosColumn(
          text: '',
          width: 5,
          styles: PosStyles(
              align: PosAlign.left, fontType: PosFontType.fontA, bold: true)),
      PosColumn(
          text: '',
          width: 1,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: currency.toString(),
          width: 3,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: true,
          )),
      PosColumn(
          text: currency.toString(),
          width: 3,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: true,
          )),
    ]);
    ticket.hr();
    ticket.setStyles(PosStyles(align: PosAlign.left));

    for (var i = 0; i < orderdetail.length; i++) {
      var item = orderdetail[i];

      if (item.issetMeal == 1) {
        var setmealproduct = json.decode(item.setmeal_product_detail);
      }

      var name = jsonDecode(item.product_detail);
      ticket.row([
        PosColumn(
            text: name["name"].toString().trim(),
            width: 5,
            styles: PosStyles(
              align: PosAlign.left,
              fontType: PosFontType.fontA,
              bold: false,
            )),
        PosColumn(
            text: item.detail_qty.toStringAsFixed(0),
            width: 1,
            styles: PosStyles(
              align: PosAlign.right,
              fontType: PosFontType.fontA,
              bold: false,
            )),
        PosColumn(
            text: item.product_old_price.toStringAsFixed(2),
            width: 3,
            styles: PosStyles(
              align: PosAlign.right,
              fontType: PosFontType.fontA,
              bold: false,
            )),
        PosColumn(
            text: item.product_price.toStringAsFixed(2),
            width: 3,
            styles: PosStyles(
              align: PosAlign.right,
              fontType: PosFontType.fontA,
              bold: false,
            )),
      ]);

      ticket.setStyles(PosStyles(align: PosAlign.left));
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

      var contain =
          orderAttr.where((element) => element.detail_id == item.app_id);
      List<OrderAttributes> attrList = [];

      if (contain.isNotEmpty) {
        var jsonString = jsonEncode(contain.map((e) => e.toJson()).toList());
        attrList.addAll((json.decode(jsonString) as List)
            .map((i) => OrderAttributes.fromJson(i))
            .toList());
      }

      /*Print attributes without price*/
      if (attrList.length > 0) {
        ticket.row([
          PosColumn(
              text: "  " + attrList[0].name.trim(),
              width: 12,
              containsChinese: true,
              styles: PosStyles(
                align: PosAlign.left,
                fontType: PosFontType.fontA,
              ))
        ]);
      }

      var contain1 =
          orderModifire.where((element) => element.detail_id == item.app_id);
      List<OrderModifire> modiList = [];
      if (contain1.isNotEmpty) {
        var jsonString = jsonEncode(contain1.map((e) => e.toJson()).toList());
        modiList.addAll((json.decode(jsonString) as List)
            .map((i) => OrderModifire.fromJson(i))
            .toList());
      }

      /*Print Modifiers without price*/
      for (var m = 0; m < modiList.length; m++) {
        ticket.row([
          PosColumn(
              text: "  " +
                  modiList[m].name.trim() +
                  "@" +
                  modiList[m].om_amount.toStringAsFixed(2),
              width: 12,
              containsChinese: true,
              styles: PosStyles(
                align: PosAlign.left,
                fontType: PosFontType.fontA,
              ))
        ]);
      }
    }
    ticket.hr();
    ticket.setStyles(PosStyles(align: PosAlign.right));
    ticket.row([
      PosColumn(
          text: "SUB TOTAL : ",
          width: 8,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: orderData.sub_total.toStringAsFixed(2),
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);
    /* ticket.row([
      PosColumn(
          text: "Service Charge@10% : ",
          width: 8,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: "50.00",
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);*/

    if (taxJson.length > 0) {
      taxJson.forEach((element) {
        ticket.row([
          PosColumn(
              text: Strings.tax.toUpperCase() +
                  " " +
                  element["taxCode"] +
                  "@" +
                  element["rate"] +
                  "% : ",
              width: 8,
              styles: PosStyles(
                align: PosAlign.right,
                fontType: PosFontType.fontA,
                bold: false,
              )),
          PosColumn(
              text: element["taxAmount"].toString(),
              width: 4,
              styles: PosStyles(
                align: PosAlign.right,
                fontType: PosFontType.fontA,
                bold: false,
              ))
        ]);
      });
    }
    ticket.row([
      PosColumn(
          text: "PAYMENT TYPE : ",
          width: 8,
          styles: PosStyles(
              align: PosAlign.right, fontType: PosFontType.fontA, bold: false)),
      PosColumn(
          text: paymentdata.name.toString(),
          width: 4,
          styles: PosStyles(
              align: PosAlign.right, fontType: PosFontType.fontA, bold: false))
    ]);
    double total =
        double.parse(checkRoundData(orderData.grand_total.toStringAsFixed(2)));
    ticket.row([
      PosColumn(
          text: "Adjustment : ",
          width: 8,
          styles: PosStyles(
              align: PosAlign.right, fontType: PosFontType.fontA, bold: false)),
      PosColumn(
          text: calRounded(total, orderData.grand_total).toStringAsFixed(2),
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          ))
    ]);

    ticket.hr(len: 15);

    ticket.row([
      PosColumn(
          text: "Total : ",
          width: 8,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: true,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: total.toStringAsFixed(2),
          //orderData.grand_total.toStringAsFixed(2),
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: true,
            width: PosTextSize.size1,
          ))
    ]);
    ticket.hr(len: 15);
    ticket.hr();
    ticket.row([
      PosColumn(
          text: "Cash Received ",
          width: 8,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: total.toStringAsFixed(2),
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          ))
    ]);
    ticket.row([
      PosColumn(
          text: "Change ",
          width: 8,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: "0.00",
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          ))
    ]);
    ticket.hr();

    ticket.setStyles(PosStyles(align: PosAlign.center));
    /* ticket.emptyLines(1);
    ticket.qrcode('www.MCN.com', size: QRSize.Size5, align: PosAlign.center);*/
    ticket.emptyLines(1);

    ticket.text('Thank you!',
        styles: PosStyles(
          bold: true,
          align: PosAlign.center,
          fontType: PosFontType.fontA,
        ));
    ticket.text('Please visit us again',
        styles: PosStyles(
          bold: true,
          align: PosAlign.center,
          fontType: PosFontType.fontA,
        ));

    ticket.feed(1);
    ticket.cut();

    /*Open Drawer only when select payment method cash*/
    if (paymentdata.name.toString().toLowerCase() == "cash") {
      ticket.drawer();
    }
    return ticket;
  }

  String checkRoundData(String total) {
    var parts = total.split('.');
    //First values
    String prefix = parts[0].trim();
    //Second values
    String postFilx = parts[1].trim();

    String round = total;

    int tempValue = int.parse(postFilx.substring(1));
    if (tempValue != 0 && tempValue != 5) {
      if (tempValue <= 2) {
        round = prefix + "." + postFilx.substring(0, 1) + "0";
      } else if (tempValue <= 7) {
        print(postFilx.substring(0, 1));
        round = prefix + "." + postFilx.substring(0, 1) + "5";
        print(round);
      } else {
        int values = 0;
        if (int.parse(postFilx.substring(1)) == 9) {
          values = 1;
        } else {
          values = 2;
        }

        String tempRound = (int.parse(postFilx) + values).toString();
        double sum = 0.00;
        if (tempRound == "100") {
          sum = double.parse(prefix + ".00") + double.parse("1.00");
        } else {
          sum = double.parse(prefix + ".00") + double.parse("." + tempRound);
        }
        round = sum.toStringAsFixed(2);
      }
    }
    return round;
  }

  double calRounded(double total, double oldTotal) {
    if (total == oldTotal) {
      return 0.00;
    } else {
      return (total - oldTotal);
    }
  }

  void checkReceiptPrint(
      String printerIp,
      BuildContext ctx,
      Branch branchData,
      List taxJson,
      List<OrderDetail> orderdetail,
      List<OrderAttributes> orderAttr,
      List<OrderModifire> orderModifire,
      Orders orderData,
      Payments paymentdata,
      String tableName,
      var currency,
      String customerName) async {
    final PrinterNetworkManager printerManager = PrinterNetworkManager();
    printerManager.selectPrinter(printerIp, port: 9100);

    final PosPrintResult res = await printerManager.printTicket(await Receipt(
        branchData,
        taxJson,
        orderdetail,
        orderAttr,
        orderModifire,
        orderData,
        paymentdata,
        tableName,
        currency,
        customerName));

    CommunFun.showToast(ctx, res.msg);
  }

/*========================================================================
  ===========================Print Draft print==============================
  ========================================================================*/

  Future<Ticket> DraftReceipt(
      List taxJson,
      List<MSTCartdetails> cartList,
      String tableName,
      double subTotal,
      double grandTotal,
      double tax,
      Branch branchData,
      String currency,
      String custName) async {
    final profile = await CapabilityProfile.load();
    final Ticket ticket = Ticket(paper, profile);

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

    ticket.setStyles(PosStyles(align: PosAlign.left));
    ticket.hr();
    ticket.setStyles(PosStyles(align: PosAlign.left));

    ticket.row([
      PosColumn(
          text: "Table",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: true,
          )),
      PosColumn(
          text: " : " + tableName,
          width: 8,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: true,
          )),
    ]);
    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    ticket.row([
      PosColumn(
          text: "Date",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: " : " + timestamp,
          width: 8,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);
    ticket.row([
      PosColumn(
          text: "Cashier",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: " : " + branchData.contactPerson,
          width: 8,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);
    ticket.row([
      PosColumn(
          text: "Customer",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: " : " + custName,
          width: 8,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);

    ticket.setStyles(PosStyles(align: PosAlign.left));

    ticket.hr();
    ticket.row([
      PosColumn(
          text: 'Description',
          width: 5,
          styles: PosStyles(
              align: PosAlign.left, fontType: PosFontType.fontA, bold: true)),
      PosColumn(
          text: 'Qty',
          width: 1,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: true,
          )),
      PosColumn(
          text: 'Price',
          width: 3,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: true,
          )),
      PosColumn(
          text: 'Amount',
          width: 3,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: true,
          )),
    ]);
    ticket.row([
      PosColumn(
          text: '',
          width: 5,
          styles: PosStyles(
              align: PosAlign.left, fontType: PosFontType.fontA, bold: true)),
      PosColumn(
          text: '',
          width: 1,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: currency.toString(),
          width: 3,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: true,
          )),
      PosColumn(
          text: currency.toString(),
          width: 3,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: true,
          )),
    ]);
    ticket.hr();

    for (var i = 0; i < cartList.length; i++) {
      var total = cartList[i].productQty * cartList[i].productPrice;

      ticket.row([
        PosColumn(
            text: cartList[i].productName,
            width: 5,
            styles: PosStyles(
                align: PosAlign.left,
                fontType: PosFontType.fontA,
                bold: false)),
        PosColumn(
            text: cartList[i].productQty.toStringAsFixed(0),
            width: 1,
            styles: PosStyles(
              align: PosAlign.right,
              fontType: PosFontType.fontA,
              bold: false,
            )),
        PosColumn(
            text: cartList[i].productPrice.toStringAsFixed(2),
            width: 3,
            styles: PosStyles(
              align: PosAlign.right,
              fontType: PosFontType.fontA,
              bold: false,
            )),
        PosColumn(
            text: total.toStringAsFixed(2),
            width: 3,
            styles: PosStyles(
              align: PosAlign.right,
              fontType: PosFontType.fontA,
              bold: false,
            )),
      ]);
      ticket.setStyles(PosStyles(align: PosAlign.left));

      if (cartList[i].productSecondName != null) {
        if (cartList[i].productSecondName.isNotEmpty) {
          ticket.row([
            PosColumn(
                text: cartList[i].productSecondName.toString(),
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
          text: "SUB TOTAL : ",
          width: 8,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: subTotal.toStringAsFixed(2),
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);
    if (taxJson.length > 0) {
      taxJson.forEach((element) {
        ticket.row([
          PosColumn(
              text: Strings.tax.toUpperCase() +
                  " " +
                  element["taxCode"] +
                  "@" +
                  element["rate"] +
                  "% : ",
              width: 8,
              styles: PosStyles(
                align: PosAlign.right,
                fontType: PosFontType.fontA,
                bold: false,
              )),
          PosColumn(
              text: element["taxAmount"].toString(),
              width: 4,
              styles: PosStyles(
                align: PosAlign.right,
                fontType: PosFontType.fontA,
                bold: false,
              ))
        ]);
      });
    }

    double total = double.parse(checkRoundData(grandTotal.toStringAsFixed(2)));
    ticket.row([
      PosColumn(
          text: "Adjustment : ",
          width: 8,
          styles: PosStyles(
              align: PosAlign.right, fontType: PosFontType.fontA, bold: false)),
      PosColumn(
          text: calRounded(total, grandTotal).toStringAsFixed(2),
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          ))
    ]);

    ticket.hr(len: 15);

    ticket.row([
      PosColumn(
          text: "Total : ",
          width: 8,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: true,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: total.toStringAsFixed(2),
          //orderData.grand_total.toStringAsFixed(2),
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: true,
            width: PosTextSize.size1,
          ))
    ]);
    ticket.hr(len: 15);

    ticket.setStyles(PosStyles(align: PosAlign.center));
    /* ticket.emptyLines(1);
    ticket.qrcode('www.MCN.com', size: QRSize.Size5, align: PosAlign.center);*/
    ticket.emptyLines(1);

    ticket.text('Thank you!',
        styles: PosStyles(
          bold: true,
          align: PosAlign.center,
          fontType: PosFontType.fontA,
        ));
    ticket.text('Please visit us again',
        styles: PosStyles(
          bold: true,
          align: PosAlign.center,
          fontType: PosFontType.fontA,
        ));

    ticket.feed(1);
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
      String currency,
      String custName) async {
    final PrinterNetworkManager printerManager = PrinterNetworkManager();
    printerManager.selectPrinter(printerIp, port: 9100);

    final PosPrintResult res = await printerManager.printTicket(
        await DraftReceipt(taxJson, cartList, tableName, subTotal, grandTotal,
            tax, branchData, currency, custName));

    CommunFun.showToast(ctx, res.msg);
  }

/*========================================================================
  ===========================Print Order check list print==================
  ========================================================================*/

  Future<Ticket> CheckListReceipt(List<MSTCartdetails> cartList,
      String tableName, Branch branchData, String custName) async {
    final profile = await CapabilityProfile.load();
    final Ticket ticket = Ticket(paper, profile);

    // Print image
    ticket.setStyles(
        PosStyles(align: PosAlign.center, fontType: PosFontType.fontA));

    ticket.text("Customer Order",
        styles: PosStyles(
            fontType: PosFontType.fontA,
            bold: true,
            width: PosTextSize.size2,
            align: PosAlign.center));
    ticket.text("Check List",
        styles: PosStyles(
            fontType: PosFontType.fontA,
            bold: true,
            width: PosTextSize.size2,
            align: PosAlign.center));

    ticket.emptyLines(1);

    ticket.setStyles(PosStyles(align: PosAlign.left));
    ticket.hr();
    ticket.setStyles(PosStyles(align: PosAlign.left));

    ticket.row([
      PosColumn(
          text: "Table",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: true,
          )),
      PosColumn(
          text: " : " + tableName,
          width: 8,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: true,
          )),
    ]);
    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    ticket.row([
      PosColumn(
          text: "Date",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: " : " + timestamp,
          width: 8,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);
    ticket.row([
      PosColumn(
          text: "Cashier",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: " : " + branchData.contactPerson,
          width: 8,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);
    ticket.row([
      PosColumn(
          text: "Customer",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: " : " + custName,
          width: 8,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);

    ticket.setStyles(PosStyles(align: PosAlign.left));

    ticket.hr();
    ticket.row([
      PosColumn(
          text: 'Item',
          width: 7,
          styles: PosStyles(
              align: PosAlign.left, fontType: PosFontType.fontA, bold: true)),
      PosColumn(
          text: 'Qty',
          width: 2,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: true,
          )),
      PosColumn(
          text: 'Check',
          width: 3,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: true,
          )),
    ]);
    ticket.hr();

    double totalQTY = 0.0;

    for (var i = 0; i < cartList.length; i++) {
      totalQTY = totalQTY + cartList[i].productQty;
      ticket.row([
        PosColumn(
            text: cartList[i].productName,
            width: 7,
            styles: PosStyles(
                align: PosAlign.left,
                fontType: PosFontType.fontA,
                bold: false)),
        PosColumn(
            text: cartList[i].productQty.toStringAsFixed(0),
            width: 2,
            styles: PosStyles(
              align: PosAlign.right,
              fontType: PosFontType.fontA,
              bold: false,
            )),
        PosColumn(
            text: "[  ]",
            width: 3,
            styles: PosStyles(
              align: PosAlign.right,
              fontType: PosFontType.fontA,
              bold: false,
            )),
      ]);
      ticket.setStyles(PosStyles(align: PosAlign.left));

      if (cartList[i].productSecondName != null) {
        if (cartList[i].productSecondName.isNotEmpty) {
          ticket.row([
            PosColumn(
                text: cartList[i].productSecondName.toString(),
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
          text: "Total QTY:",
          width: 8,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: true,
          )),
      PosColumn(
          text: totalQTY.toStringAsFixed(1),
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: true,
          )),
    ]);
    ticket.hr();

    ticket.feed(1);
    ticket.cut();
    return ticket;
  }

  void checkListReceiptPrint(
      String printerIp,
      BuildContext ctx,
      List<MSTCartdetails> cartList,
      String tableName,
      Branch branchData,
      String custName) async {
    final PrinterNetworkManager printerManager = PrinterNetworkManager();
    printerManager.selectPrinter(printerIp, port: 9100);

    final PosPrintResult res = await printerManager.printTicket(
        await CheckListReceipt(cartList, tableName, branchData, custName));

    CommunFun.showToast(ctx, res.msg);
  }

/*========================================================================
  ===========================Test print=====================================
  ========================================================================*/

  void testReceiptPrint(String printerIp, BuildContext ctx, String printerName,
      String isFor) async {
    final PrinterNetworkManager printerManager = PrinterNetworkManager();
    printerManager.selectPrinter(printerIp, port: 9100);

    final PosPrintResult res = await printerManager
        .printTicket(await testPrintReceipt(printerName, printerIp, isFor));

    CommunFun.showToast(ctx, res.msg);
  }

  Future<Ticket> testPrintReceipt(
      String printerName, String printerIp, String isFor) async {
    final profile = await CapabilityProfile.load();
    final Ticket ticket = Ticket(paper, profile);

    if (isFor == "Testing") {
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
    }
    ticket.drawer();
    return ticket;
  }
}
