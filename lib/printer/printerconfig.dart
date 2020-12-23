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
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/Order_Modifire.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:image/image.dart';
import 'package:mcncashier/models/SetMealProduct.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/models/Terminal.dart';

class PrintReceipt {
  PaperSize paper = PaperSize.mm80;
  String receipt48CharHeader =
      "Description                 Qty   Price  Amount";

  Future<Ticket> KOTReceipt(String tableName, List<MSTCartdetails> cartList,
      String pax, bool isReprint) async {
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

    ticket.text('Pax : ' + (pax ?? 0),
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
    ticket.text("Terminal : " + Strings.terminalName,
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
          text: 'Qty',
          width: 2,
          styles: PosStyles(
            align: PosAlign.left,
            bold: true,
            fontType: PosFontType.fontA,
            width: PosTextSize.size2,
          )),
      PosColumn(
          text: 'Description',
          width: 10,
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
      if (item.isSendKichen == null || isReprint) {
        ticket.row([
          PosColumn(
              text: item.productQty.toStringAsFixed(0),
              width: 2,
              styles: PosStyles(
                align: PosAlign.left,
                fontType: PosFontType.fontA,
                width: PosTextSize.size2,
                bold: false,
              )),
          PosColumn(
              text: item.productName,
              width: 10,
              containsChinese: true,
              styles: PosStyles(
                align: PosAlign.left,
                fontType: PosFontType.fontA,
                bold: false,
                width: PosTextSize.size2,
                height: PosTextSize.size1,
              )),
        ]);
        //second Name
        if (item.productSecondName != null) {
          if (item.productSecondName.isNotEmpty) {
            ticket.row([
              PosColumn(
                  text: "",
                  width: 2,
                  styles: PosStyles(
                    align: PosAlign.left,
                    fontType: PosFontType.fontA,
                    width: PosTextSize.size2,
                    bold: false,
                  )),
              PosColumn(
                  text: item.productSecondName.toString(),
                  width: 10,
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

        /*For set meal product*/
        if (item.issetMeal == 1) {
          List<dynamic> setmealproduct =
              json.decode(item.setmeal_product_detail);
          List<SetMealProduct> setMealProducts = [];
          if (setmealproduct[0] != null) {
            setMealProducts = setmealproduct.isNotEmpty
                ? setmealproduct.map((c) => SetMealProduct.fromJson(c)).toList()
                : [];
          }

          setMealProducts.forEach((element) {
            ticket.row([
              PosColumn(
                  text: "",
                  width: 2,
                  styles: PosStyles(
                    align: PosAlign.left,
                    fontType: PosFontType.fontA,
                    width: PosTextSize.size2,
                    bold: false,
                  )),
              PosColumn(
                  text: " " +
                      element.quantity.toStringAsFixed(0) +
                      " x " +
                      element.name.toString().trim(),
                  width: 10,
                  containsChinese: true,
                  styles: PosStyles(
                    align: PosAlign.left,
                    fontType: PosFontType.fontA,
                    width: PosTextSize.size2,
                    bold: false,
                  ))
            ]);
          });
        }
        /*Print attributes without price*/
        if (cartList[i].attrName != null) {
          List<String> attributes = cartList[i].attrName.split(",");
          if (attributes.length > 0) {
            for (var a = 0; a < attributes.length; a++) {
              ticket.row([
                PosColumn(
                    text: "",
                    width: 2,
                    styles: PosStyles(
                      align: PosAlign.left,
                      fontType: PosFontType.fontA,
                      width: PosTextSize.size2,
                      bold: false,
                    )),
                PosColumn(
                    text: " " + "(" + attributes[a] + ")",
                    width: 10,
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
        //modifier
        if (item.modiName != null) {
          if (item.modiName.isNotEmpty) {
            ticket.row([
              PosColumn(
                  text: "",
                  width: 2,
                  styles: PosStyles(
                    align: PosAlign.left,
                    fontType: PosFontType.fontA,
                    width: PosTextSize.size2,
                    bold: false,
                  )),
              PosColumn(
                  text: " " + item.modiName.toString(),
                  width: 10,
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
        //remarks

        if (cartList[i].remark != null) {
          // List<String> attributes = cartList[i].attrName.split(",");
          if (cartList[i].remark.length > 0) {
            ticket.row([
              PosColumn(
                  text: " ",
                  width: 2,
                  styles: PosStyles(
                    align: PosAlign.left,
                    fontType: PosFontType.fontA,
                    width: PosTextSize.size1,
                    bold: false,
                  )),
              PosColumn(
                  text: "Remark:" + "***" + cartList[i].remark,
                  width: 10,
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
      List<MSTCartdetails> cartList, String pax, bool isReprint) async {
    final PrinterNetworkManager printerManager = PrinterNetworkManager();
    printerManager.selectPrinter(printerIp, port: 9100);
    final PosPrintResult res = await printerManager
        .printTicket(await KOTReceipt(tableName, cartList, pax, isReprint));

    await CommunFun.showToast(ctx, res.msg);
  }

/*========================================================================
  ===========================Print Receipt==================================
  ========================================================================*/

  Future<Ticket> Receipt(
      String pax,
      Branch branchData,
      List taxJson,
      List<OrderDetail> orderdetail,
      List<OrderAttributes> orderAttr,
      List<OrderModifire> orderModifire,
      Orders orderData,
      List<OrderPayment> paymentdata,
      List<Payments> paymentMethods,
      String tableName,
      var currency,
      String customerName,
      ctx,
      bool isFor,
      bool isper) async {
    bool isCashPayment = false;
    double cashPaymentTotal = 0.00;
    double cashPaymentChange = 0.00;

    final profile = await CapabilityProfile.load();
    final Ticket ticket = Ticket(paper, profile);

    // Print image
    ticket.setStyles(
        PosStyles(align: PosAlign.center, fontType: PosFontType.fontA));

    final ByteData data =
        await rootBundle.load('assets/headerlogo_receipt.png');

    var strImage;
    Uint8List bytes = data.buffer.asUint8List();
    if (branchData != null) {
      strImage = branchData.base64;
      if (branchData.base64.contains("base64,")) {
        strImage = branchData.base64.split("base64,")[1];
      }
      bytes = base64Decode(strImage);
    }

    ticket.image(decodeImage(bytes));

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
          text: "Invoice No.",
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
          text: "Pax",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: " : " + (pax ?? 0),
          width: 8,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);
    ticket.row([
      PosColumn(
          text: "Terminal",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: " : " + Strings.terminalName,
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

    /*For font - A size 1 = 4 Character print */
    ticket.hr();
    ticket.text("$receipt48CharHeader",
        styles: PosStyles(
            align: PosAlign.left, fontType: PosFontType.fontA, bold: true));
    String priceCurrency = printColumnWitSpace(37, currency, true);
    String amountCurrency = printColumnWitSpace(8, currency, true);
    ticket.text("$priceCurrency$amountCurrency",
        styles: PosStyles(
            align: PosAlign.left, fontType: PosFontType.fontA, bold: true));

    ticket.hr();
    ticket.setStyles(PosStyles(align: PosAlign.left));

    for (var i = 0; i < orderdetail.length; i++) {
      var item = orderdetail[i];

      var name = jsonDecode(item.product_detail);
      double price =
          item.detail_amount != null ? item.detail_amount : item.product_price;
      String nameOfProduct =
          printColumnWitSpace(0, name["name"].toString().trim(), false);
      String qtyOfProduct =
          printColumnWitSpace(0, item.detail_qty.toStringAsFixed(0), true);
      String priceOfProduct = printColumnWitSpace(
          0,
          (item.product_old_price != null && item.product_old_price > 0
              ? item.product_old_price.toStringAsFixed(2)
              : (price / item.detail_qty).toStringAsFixed(2)),
          true);
      String amountOfProduct =
          printColumnWitSpace(0, price.toStringAsFixed(2), true);

      // ticket.text("$nameOfProduct$qtyOfProduct$priceOfProduct$amountOfProduct",
      //     containsChinese: true,
      //     styles: PosStyles(
      //         align: PosAlign.left, fontType: PosFontType.fontA, bold: false));

      ticket.row([
        PosColumn(
            text: nameOfProduct,
            width: 7,
            styles: PosStyles(
              // align: PosAlign.left,
              fontType: PosFontType.fontA,
              bold: false,
            )),
        PosColumn(
            text: qtyOfProduct,
            width: 1,
            styles: PosStyles(
              align: PosAlign.right,
              fontType: PosFontType.fontA,
              bold: false,
            )),
        PosColumn(
            text: priceOfProduct,
            width: 2,
            styles: PosStyles(
              align: PosAlign.right,
              fontType: PosFontType.fontA,
              bold: false,
            )),
        PosColumn(
            text: amountOfProduct,
            width: 2,
            styles: PosStyles(
              align: PosAlign.right,
              fontType: PosFontType.fontA,
              bold: false,
            )),
      ]);

      // ticket.setStyles(PosStyles(align: PosAlign.left));
      // if (name["name_2"] != null) {
      //   if (name["name_2"].isNotEmpty) {
      //     ticket.row([
      //       PosColumn(
      //           text: name["name_2"].toString(),
      //           width: 5,
      //           containsChinese: true,
      //           styles: PosStyles(
      //             align: PosAlign.left,
      //             fontType: PosFontType.fontA,
      //           )),
      //       PosColumn(
      //           text: name["name_2"].toString(),
      //           width: 7,
      //           containsChinese: true,
      //           styles: PosStyles(
      //             align: PosAlign.left,
      //             fontType: PosFontType.fontA,
      //           ))
      //     ]);
      //   }
      // }

      /*For set meal product*/
      if (item.issetMeal == 1 && item.setmeal_product_detail != null) {
        List<dynamic> setmealproduct = json.decode(item.setmeal_product_detail);
        List<SetMealProduct> setMealProducts = [];
        if (setmealproduct[0] != null) {
          setMealProducts = setmealproduct.isNotEmpty
              ? setmealproduct.map((c) => SetMealProduct.fromJson(c)).toList()
              : [];
        }

        setMealProducts.forEach((element) {
          ticket.text(
            " " +
                element.quantity.toStringAsFixed(0) +
                " x " +
                element.name.toString().trim(),
            styles: PosStyles(
                align: PosAlign.left, fontType: PosFontType.fontA, bold: false),
            containsChinese: true,
          );
        });
      }

      var contain =
          orderAttr.where((element) => element.detail_app_id == item.app_id);
      List<OrderAttributes> attrList = [];

      if (contain.isNotEmpty) {
        var jsonString = jsonEncode(contain.map((e) => e.toJson()).toList());
        attrList.addAll((json.decode(jsonString) as List)
            .map((i) => OrderAttributes.fromJson(i))
            .toList());
      }

      /*Print attributes without price*/
      if (attrList.length > 0) {
        for (var a = 0; a < attrList.length; a++) {
          ticket.row([
            PosColumn(
                text: "  " +
                    (attrList[a].name != null ? attrList[a].name.trim() : ""),
                width: 12,
                containsChinese: true,
                styles: PosStyles(
                  align: PosAlign.left,
                  fontType: PosFontType.fontA,
                ))
          ]);
        }
      }

      var contain1 = orderModifire
          .where((element) => element.detail_app_id == item.app_id);
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
          text: "Sub Total ",
          width: 8,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: orderData.sub_total.toStringAsFixed(2) + "  ",
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);
    ticket.row([
      PosColumn(
          text: "Service Charge(" +
              orderData.serviceChargePercent.toString() +
              "%) ",
          width: 8,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: orderData.serviceCharge.toStringAsFixed(2) + "  ",
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
                  "%  ",
              width: 8,
              styles: PosStyles(
                align: PosAlign.right,
                fontType: PosFontType.fontA,
                bold: false,
              )),
          PosColumn(
              text: element["taxAmount"].toString() + "  ",
              width: 4,
              styles: PosStyles(
                align: PosAlign.right,
                fontType: PosFontType.fontA,
                bold: false,
              ))
        ]);
      });
    }

    double total =
        double.parse(checkRoundData(orderData.grand_total.toStringAsFixed(2)));
    ticket.row([
      PosColumn(
          text: "Adjustment ",
          width: 8,
          styles: PosStyles(
              align: PosAlign.right, fontType: PosFontType.fontA, bold: false)),
      PosColumn(
          text: orderData.rounding_amount.toStringAsFixed(2) +
              "  ", //calRounded(total, orderData.grand_total).toStringAsFixed(2),
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          ))
    ]);

    // ticket.text(printColumnWitSpace(0, Strings.print15line, true),
    //     styles: PosStyles(
    //       align: PosAlign.right,
    //       fontType: PosFontType.fontA,
    //     ));
    ticket.row([
      PosColumn(
          text: "-----------------------------------------------",
          width: 12,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);
    ticket.row([
      PosColumn(
          text: "Total ",
          width: 8,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: true,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: total.toStringAsFixed(2) + "  ",
          //orderData.grand_total.toStringAsFixed(2),
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: true,
            width: PosTextSize.size1,
          ))
    ]);
    // ticket.text(printColumnWitSpace(48, Strings.print15line, true),
    //     styles: PosStyles(
    //       align: PosAlign.right,
    //       fontType: PosFontType.fontA,
    //     ));
    // ticket.hr();
    // ticket.setStyles(PosStyles(align: PosAlign.right));

    for (int p = 0; p < paymentMethods.length; p++) {
      if (paymentMethods[p].name.toLowerCase() == "cash") {
        isCashPayment = true;
        cashPaymentTotal = cashPaymentTotal + paymentdata[p].op_amount;
        cashPaymentChange = cashPaymentChange +
            (paymentdata[p].op_amount_change == null
                ? 0.00
                : paymentdata[p].op_amount_change);
      }
    }

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
          text: cashPaymentTotal.toStringAsFixed(2) + "  ",
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
          text: cashPaymentChange > 0
              ? "-" + cashPaymentChange.toStringAsFixed(2) + "  "
              : cashPaymentChange.toStringAsFixed(2) +
                  "  ", //(paymentdaWta.length > 0 ? paymentdata[0].op_amount_change :
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          ))
    ]);

    ticket.hr();
    ticket.setStyles(PosStyles(align: PosAlign.right));

    for (int p = 0; p < paymentMethods.length; p++) {
      double amount = 0.00;
      if (paymentMethods[p].name.toLowerCase() == "cash") {
        amount = cashPaymentTotal - cashPaymentChange;
      } else if (paymentMethods[p].name.toLowerCase() == "Entertainment Bill") {
        amount = total;
      } else {
        amount = paymentdata[p].op_amount;
      }
      ticket.row([
        PosColumn(
            text: paymentMethods[p].name.toString() + " ",
            width: 8,
            styles: PosStyles(
              align: PosAlign.right,
              fontType: PosFontType.fontA,
              bold: false,
            )),
        PosColumn(
            text: amount.toStringAsFixed(2) + "  ",
            width: 4,
            styles: PosStyles(
              align: PosAlign.right,
              fontType: PosFontType.fontA,
              bold: false,
            ))
      ]);
    }

    ticket.emptyLines(1);
    ticket.setStyles(PosStyles(align: PosAlign.center));
    /* ticket.emptyLines(1);
    ticket.qrcode('www.MCN.com', size: QRSize.Size5, align: PosAlign.center);*/

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
    if (isFor) {
      ticket.emptyLines(1);
      ticket.text('Duplicate',
          styles: PosStyles(
            width: PosTextSize.size2,
            bold: true,
            align: PosAlign.center,
            fontType: PosFontType.fontA,
          ));
    }
    ticket.feed(1);
    ticket.cut();

    /*Open Drawer only when select payment method cash*/
    if (isCashPayment) {
      ticket.drawer();
    }
    return ticket;
  }

  void checkReceiptPrint(
      String pax,
      String printerIp,
      BuildContext ctx,
      Branch branchData,
      List taxJson,
      List<OrderDetail> orderdetail,
      List<OrderAttributes> orderAttr,
      List<OrderModifire> orderModifire,
      Orders orderData,
      List<OrderPayment> paymentdata,
      List<Payments> paymentMethods,
      String tableName,
      var currency,
      String customerName,
      isFor,
      isper) async {
    final PrinterNetworkManager printerManager = PrinterNetworkManager();
    printerManager.selectPrinter(printerIp, port: 9100);

    final PosPrintResult res = await printerManager.printTicket(await Receipt(
        pax,
        branchData,
        taxJson,
        orderdetail,
        orderAttr,
        orderModifire,
        orderData,
        paymentdata,
        paymentMethods,
        tableName,
        currency,
        customerName,
        ctx,
        isFor,
        isper));
    await CommunFun.showToast(ctx, res.msg);
  }

/*========================================================================
  ===========================Print Draft print==============================
  ========================================================================*/

  Future<Ticket> DraftReceipt(
      String pax,
      List taxJson,
      List<MSTCartdetails> cartList,
      String tableName,
      double subTotal,
      double serviceChargePer,
      double serviceCharge,
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
    var strImage;
    Uint8List bytes = data.buffer.asUint8List();
    if (branchData != null) {
      strImage = branchData.base64;
      if (branchData.base64.contains("base64,")) {
        strImage = branchData.base64.split("base64,")[1];
      }
      bytes = base64Decode(strImage);
    }
    ticket.image(decodeImage(bytes));
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
          text: "Terminal",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: " : " + Strings.terminalName,
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
    ticket.row([
      PosColumn(
          text: "Pax",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: " : " + (pax ?? 0),
          width: 8,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);
    ticket.setStyles(PosStyles(align: PosAlign.left));

    ticket.hr();
    ticket.text("$receipt48CharHeader",
        styles: PosStyles(
            align: PosAlign.left, fontType: PosFontType.fontA, bold: true));
    String priceCurrency = printColumnWitSpace(40, currency, true);
    String amountCurrency = printColumnWitSpace(8, currency, true);
    ticket.text("$priceCurrency$amountCurrency",
        styles: PosStyles(
            align: PosAlign.left, fontType: PosFontType.fontA, bold: true));
    ticket.hr();

    for (var i = 0; i < cartList.length; i++) {
      //var total = cartList[i].productQty * cartList[i].productPrice;

      String nameOfProduct = printColumnWitSpace(
          28, cartList[i].productName.toString().trim(), false);
      String qtyOfProduct = printColumnWitSpace(
          4, cartList[i].productQty.toStringAsFixed(0), true);
      String priceOfProduct = printColumnWitSpace(
          8, cartList[i].productPrice.toStringAsFixed(2), true);
      String amountOfProduct = printColumnWitSpace(
          8, cartList[i].productDetailAmount.toStringAsFixed(2), true);

      ticket.text("$nameOfProduct$qtyOfProduct$priceOfProduct$amountOfProduct",
          containsChinese: true,
          styles: PosStyles(
              align: PosAlign.left, fontType: PosFontType.fontA, bold: false));

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

      /*For set meal product*/
      if (cartList[i].issetMeal == 1) {
        List<dynamic> setmealproduct =
            json.decode(cartList[i].setmeal_product_detail);
        List<SetMealProduct> setMealProducts = [];
        if (setmealproduct[0] != null) {
          setMealProducts = setmealproduct.isNotEmpty
              ? setmealproduct.map((c) => SetMealProduct.fromJson(c)).toList()
              : [];
        }

        setMealProducts.forEach((element) {
          ticket.text(
              " " +
                  element.quantity.toStringAsFixed(0) +
                  " x " +
                  element.name.toString().trim(),
              styles: PosStyles(
                  align: PosAlign.left,
                  fontType: PosFontType.fontA,
                  bold: false));
        });
      }
      /*Print attributes without price*/
      /*Print attributes without price*/
      if (cartList[i].attrName != null) {
        List<String> attributes = cartList[i].attrName.split(",");
        if (attributes.length > 0) {
          for (var a = 0; a < attributes.length; a++) {
            ticket.row([
              PosColumn(
                  text: "  " + attributes[a],
                  width: 12,
                  containsChinese: true,
                  styles: PosStyles(
                    align: PosAlign.left,
                    fontType: PosFontType.fontA,
                    bold: false,
                  ))
            ]);
          }
        }
      }
    }
    ticket.hr();
    ticket.setStyles(PosStyles(align: PosAlign.right));
    ticket.row([
      PosColumn(
          text: "Sub Total : ",
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
    ticket.row([
      PosColumn(
          text: "Service Charge($serviceChargePer%) : ",
          width: 8,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: serviceCharge.toStringAsFixed(2),
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
    ticket.text(printColumnWitSpace(48, Strings.print15line, true),
        styles: PosStyles(
          align: PosAlign.right,
          fontType: PosFontType.fontA,
        ));
    ticket.setStyles(PosStyles(align: PosAlign.right));

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
    ticket.text(printColumnWitSpace(48, Strings.print15line, true),
        styles: PosStyles(
          align: PosAlign.right,
          fontType: PosFontType.fontA,
        ));
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

  void cashInPrint(
      String printerIp,
      BuildContext ctx,
      String title,
      String reason,
      Branch branchData,
      Terminal terminalData,
      String type,
      double amount) async {
    final PrinterNetworkManager printerManager = PrinterNetworkManager();
    printerManager.selectPrinter(printerIp, port: 9100);

    final PosPrintResult res = await printerManager.printTicket(
        await CashInPrint(printerIp, ctx, title, reason, branchData,
            terminalData, type, amount));

    CommunFun.showToast(ctx, res.msg);
  }

/*========================================================================
  ===========================Print Cash in==================
  ========================================================================*/

  Future<Ticket> CashInPrint(
      String printerIp,
      BuildContext ctx,
      String title,
      String reason,
      Branch branchData,
      Terminal terminalData,
      String type,
      double amount) async {
    final profile = await CapabilityProfile.load();
    final Ticket ticket = Ticket(paper, profile);

    ticket.setStyles(
        PosStyles(align: PosAlign.center, fontType: PosFontType.fontA));

    ticket.text(title,
        styles: PosStyles(
            fontType: PosFontType.fontA,
            bold: true,
            width: PosTextSize.size2,
            align: PosAlign.center));
    ticket.emptyLines(1);

    ticket.text(branchData.name,
        styles: PosStyles(
            fontType: PosFontType.fontA,
            bold: true,
            width: PosTextSize.size1,
            align: PosAlign.center));

    ticket.text(branchData.address,
        styles: PosStyles(
            fontType: PosFontType.fontA,
            bold: true,
            width: PosTextSize.size1,
            align: PosAlign.center));

    ticket.emptyLines(1);

    ticket.setStyles(PosStyles(align: PosAlign.left));
    ticket.hr();
    ticket.setStyles(PosStyles(align: PosAlign.left));
    ticket.row([
      PosColumn(
          text: "Terminal : ",
          width: 3,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: terminalData.terminalName,
          width: 9,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);

    ticket.row([
      PosColumn(
          text: "Cashier  : ",
          width: 3,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: branchData.contactPerson,
          width: 9,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy HH:mm');
    final String timestamp = formatter.format(now);
    ticket.row([
      PosColumn(
          text: "Date     : ",
          width: 3,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: timestamp,
          width: 9,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);

    ticket.row([
      PosColumn(
          text: "Amount   : ",
          width: 3,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: "RM " + amount.toStringAsFixed(2),
          width: 9,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);

    ticket.row([
      PosColumn(
          text: "Type     : ",
          width: 3,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: type[0].toUpperCase() + type.substring(1),
          width: 9,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);

    type == "other"
        ? ticket.row([
            PosColumn(
                text: "Remark   : ",
                width: 3,
                styles: PosStyles(
                  align: PosAlign.left,
                  fontType: PosFontType.fontA,
                  bold: false,
                )),
            PosColumn(
                text: CommunFun.getTextAndSplit(
                        reason[0].toUpperCase() + reason.substring(1))
                    .toString(),
                width: 9,
                styles: PosStyles(
                  align: PosAlign.left,
                  fontType: PosFontType.fontA,
                  bold: false,
                )),
          ])
        : ticket.emptyLines(1);
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
      double serviceChargePer,
      double serviceCharge,
      double grandTotal,
      double tax,
      Branch branchData,
      String currency,
      String pax,
      String custName) async {
    final PrinterNetworkManager printerManager = PrinterNetworkManager();
    printerManager.selectPrinter(printerIp, port: 9100);

    final PosPrintResult res = await printerManager.printTicket(
        await DraftReceipt(
            pax,
            taxJson,
            cartList,
            tableName,
            subTotal,
            serviceChargePer,
            serviceCharge,
            grandTotal,
            tax,
            branchData,
            currency,
            custName));

    CommunFun.showToast(ctx, res.msg);
  }

/*========================================================================
  ===========================Print Order check list print==================
  ========================================================================*/

  Future<Ticket> CheckListReceipt(List<MSTCartdetails> cartList,
      String tableName, Branch branchData, String pax, String custName) async {
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
    ticket.row([
      PosColumn(
          text: "Pax",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: " : " + (pax ?? 0),
          width: 8,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
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
          text: "Terminal",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: " : " + Strings.terminalName,
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
            containsChinese: true,
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
      /*For set meal product*/
      if (cartList[i].issetMeal == 1) {
        List<dynamic> setmealproduct =
            json.decode(cartList[i].setmeal_product_detail);
        List<SetMealProduct> setMealProducts = [];
        if (setmealproduct[0] != null) {
          setMealProducts = setmealproduct.isNotEmpty
              ? setmealproduct.map((c) => SetMealProduct.fromJson(c)).toList()
              : [];
        }

        setMealProducts.forEach((element) {
          ticket.text(
              " " +
                  element.quantity.toStringAsFixed(0) +
                  " x " +
                  element.name.toString().trim(),
              styles: PosStyles(
                  align: PosAlign.left,
                  fontType: PosFontType.fontA,
                  bold: false));
        });
      }
      /*Print attributes without price*/
      if (cartList[i].attrName != null) {
        List<String> attributes = cartList[i].attrName.split(",");
        if (attributes.length > 0) {
          for (var a = 0; a < attributes.length; a++) {
            ticket.row([
              PosColumn(
                  text: "  " + attributes[a],
                  width: 12,
                  containsChinese: true,
                  styles: PosStyles(
                    align: PosAlign.left,
                    fontType: PosFontType.fontA,
                    bold: false,
                  ))
            ]);
          }
        }
      }
    }
    ticket.hr();
    // ticket.setStyles(PosStyles(align: PosAlign.right));
    ticket.row([
      PosColumn(
          text: "Total QTY:",
          width: 9,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: true,
          )),
      PosColumn(
          text: totalQTY.toStringAsFixed(0) + " ",
          width: 3,
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
      String pax,
      String custName) async {
    final PrinterNetworkManager printerManager = PrinterNetworkManager();
    printerManager.selectPrinter(printerIp, port: 9100);

    final PosPrintResult res = await printerManager.printTicket(
        await CheckListReceipt(cartList, tableName, branchData, pax, custName));

    CommunFun.showToast(ctx, res.msg);
  }

/*========================================================================
  ===========================Print Shift Report==================
  ========================================================================*/

  Future<Ticket> shiftReportReceipt(
      Branch branchData,
      int totalPax,
      Terminal terminalData,
      var grosssale,
      var refundval,
      var discountval,
      var netsale,
      var taxval,
      var serviceTax,
      var roundingAmount,
      var totalRend,
      Shift shift,
      var cashSale,
      var cashDeposit,
      var cashRefund,
      var cashRounding,
      var payInAmount,
      var payOutAmmount,
      var expectedVal,
      List<OrderPayment> orderPayments,
      List<Payments> paymentMethods,
      var ordersCount) async {
    final profile = await CapabilityProfile.load();
    final Ticket ticket = Ticket(paper, profile);

    ticket.setStyles(
        PosStyles(align: PosAlign.center, fontType: PosFontType.fontA));

    ticket.text("Shift Report",
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
          text: "Branch Name",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: " : " + branchData.name,
          width: 8,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);
    ticket.row([
      PosColumn(
          text: "Terminal",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: " : " + terminalData.terminalName,
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
          text: "Start Date",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: " : " + shift.createdAt,
          width: 8,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);
    ticket.row([
      PosColumn(
          text: "End Date",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: " : " + (shift.updatedAt != null ? shift.updatedAt : ""),
          width: 8,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);
    ticket.row([
      PosColumn(
          text: "Pax Count",
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: " : " + totalPax.toString(),
          width: 8,
          styles: PosStyles(
            align: PosAlign.left,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);

    /*
    *For Print summery
    */
    ticket.setStyles(PosStyles(align: PosAlign.center));
    ticket.emptyLines(2);
    ticket.text("Summery",
        styles: PosStyles(
            fontType: PosFontType.fontA,
            bold: true,
            width: PosTextSize.size2,
            align: PosAlign.center));
    ticket.hr();

    ticket.setStyles(PosStyles(align: PosAlign.left));
    /*For summery 48 char*/
    String grossSales = printColumnWitSpace(38, "Gross Sales", false);
    String grossSalesAmt =
        printColumnWitSpace(10, grosssale.toStringAsFixed(2), true);
    ticket.text("$grossSales$grossSalesAmt",
        styles: PosStyles(
            align: PosAlign.left, fontType: PosFontType.fontA, bold: false));

    /*For Refunds 48 char*/
    String refunds = printColumnWitSpace(38, "Refunds", false);
    String refundsAmt =
        printColumnWitSpace(10, refundval.toStringAsFixed(2), true);
    ticket.text("$refunds$refundsAmt",
        styles: PosStyles(
            align: PosAlign.left, fontType: PosFontType.fontA, bold: false));

    /*For Discount 48 char*/
    String discount = printColumnWitSpace(38, "Discount", false);
    String discountAmt =
        printColumnWitSpace(10, discountval.toStringAsFixed(2), true);
    ticket.text("$discount$discountAmt",
        styles: PosStyles(
            align: PosAlign.left, fontType: PosFontType.fontA, bold: false));

    /*For Net Sales 48 char*/
    String netSales = printColumnWitSpace(38, "Net Sales", false);
    String netSalesAmt =
        printColumnWitSpace(10, netsale.toStringAsFixed(2), true);
    ticket.text("$netSales$netSalesAmt",
        styles: PosStyles(
            align: PosAlign.left, fontType: PosFontType.fontA, bold: false));

    /*For Rounding/Amount Redeemed 48 char*/
    String roundingAmountRedeem = printColumnWitSpace(38, "Rounding", false);
    String roundingAmountRedeemAmt =
        printColumnWitSpace(10, roundingAmount.toStringAsFixed(2), true);
    ticket.text("$roundingAmountRedeem$roundingAmountRedeemAmt",
        styles: PosStyles(
            align: PosAlign.left, fontType: PosFontType.fontA, bold: false));

    /*For Tax/ 48 char*/
    String tax = printColumnWitSpace(38, "Tax", false);
    String taxAmt = printColumnWitSpace(10, taxval.toStringAsFixed(2), true);
    ticket.text("$tax$taxAmt",
        styles: PosStyles(
            align: PosAlign.left, fontType: PosFontType.fontA, bold: false));

    /*For /Service Charge/ 48 char*/
    String serviceCharge = printColumnWitSpace(38, "Service Charge", false);
    String serviceChargeAmt =
        printColumnWitSpace(10, serviceTax.toStringAsFixed(2), true);
    ticket.text("$serviceCharge$serviceChargeAmt",
        styles: PosStyles(
            align: PosAlign.left, fontType: PosFontType.fontA, bold: false));
    ticket.hr();

    /*For Total Rendered 48 char*/
    String totalRendered = printColumnWitSpace(38, "Total Rendered", false);
    String totalRenderedAmt =
        printColumnWitSpace(10, totalRend.toStringAsFixed(2), true);
    ticket.text("$totalRendered$totalRenderedAmt",
        styles: PosStyles(
            align: PosAlign.left, fontType: PosFontType.fontA, bold: true));

    /*
    *For Print cash drawer summery
    */
    ticket.setStyles(PosStyles(align: PosAlign.center));
    ticket.emptyLines(2);
    ticket.text("Case Drawer Summery",
        styles: PosStyles(
            fontType: PosFontType.fontA,
            bold: true,
            width: PosTextSize.size2,
            align: PosAlign.center));
    ticket.hr();

    ticket.setStyles(PosStyles(align: PosAlign.left));
    /*For Opening Amount 48 char*/
    String openingAmountTitle =
        printColumnWitSpace(38, "Opening Amount", false);
    String openingAmt = printColumnWitSpace(
        10,
        shift.startAmount != null ? shift.startAmount.toStringAsFixed(2) : "",
        true);
    ticket.text("$openingAmountTitle$openingAmt",
        styles: PosStyles(
            align: PosAlign.left, fontType: PosFontType.fontA, bold: false));

    /*For Case Sales 48 char*/
    String cashSaleTitle = printColumnWitSpace(38, "Cash Sales", false);
    String cashSalesAmt =
        printColumnWitSpace(10, cashSale.toStringAsFixed(2), true);
    ticket.text("$cashSaleTitle$cashSalesAmt",
        styles: PosStyles(
            align: PosAlign.left, fontType: PosFontType.fontA, bold: false));

    /*For Case Deposit 48 char*/
    String cashDepositTitle = printColumnWitSpace(38, "Cash Deposit", false);
    String cashDepositAmt =
        printColumnWitSpace(10, cashDeposit.toStringAsFixed(2), true);
    ticket.text("$cashDepositTitle$cashDepositAmt",
        styles: PosStyles(
            align: PosAlign.left, fontType: PosFontType.fontA, bold: false));

    /*For Case Refunds 48 char*/
    String cashRefundTitle = printColumnWitSpace(38, "Cash Refunds", false);
    String cashRefundsAmt =
        printColumnWitSpace(10, cashRefund.toStringAsFixed(2), true);
    ticket.text("$cashRefundTitle$cashRefundsAmt",
        styles: PosStyles(
            align: PosAlign.left, fontType: PosFontType.fontA, bold: false));

    /*For Case Rounding 48 char*/
    String cashRoundingTitle = printColumnWitSpace(38, "Cash Rounding", false);
    String cashRoundingAmt =
        printColumnWitSpace(10, cashRounding.toStringAsFixed(2), true);
    ticket.text("$cashRoundingTitle$cashRoundingAmt",
        styles: PosStyles(
            align: PosAlign.left, fontType: PosFontType.fontA, bold: false));

    /*For Pay In 48 char*/
    String payIn = printColumnWitSpace(38, "Pay In", false);
    String payInAmt =
        printColumnWitSpace(10, payInAmount.toStringAsFixed(2), true);
    ticket.text("$payIn$payInAmt",
        styles: PosStyles(
            align: PosAlign.left, fontType: PosFontType.fontA, bold: false));

    /*For Pay Out 48 char*/
    String payOut = printColumnWitSpace(38, "Pay Out", false);
    String payOutAmt =
        printColumnWitSpace(10, payOutAmmount.toStringAsFixed(2), true);
    ticket.text("$payOut$payOutAmt",
        styles: PosStyles(
            align: PosAlign.left, fontType: PosFontType.fontA, bold: false));
    ticket.hr();

    /*For Expected Drawer 48 char*/
    String expDrawer = printColumnWitSpace(38, "Expected Drawer", false);
    String expDrawerAmt =
        printColumnWitSpace(10, expectedVal.toStringAsFixed(2), true);
    ticket.text("$expDrawer$expDrawerAmt",
        styles: PosStyles(
            align: PosAlign.left, fontType: PosFontType.fontA, bold: true));

    /*
    *For Payment summery
    */
    ticket.setStyles(PosStyles(align: PosAlign.center));
    ticket.emptyLines(2);
    ticket.text("Payment Summery",
        styles: PosStyles(
            fontType: PosFontType.fontA,
            bold: true,
            width: PosTextSize.size2,
            align: PosAlign.center));
    ticket.hr();

    ticket.setStyles(PosStyles(align: PosAlign.left));
    /*For Case 48 char*/
    var data = 0.0;
    for (var i = 0; i < orderPayments.length; i++) {
      String caseTitle = printColumnWitSpace(38, paymentMethods[i].name, false);
      String caseTitleAmt = printColumnWitSpace(
          10, orderPayments[i].op_amount.toStringAsFixed(2), true);
      ticket.text("$caseTitle$caseTitleAmt",
          styles: PosStyles(
              align: PosAlign.left, fontType: PosFontType.fontA, bold: false));
      data += orderPayments[i].op_amount;
    }

    ticket.hr();
    ticket.setStyles(PosStyles(align: PosAlign.left));
    /*For Case 48 char*/
    String totalTitle = printColumnWitSpace(38, "Total", false);
    String totalAmt = printColumnWitSpace(10, data.toStringAsFixed(2), true);
    ticket.text("$totalTitle$totalAmt",
        styles: PosStyles(
            align: PosAlign.left, fontType: PosFontType.fontA, bold: true));

    ticket.hr();
    ticket.setStyles(PosStyles(align: PosAlign.right));
    ticket.row([
      PosColumn(
          text: "Total Net Sales : ",
          width: 8,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: netsale.toStringAsFixed(2),
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);
    ticket.row([
      PosColumn(
          text: "Transactions : ",
          width: 8,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: ordersCount.toString(),
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);
    ticket.row([
      PosColumn(
          text: "Avg Order value : ",
          width: 8,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: (netsale / ordersCount).toStringAsFixed(2),
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);
    ticket.row([
      PosColumn(
          text: "Avg Per Pax : ",
          width: 8,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          )),
      PosColumn(
          text: (netsale / totalPax).toStringAsFixed(2),
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
            fontType: PosFontType.fontA,
            bold: false,
          )),
    ]);

    ticket.emptyLines(1);
    ticket.feed(2);
    ticket.cut();
    return ticket;
  }

  void shiftReportPrint(
      String printerIp,
      BuildContext ctx,
      Branch branchData,
      int totalPax,
      Terminal terminalData,
      var grosssale,
      var refundval,
      var discountval,
      var netsale,
      var taxval,
      var serviceTax,
      var roundingAmount,
      var totalRend,
      Shift shifittem,
      var cashSale,
      var cashDeposit,
      var cashRefund,
      var cashRounding,
      var payInAmmount,
      var payOutAmmount,
      var expectedVal,
      List<OrderPayment> orderPayments,
      List<Payments> paymentMethods,
      var ordersCount) async {
    final PrinterNetworkManager printerManager = PrinterNetworkManager();
    printerManager.selectPrinter(printerIp, port: 9100);

    final PosPrintResult res = await printerManager.printTicket(
        await shiftReportReceipt(
            branchData,
            totalPax,
            terminalData,
            grosssale,
            refundval,
            discountval,
            netsale,
            taxval,
            serviceTax,
            roundingAmount,
            totalRend,
            shifittem,
            cashSale,
            cashDeposit,
            cashRefund,
            cashRounding,
            payInAmmount,
            payOutAmmount,
            expectedVal,
            orderPayments,
            paymentMethods,
            ordersCount));

    CommunFun.showToast(ctx, res.msg);
  }

/*========================================================================
  ===========================Test print=====================================
  ========================================================================*/

  void testReceiptPrint(String printerIp, BuildContext ctx, String printerName,
      String isFor, bool isper) async {
    final PrinterNetworkManager printerManager = PrinterNetworkManager();
    printerManager.selectPrinter(printerIp, port: 9100);

    final PosPrintResult res = await printerManager
        .printTicket(await testPrintReceipt(printerName, printerIp, isFor));
    await CommunFun.showToast(ctx, res.msg);
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
      ticket.text("Terminal : " + Strings.terminalName,
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
        round = prefix + "." + postFilx.substring(0, 1) + "5";
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

  String printColumnWitSpace(
      int spaceBetween, String values, bool isLeftSpace) {
    int totalGivenSpace = spaceBetween - values.length;
    String space = " ";
    String printSpace = "";
    for (int i = 1; i <= totalGivenSpace; i++) {
      printSpace = printSpace + space;
    }
    if (isLeftSpace) {
      return printSpace + values;
    } else {
      return values + printSpace;
    }
  }
}
