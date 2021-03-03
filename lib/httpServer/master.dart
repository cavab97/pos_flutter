import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:deep_pick/deep_pick.dart';
import 'package:intl/intl.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/helpers/GetTableData.dart';
import 'package:mcncashier/models/Attribute_data.dart';
import 'package:mcncashier/models/BranchTax.dart';
import 'package:mcncashier/models/CheckInout.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/ModifireData.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/Printer.dart';
import 'package:mcncashier/models/Reservation.dart';
import 'package:mcncashier/models/SetMeal.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/models/TableDetails.dart';
import 'package:mcncashier/models/Table_order.dart';
import 'package:mcncashier/models/TerminalLog.dart';
import 'package:mcncashier/models/Voucher.dart';
import 'package:mcncashier/models/mst_sub_cart_details.dart';
import 'package:mcncashier/models/saveOrder.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/models/User.dart';
import 'package:wifi/wifi.dart';
import 'package:http/http.dart' as http;

class ServerModel {
  static LocalAPI _localAPI = new LocalAPI();
  static Future<void> start(String deviceIp) async {
    final server = await createServer(deviceIp);
    print('Server started: ${server.address} port ${server.port}');
    await handleRequests(server);
  }

  static Future<HttpServer> createServer(String deviceIp) async {
    final address = await Wifi.ip; // InternetAddress.loopbackIPv4;
    const port = 4040;
    return await HttpServer.bind(address, port);
  }

  static Future<void> handleRequests(HttpServer server) async {
    await for (HttpRequest request in server) {
      switch (request.method) {
        case 'GET':
          handleGet(request);
          break;
        case 'POST':
          handlePost(request);
          break;
        case 'DELETE':
          handleDelete(request);
          break;
        default:
          handleDefault(request);
      }
    }
  }

