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
import 'APIcalls/CartReq.dart';
import 'APIcalls/OrdersReq.dart';
import 'APIcalls/TablesReq.dart';

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
      case "/Search_setmeal":
        ProductsReq.getsetmealSearchCall(request);
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
      case "/table_orders":
        TablesReq.gettableOrder(request);
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
      case "/place_order":
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
      case "/printer":
        PrinterReq.getAllPrinters(request);
        break;
      case "/printer_cart":
        PrinterReq.getCartQTYPrinters(request);
        break;
      case "/set_meals":
        ProductsReq.getSetMeals(request);
        break;
      case "/set_meals_products":
        ProductsReq.getSetmealProducts(request);
        break;
      case "/product_details":
        ProductsReq.getProductSubDetails(request);
        break;
      case "/merge_table_order":
        TablesReq.mergeTableOrder(request);
        break;
      case "/check_voucher":
        CartReq.vaucherExit(request);
        break;
      case "/order_data":
        OrdersReq.getOrdersDetails(request);
        break;
      case "/add_voucher":
        CartReq.addVoucher(request);
        break;
      case "/terminal_data":
        BranchReq.getTerminalData(request);
        break;
      case "/lastcustomer_id":
        BranchReq.getCustomerAppid(request);
        break;
      case "/get_addresses":
        CustomerReq.getCustomerAddList(request);
        break;
      case "/add_foc_product":
        CartReq.makeProductAsFoc(request);
        break;
      case "/change_table":
        TablesReq.changeTable(request);
        break;
      case "/drawer_data":
        ShiftReq.drawerList(request);
        break;
      case "/get_user_permission":
        BranchReq.getPermissions(request);
        break;
      case "/cancel_order":
        OrdersReq.insertCancelOrd(request);
        break;
      case "/store_inv_data":
        OrdersReq.getStoreInvdata(request);
        break;
      case "/update_order_status":
        OrdersReq.updateStatus(request);
        break;
      case "/last_wine_int_log_id":
        OrdersReq.customerInvlastId(request);
        break;
      case "/remove_cart":
        OrdersReq.removeCartItem(request);
        break;
      case "/check_item_into_store":
        OrdersReq.checkitemIntoStore(request);
        break;
      case "/cart_list":
        CartReq.getcartLists(request);
        break;
      case "/product_Data":
        ProductsReq.getcartproductData(request);
        break;
      case "/setmeal_Data":
        ProductsReq.getcartsetMealData(request);
        break;
      case "/customer_redeem":
        CustomerReq.getCustomerRedeem(request);
        break;
      case "/rac_data":
        ProductsReq.getracData(request);
        break;
      case "/box_list":
        ProductsReq.getboxData(request);
        break;
      case "/drawer_data":
        ShiftReq.addDrawer(request);
        break;
      case "/shift_app_id":
        ShiftReq.lastappid(request);
        break;
      case "/shift_Invoice_app_id":
        ShiftReq.lastshiftInvoiceappid(request);
        break;
      default:
    }
  }

  static handleGet(request) {
    print(request);
  }
}
