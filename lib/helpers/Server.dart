import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/QrScanAndGenrate.dart';
import 'package:mcncashier/helpers/APIcalls/BranchReq.dart';
import 'package:mcncashier/helpers/APIcalls/CartReq.dart';
import 'package:mcncashier/helpers/APIcalls/CategoriesReq.dart';
import 'package:mcncashier/helpers/APIcalls/CheckinOutReq.dart';
import 'package:mcncashier/helpers/APIcalls/CustomerReq.dart';
import 'package:mcncashier/helpers/APIcalls/OrdersReq.dart';
import 'package:mcncashier/helpers/APIcalls/PaymentReq.dart';
import 'package:mcncashier/helpers/APIcalls/PrinterReq.dart';
import 'package:mcncashier/helpers/APIcalls/ProductsReq.dart';
import 'package:mcncashier/helpers/APIcalls/ShiftReq.dart';
import 'package:mcncashier/helpers/APIcalls/TablesReq.dart';

class Server {
  static createSetver(ip, context) async {
    var server = await HttpServer.bind(ip, 8080);
    print("Server running on IP : " +
        server.address.toString() +
        " On Port : " +
        server.port.toString());
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return QRCodesImagePop(ip: ip);
        });
    await for (var request in server) {
      handleRequest(request);
    }
  }

  static handleRequest(request) {
    try {
      if (request.method == 'GET') {
        handleGet(request);
      }
      if (request.method == 'POST') {
        handlePOST(request);
      } else {
        request.response
          ..statusCode = HttpStatus.methodNotAllowed
          ..write('Unsupported request: ${request.method}.');
      }
    } catch (e) {
      print('Exception in handleRequest: $e');
    }
  }

  static handlePOST(request) async {
    var path = request.uri.path;
    print(path);
    switch (path) {
      case "/Categories":
        CategoriesReq.getcategoryCall(request);
        break;
      case "/Products":
        ProductsReq.getProductCall(request);
        break;
      case "/Search_product":
        ProductsReq.getProductSearchCall(request);
        break;
      case "/Customers":
        CustomerReq.getCustomerCall(request);
        break;
      case "/Add_Customer":
        CustomerReq.addCustomerCall(request);
        break;
      case "/Tables":
        TablesReq.getTableCall(request);
        break;
      case "/Add_Table_Order":
        TablesReq.addTableOrder(request);
        break;
      case "/Add_shift":
        ShiftReq.addShift(request);
        break;
      case "/Shift_datails":
        ShiftReq.getShiftList(request);
        break;
      case "/Product_attributes":
        ProductsReq.getProductAttributes(request);
        break;
      case "/Product_modifires":
        ProductsReq.getProductModifires(request);
        break;
      case "/Add_cart":
        CartReq.addCart(request);
        break;
      case "/Add_SaveOrder":
        CartReq.addSaveOrder(request);
        break;
      case "/Cart_Details":
        CartReq.addCartDetails(request);
        break;
      case "/Cart_Sub_Details":
        CartReq.addSubCartDetails(request);
        break;
      case "/Cart_Items":
        CartReq.cartItemList(request);
        break;
      case "/checkIn_Out":
        CheckInOutReq.userCheckInOut(request);
        break;
      case "/table_Details":
        TablesReq.gettableDetails(request);
        break;
      case "/get_Cart_id":
        CartReq.getSaveOrder(request);
        break;
      case "/cart_data":
        CartReq.getCartTotals(request);
        break;
      case "/payment_Methods":
        PaymenntReq.getPaymentMethods(request);
        break;
      case "/get_order":
        OrdersReq.getcurrentOrders(request);
        break;
      case "/getLastOrderids":
        OrdersReq.getLastOrderIds(request);
        break;
      case "/delete_cart_item":
        CartReq.deletecartItem(request);
        break;
      case "/clear_cart":
        CartReq.cleatCart(request);
        break;
      case "/product_modifire":
        CartReq.productModifierdata(request);
        break;
      case "/order":
        OrdersReq.placeOrder(request);
        break;
      case "/order_details":
        OrdersReq.orderDetails(request);
        break;
      case "/order_payment_details":
        OrdersReq.orderPaymentdata(request);
        break;
      case "/order_List":
        OrdersReq.getOrdersList(request);
        break;
      case "/order_payment_method":
        PaymenntReq.getOrderPaymentMethods(request);
        break;
      case "/update_cart":
        CartReq.updateCartData(request);
        break;
      case "/update_cart_items":
        CartReq.updateCartList(request);
        break;
      case "/branch_detail":
        BranchReq.branchdata(request);
        break;
      case "/branch_tax":
        BranchReq.branchtax(request);
        break;
      case "/getPrinter":
        PrinterReq.getAllPrinters(request);
        break;
      case "/getPrinterForCart":
        PrinterReq.getCartQTYPrinters(request);
        break;
      case "/set_meals":
        ProductsReq.getSetMeals(request);
        break;
      case "/set_meals_products":
        ProductsReq.getSetmealProducts(request);
        break;
      default:
    }
  }

  static handleGet(request) {
    print(request);
  }
}