  static void handleGet(HttpRequest request) async {
    final path = request.uri.path;
    switch (path) {
      case '/ping':
        request.response
          ..statusCode = HttpStatus.ok
          ..close();
        break;
      case '/shifts':
        var _getShiftOpen = await getShiftOpen();
        request.response
          ..statusCode = HttpStatus.ok
          ..write(_getShiftOpen)
          ..close();
        break;

      case '/api/marslab/terminal/id':
        request.response
          ..statusCode = HttpStatus.ok
          ..write(await Preferences.getStringValuesSF(Constant.TERMINAL_KEY))
          ..close();
        break;
      case '/api/marslab/auth/me':
        try {
          Map<String, String> queryParameters = request.uri.queryParameters;
          List<User> checkUserExit =
              await _localAPI.checkUserExit(queryParameters["pin"]);
          request.response
            ..statusCode = HttpStatus.ok
            ..write(jsonEncode(checkUserExit))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/tablecolors':
        try {
          request.response
            ..statusCode = HttpStatus.ok
            ..write(jsonEncode(await _localAPI.getTablesColor()))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/shifts/current/status':
        try {
          request.response
            ..statusCode = HttpStatus.ok
            ..write(await Preferences.getStringValuesSF(Constant.IS_SHIFT_OPEN))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/kitchenprinters':
        try {
          request.response
            ..statusCode = HttpStatus.ok
            ..write(jsonEncode(await _localAPI.getAllPrinterForKOT()))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/receiptprinters':
        try {
          request.response
            ..statusCode = HttpStatus.ok
            ..write(jsonEncode(await _localAPI.getAllPrinterForecipt()))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/printers':
        try {
          Map<String, String> queryParameters = request.uri.queryParameters;
          int _productID = pick(queryParameters, "productid").asIntOrNull();
          request.response
            ..statusCode = HttpStatus.ok
            ..write(jsonEncode(await _localAPI.getPrinter(_productID)))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/mine/permissions':
        try {
          Map<String, String> queryParameters = request.uri.queryParameters;
          int _userID = pick(queryParameters, "userid").asIntOrNull();
          request.response
            ..statusCode = HttpStatus.ok
            ..write(jsonEncode(await localAPI.getUserPermissions(_userID)))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/reservations':
        try {
          String dateFrom;
          DateTime today;
          if (dateFrom == null) {
            today = DateTime.now();
            dateFrom = DateTime(today.year, today.month, 1).toString();
          }
          int terminalID = pick(await CommunFun.getTeminalKey()).asIntOrNull();
          List<Reservation> _resList = [];
          if (terminalID != null) {
            _resList = await localAPI.getReservationList(
              terminalID,
              dateFrom,
              (today != null ? today : DateTime.tryParse(dateFrom))
                  .add(Duration(days: 1))
                  .toString(),
            );
          }
          request.response
            ..statusCode = HttpStatus.ok
            ..write(jsonEncode(_resList))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/tables':
        try {
          Map<String, String> queryParameters = request.uri.queryParameters;
          String _tableID =
              pick(queryParameters, "id").asStringOrNull()?.trim();
          String _branchID = await CommunFun.getbranchId();
          if (_tableID != null) {
            request.response
              ..statusCode = HttpStatus.ok
              ..write(
                  jsonEncode(await localAPI.getTableData(_branchID, _tableID)))
              ..close();
          } else {
            request.response
              ..statusCode = HttpStatus.ok
              ..write(jsonEncode(await _localAPI.getTables(_branchID)))
              ..close();
          }
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/tableorders':
        try {
          Map<String, String> queryParameters = request.uri.queryParameters;
          String _tableID =
              pick(queryParameters, "tableid").asStringOrNull()?.trim();
          request.response
            ..statusCode = HttpStatus.ok
            ..write(jsonEncode(await localAPI.getTableOrders(_tableID)))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/categories':
        try {
          request.response
            ..statusCode = HttpStatus.ok
            ..write(jsonEncode(await _localAPI.getAllCategory()))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/taxes':
        try {
          Map<String, String> queryParameters = request.uri.queryParameters;
          String _taxID = pick(queryParameters, "id").asStringOrNull()?.trim();
          if (_taxID != null) {
            request.response
              ..statusCode = HttpStatus.ok
              ..write(jsonEncode(await _localAPI.getTaxName(_taxID)))
              ..close();
          } else {
            String _branchID = await CommunFun.getbranchId();
            request.response
              ..statusCode = HttpStatus.ok
              ..write(jsonEncode(await _localAPI.getTaxList(_branchID)))
              ..close();
          }
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/paymentmethods':
        try {
          request.response
            ..statusCode = HttpStatus.ok
            ..write(jsonEncode(await localAPI.getPaymentMethods()))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;

      case '/api/marslab/productcategory':
        try {
          request.response
            ..statusCode = HttpStatus.ok
            ..write(jsonEncode(await localAPI.getProductCategory()))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/products':
        try {
          Map<String, String> queryParameters = request.uri.queryParameters;
          String _searchText =
              pick(queryParameters, "search").asStringOrNull()?.trim();
          String _branchID = await CommunFun.getbranchId();
          if (_searchText == null) {
            request.response
              ..statusCode = HttpStatus.ok
              ..write(jsonEncode(await localAPI.getAllProduct(_branchID)))
              ..close();
          } else {
            request.response
              ..statusCode = HttpStatus.ok
              ..write(jsonEncode(
                  await localAPI.getSeachProduct(_searchText, _branchID)))
              ..close();
          }
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/product/details':
        try {
          Map<String, String> queryParameters = request.uri.queryParameters;
          String _productID =
              pick(queryParameters, "productid").asStringOrNull()?.trim();
          request.response
            ..statusCode = HttpStatus.ok
            ..write(jsonEncode(await localAPI.getProductDetails(_productID)))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/productmodifiers':
        try {
          Map<String, String> queryParameters = request.uri.queryParameters;
          String _productID =
              pick(queryParameters, "productid").asStringOrNull()?.trim();
          request.response
            ..statusCode = HttpStatus.ok
            ..write(jsonEncode(await localAPI.getProductModifeir(_productID)))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/product/inventory':
        try {
          Map<String, String> queryParameters = request.uri.queryParameters;
          String _productID =
              pick(queryParameters, "productid").asStringOrNull()?.trim();
          request.response
            ..statusCode = HttpStatus.ok
            ..write(await localAPI.checkItemAvailableinStore(_productID))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/setmeal':
        try {
          Map<String, String> queryParameters = request.uri.queryParameters;
          String _searchText =
              pick(queryParameters, "search").asStringOrNull()?.trim();
          String _branchID = await CommunFun.getbranchId();
          request.response
            ..statusCode = HttpStatus.ok
            ..write(jsonEncode(
                await localAPI.getSearchSetMealsData(_searchText, _branchID)))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/meals':
        try {
          String _branchID = await CommunFun.getbranchId();
          request.response
            ..statusCode = HttpStatus.ok
            ..write(jsonEncode(await localAPI.getMealsData(_branchID)))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/mealproducts':
        try {
          Map<String, String> queryParameters = request.uri.queryParameters;
          String _setMealID =
              pick(queryParameters, "id").asStringOrNull()?.trim();
          request.response
            ..statusCode = HttpStatus.ok
            ..write(jsonEncode(await localAPI.getMealsProductData(_setMealID)))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/categoryproducts':
        try {
          Map<String, String> queryParameters = request.uri.queryParameters;
          String _categoryID =
              pick(queryParameters, "categoryid").asStringOrNull()?.trim();
          String _branchID = await CommunFun.getbranchId();
          request.response
            ..statusCode = HttpStatus.ok
            ..write(
                jsonEncode(await localAPI.getProduct(_categoryID, _branchID)))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/categoryproducts':
        try {
          Map<String, String> queryParameters = request.uri.queryParameters;
          String _categoryID =
              pick(queryParameters, "categoryid").asStringOrNull()?.trim();
          String _branchID = await CommunFun.getbranchId();
          request.response
            ..statusCode = HttpStatus.ok
            ..write(
                jsonEncode(await localAPI.getProduct(_categoryID, _branchID)))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/saveorders':
        try {
          Map<String, String> queryParameters = request.uri.queryParameters;
          String _saveOrderID =
              pick(queryParameters, "id").asStringOrNull()?.trim();
          request.response
            ..statusCode = HttpStatus.ok
            ..write(jsonEncode(await localAPI.getSaveOrder(_saveOrderID)))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/cartproducts':
        try {
          Map<String, String> queryParameters = request.uri.queryParameters;
          String _cartID =
              pick(queryParameters, "cartid").asStringOrNull()?.trim();
          List<MSTCartdetails> _cartDetailsList = [];
          if (_cartID != null) {
            _cartDetailsList = await localAPI.getCartItem(_cartID);
          }
          request.response
            ..statusCode = HttpStatus.ok
            ..write(jsonEncode(_cartDetailsList))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/carts':
        try {
          Map<String, String> queryParameters = request.uri.queryParameters;
          String _cartID = pick(queryParameters, "id").asStringOrNull()?.trim();
          if (_cartID != null && _cartID.isNotEmpty) {
            request.response
              ..statusCode = HttpStatus.ok
              ..write(jsonEncode(await localAPI.getCartData(_cartID)))
              ..close();
          } else {
            String _branchID = await CommunFun.getbranchId();
            List<MST_Cart> _cartList = [];
            if (_branchID != null) {
              _cartList = await localAPI.getCartList(_branchID);
            }
            request.response
              ..statusCode = HttpStatus.ok
              ..write(jsonEncode(_cartList))
              ..close();
          }
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/branches/current':
        try {
          String _branchID = await CommunFun.getbranchId();
          request.response
            ..statusCode = HttpStatus.ok
            ..write(jsonEncode(await _localAPI.getBranchData(_branchID)))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/apply/voucher':
        try {
          String _inputString = await utf8.decoder.bind(request).join();
          if (_inputString.isEmpty) {
            request.response
              ..statusCode = HttpStatus.unprocessableEntity
              ..write('parameter empty')
              ..close();
            break;
          }
          MST_Cart _cartData =
              MST_Cart.fromJson(jsonDecode(_inputString)["cartData"]);
          Voucher _voucher =
              Voucher.fromJson(jsonDecode(_inputString)["voucher"]);

          request.response
            ..statusCode = HttpStatus.ok
            ..write(await _localAPI.addVoucherInOrder(_cartData, _voucher))
            ..close();
          /* Table_order tableOrder =
              Table_order.fromJson(jsonDecode(_inputString));
          tableOrder.assignTime =
              await CommunFun.getCurrentDateTime(DateTime.now());
          int _tableOrderID = await localAPI.addVoucherInOrder(tableOrder);
          request.response
            ..statusCode = HttpStatus.ok
            ..write(_tableOrderID)
            ..close(); */
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      default:
        handleGetOther(request);
    }
  }

  static getShiftOpen() async {
    return await Preferences.getStringValuesSF(Constant.IS_SHIFT_OPEN);
  }

  static void handleGetOther(HttpRequest request) {
    request.response
      ..statusCode = HttpStatus.badRequest
      ..close();
  }

  static void handlePost(HttpRequest request) async {
    final path = request.uri.path;
    switch (path) {
      case '/api/marslab/auth/access/pin':
        try {
          String _inputString = await utf8.decoder.bind(request).join();
          if (_inputString.isEmpty) {
            request.response
              ..statusCode = HttpStatus.unprocessableEntity
              ..write('parameter empty')
              ..close();
            break;
          }
          CheckinOut _checkinOut =
              CheckinOut.fromJson(jsonDecode(_inputString));

          var terminalId = await CommunFun.getTeminalKey();
          var branchid = await CommunFun.getbranchId();
          _checkinOut.localID = await CommunFun.getLocalID();
          _checkinOut.terminalId = int.parse(terminalId);
          _checkinOut.branchId = int.parse(branchid);
          _checkinOut.status = _checkinOut.id == null ? "IN" : "OUT";
          _checkinOut.timeInOut = DateTime.now().toString();
          if (_checkinOut.id == null) {
            _checkinOut.createdAt = DateTime.now().toString();
          }
          _checkinOut.sync = 0;
          int shiftID = await _localAPI.userCheckInOut(_checkinOut);
          request.response
            ..statusCode = HttpStatus.ok
            ..write(shiftID)
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/mine/logs':
        try {
          String _inputString = await utf8.decoder.bind(request).join();
          if (_inputString.isEmpty) {
            request.response
              ..statusCode = HttpStatus.unprocessableEntity
              ..write('parameter empty')
              ..close();
            break;
          }
          TerminalLog _log = TerminalLog.fromJson(jsonDecode(_inputString));
          var uuid = await CommunFun.getLocalID();
          var terminalId = await CommunFun.getTeminalKey();
          var branchid = await CommunFun.getbranchId();
          final DateTime now = DateTime.now();
          final String date = DateFormat('yyyy-MM-dd').format(now);
          final String time = DateFormat('HH:mm').format(now);
          String datetime = await CommunFun.getCurrentDateTime(DateTime.now());
          _log.uuid = uuid;
          _log.terminal_id = int.parse(terminalId);
          _log.branch_id = int.parse(branchid);
          _log.activity_date = date;
          _log.activity_time = time;
          _log.isSync = 0;
          _log.status = 1;
          _log.updated_at = datetime;
          int _logID = await _localAPI.terminalLog(_log);
          request.response
            ..statusCode = HttpStatus.ok
            ..write(_logID)
            ..close();
        } catch (e) {}
        break;
      case '/api/marslab/insertorder':
        try {
          String _inputString = await utf8.decoder.bind(request).join();
          if (_inputString.isEmpty) {
            request.response
              ..statusCode = HttpStatus.unprocessableEntity
              ..write('parameter empty')
              ..close();
            break;
          }
          Table_order tableOrder =
              Table_order.fromJson(jsonDecode(_inputString));
          tableOrder.number_of_pax = 0;
          tableOrder.assignTime =
              await CommunFun.getCurrentDateTime(DateTime.now());
          int _tableOrderID = await localAPI.insertTableOrder(tableOrder);
          request.response
            ..statusCode = HttpStatus.ok
            ..write(_tableOrderID)
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/tableorders':
        try {
          String _inputString = await utf8.decoder.bind(request).join();
          if (_inputString.isEmpty) {
            request.response
              ..statusCode = HttpStatus.unprocessableEntity
              ..write('parameter empty')
              ..close();
            break;
          }
          Table_order tableOrder =
              Table_order.fromJson(jsonDecode(_inputString));
          tableOrder.assignTime =
              await CommunFun.getCurrentDateTime(DateTime.now());
          int _tableOrderID = await localAPI.insertTableOrder(tableOrder);
          request.response
            ..statusCode = HttpStatus.ok
            ..write(_tableOrderID)
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/cartproducts':
        try {
          String _inputString = await utf8.decoder.bind(request).join();
          if (_inputString.isEmpty) {
            request.response
              ..statusCode = HttpStatus.unprocessableEntity
              ..write('parameter empty')
              ..close();
            break;
          }
          Map<String, dynamic> _inputMap = jsonDecode(_inputString);
          List<int> _modifierIDs =
              pick(_inputMap, "modifier_ids").asListOrNull();
          List<int> _attributesIDs = pick(_inputMap, "attr_ids").asListOrNull();
          int _cartID = await _addToCart(
            request: request,
            tableID: pick(_inputMap, "table_id").asIntOrNull(),
            cartID: pick(_inputMap, "cart_id").asIntOrNull(),
            staffID: pick(_inputMap, "user_id").asIntOrNull(),
            productID: pick(_inputMap, "product_id").asIntOrNull(),
            productQty: pick(_inputMap, "product_qty").asDoubleOrNull(),
            isSetMeal: pick(_inputMap, "is_set_meal").asBoolOrFalse(),
            notesMessage: pick(_inputMap, "note_msg").asStringOrNull(),
            modifierIDs: _modifierIDs,
            attributesID: _attributesIDs,
          );
          request.response
            ..statusCode = HttpStatus.ok
            ..write(_cartID)
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      case '/api/marslab/productdetail':
        try {
          String _inputString = await utf8.decoder.bind(request).join();
          if (_inputString.isEmpty) {
            request.response
              ..statusCode = HttpStatus.unprocessableEntity
              ..write('parameter empty')
              ..close();
            break;
          }
          MSTCartdetails _cartDetails =
              MSTCartdetails.fromJson(jsonDecode(_inputString)["cartDetails"]);
          request.response
            ..statusCode = HttpStatus.ok
            ..write(await localAPI.addintoCartDetails(_cartDetails))
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      default:
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('path no found')
          ..close();
    }
  }

  static Future<int> _addToCart({
    int tableID,
    int cartID,
    int staffID,
    int productID,
    double productQty,
    bool isSetMeal = false,
    String notesMessage = "",
    List<int> modifierIDs,
    List<int> attributesID,
    HttpRequest request,
  }) async {
    try {
      if (productID == null) {
        throw "Product ID is empty";
      }
      if (staffID == null) {
        throw "Staff ID is empty";
      }
      if (tableID == null) {
        throw "Table ID is empty";
      }
      if (productQty == null || productQty < 0.01) {
        productQty = 1;
      }
      MST_Cart _cart = new MST_Cart();
      if (cartID != null) {
        _cart = await _localAPI.getCartData(cartID);
      }
      List<Table_order> _tableOrder = await _localAPI.getTableOrders(tableID);
      Table_order _currentTableOrder =
          _tableOrder.length > 0 ? _tableOrder[0] : null;

      ProductDetails _productDetails = new ProductDetails();
      _productDetails.isSetMeal = isSetMeal;
      ProductDetails _product;
      SetMeal _setMeal;
      Printer _printer;

      _cart.id = cartID;
      if (_cart.total_qty == null) {
        _cart.sub_total = 0.00;
        _cart.total_qty = productQty;
      } else {}
      _cart.total_qty += productQty;
      _cart.branch_id = pick(await CommunFun.getbranchId()).asIntOrNull();
      _cart.serviceCharge = _currentTableOrder == null ||
              _currentTableOrder.service_charge == null
          ? 0.00
          : double.parse((_currentTableOrder.service_charge * _cart.sub_total)
              .toStringAsFixed(2));
      _cart.serviceChargePercent =
          _currentTableOrder == null ? 0 : _currentTableOrder.service_charge;
      _cart.discountAmount = 0.00;
      List<BranchTax> _taxes = await localAPI.getTaxList(_cart.branch_id);
      List<Map<String, dynamic>> _taxesMap = [];
      double _taxesAmount = 0.00;
      for (BranchTax _tax in _taxes) {
        Map<String, dynamic> _taxMap = new Map();
        double _taxAmount = _tax.rate != null
            ? ((_cart.serviceCharge + _cart.sub_total) *
                (double.parse(_tax.rate) / 100))
            : 0;
        _taxMap = {
          "id": _tax.id,
          "tax_id": _tax.taxId,
          "branch_id": _tax.branchId,
          "rate": _tax.rate,
          "status": _tax.status,
          "updated_at": _tax.updatedAt,
          "updated_by": _tax.updatedBy,
          "taxAmount": _taxAmount.toStringAsFixed(2),
          "taxCode": _tax.code
        };
        _taxesAmount += _taxAmount;
        _taxesMap.add(_taxMap);
      }

      _cart.tax_json = json.encode(_taxesMap);
      _cart.grand_total =
          (_cart.sub_total + _cart.serviceCharge + _taxesAmount);
      _cart.customer_terminal = 0;
      _cart.created_by = staffID;
      _cart.localID = await CommunFun.getLocalID();
      _cart.created_at = await CommunFun.getCurrentDateTime(DateTime.now());
      SaveOrder orderData = new SaveOrder();
      orderData.orderName = _currentTableOrder != null ? "" : "web";
      orderData.numberofPax =
          _currentTableOrder != null ? _currentTableOrder.number_of_pax : 0;
      orderData.isTableOrder = _currentTableOrder != null ? 1 : 0;
      if (!isSetMeal) {
        List<ProductDetails> productdt = await localAPI.productdData(productID);
        if (productdt != null && productdt.length > 0) {
          _product = productdt[0];
          _productDetails.qty = productQty;
          _productDetails.status = _product.status;
          _productDetails.productId = _product.productId;
          _productDetails.name = _product.name;
          _productDetails.name_2 = _product.name_2 ?? "";
          _productDetails.uuid = _product.uuid;
          _productDetails.price = _product.price;
          _productDetails.oldPrice = _product.oldPrice ?? 0.00;
          List<Printer> _printerList =
              await localAPI.getPrinter(_product.productId);
          _printer = _printerList[0];
        }
      } else {
        List<SetMeal> productdt = await localAPI.setmealData(productID);
        if (productdt != null && productdt.length > 0) {
          _setMeal = productdt[0];
          _productDetails.qty = productQty;
          _productDetails.status = _setMeal.status;
          _productDetails.productId = _setMeal.setmealId;
          _productDetails.name = _setMeal.name;
          _productDetails.uuid = _setMeal.uuid;
          _productDetails.price = _setMeal.price;
          _productDetails.name_2 = "";
          _productDetails.oldPrice = 0.00;
          List<Printer> _printerList =
              await localAPI.getPrinter(_setMeal.setmealId);
          _printer = _printerList[0];
        }
      }
      _productDetails
          .toJson()
          .removeWhere((String key, dynamic value) => value == null);
      if (_productDetails.productId == null) {
        throw "Product no found";
      }

      _cart.id = cartID = await localAPI.insertItemTocart(_cart.id, _cart,
          _productDetails, orderData, _currentTableOrder.table_id);
      double _productSubTotal = 0.00;
      _productSubTotal += _productDetails.price * _productDetails.qty;
      MSTCartdetails cartdetails = new MSTCartdetails(
        cartId: _cart.id,
        productId: _productDetails.productId,
        productName: _productDetails.name,
        productSecondName: _productDetails.name_2,
        productPrice: _productDetails.price,
        productDetailAmount: _productDetails.price * _productDetails.qty,
        productQty: _productDetails.qty,
        productNetPrice: _productDetails.oldPrice ?? 0,
        createdBy: staffID,
        cart_detail: jsonEncode(_productDetails),
        discountAmount: 0,
        localID: await CommunFun.getLocalID(),
        remark: notesMessage,
        issetMeal: isSetMeal ? 1 : 0,
        taxValue: 0,
        printer_id: _printer.printerId,
        createdAt: await CommunFun.getCurrentDateTime(DateTime.now()),
        setmeal_product_detail: isSetMeal ? json.encode(_setMeal) : null,
      );
      int _cartDetailID = await localAPI.addintoCartDetails(cartdetails);
      await localAPI.deletesubcartDetail(
          _cartDetailID); //clear previous attributes and modifier

      if (modifierIDs != null) {
        List<ModifireData> _modifiers =
            await _localAPI.getProductModifeir(_productDetails.productId);
        for (var i = 0;
            i < modifierIDs.length &&
                _modifiers.any((e) => e.modifierId == modifierIDs[i]);
            i++) {
          MSTSubCartdetails subCartData = new MSTSubCartdetails();
          ModifireData _modifier =
              _modifiers.firstWhere((mod) => mod.modifierId == modifierIDs[i]);
          if (_modifier != null) {
            subCartData.cartdetailsId = _cartDetailID;
            subCartData.localID = _cart.localID;
            subCartData.productId = _productDetails.productId;
            subCartData.modifierId = modifierIDs[i];
            subCartData.caId = _cart.id;
            subCartData.modifirePrice = _modifier.price;
            await localAPI.addsubCartData(subCartData);
            _productSubTotal += _modifier.price;
          }
        }
      }
      if (attributesID != null) {
        List<Attribute_Data> _attributes =
            await _localAPI.getProductDetails(_productDetails.productId);
        for (var i = 0;
            i < attributesID.length &&
                _attributes
                    .any((e) => e.attributeId == attributesID[i].toString());
            i++) {
          MSTSubCartdetails subCartData = new MSTSubCartdetails();
          Attribute_Data _attribute = _attributes.firstWhere(
              (mod) => mod.attributeId == attributesID[i].toString());
          if (_attribute != null) {
            subCartData.cartdetailsId = _cartDetailID;
            subCartData.localID = _cart.localID;
            subCartData.productId = _productDetails.productId;
            subCartData.modifierId = modifierIDs[i];
            subCartData.caId = _cart.id;
            subCartData.attrPrice =
                pick(_attribute.attr_types_price).asDoubleOrNull();
            await localAPI.addsubCartData(subCartData);
            _productSubTotal += subCartData.attrPrice;
          }
        }
        List<MSTCartdetails> cartdetails =
            await localAPI.getCartItem(_cartDetailID);
        /** 
         * stop on dashboard.dart
         * clear cart api
         * pass list to me
        */

        await _localAPI.updateCartDetailsPrice(_cartDetailID, _productSubTotal);
        await _localAPI.updateWebCart(_cart);
      }
      return cartID;
    } catch (e) {
      rethrow;
    }
  }

  static void handleDelete(HttpRequest request) async {
    final path = request.uri.path;
    print(path);
    switch (path) {
      case '/api/marslab/tableorders':
        try {
          Map<String, String> queryParameters = request.uri.queryParameters;
          int _tableID = pick(queryParameters["id"]).asIntOrNull();
          if (_tableID != null) {
            await localAPI.deleteTableOrder(_tableID);
          }
          request.response
            ..statusCode = HttpStatus.ok
            ..close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.unprocessableEntity
            ..write(e)
            ..close();
        }
        break;
      default:
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('path no found')
          ..close();
    }
  }

  static void handleDefault(HttpRequest request) {
    request.response
      ..statusCode = HttpStatus.methodNotAllowed
      ..write('Unsupported request: ${request.method}.')
      ..close();
  }

  static broadcastByURL(String apiURL, Map<String, dynamic> params) async {
    final address = await Wifi.ip;

    List<String> addressList = [];
    for (var i = 0; i < 20; i++) {
      addressList.add(address.substring(0, address.lastIndexOf(".") - 1) +
          (255 - i).toString());
    }
    for (String _address in addressList) {
      try {
        final client = new http.Client();
        final _responce = await client
            .get('$_address:4040/ping')
            .timeout(Duration(seconds: (1)));
        if (_responce.statusCode == HttpStatus.ok) {
          http.post(
            '$_address:4040/$apiURL',
            body: json.encode(params),
          );
        }
      } on TimeoutException catch (_) {
        print('request timeout');
        continue;
      } catch (e) {
        continue;
      }
    }
  }
}
