import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Attribute_data.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/models/Category.dart';
import 'package:mcncashier/models/CheckInout.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/ModifireData.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/PosPermission.dart';
import 'package:mcncashier/models/Printer.dart';
import 'package:mcncashier/models/Product.dart';
import 'package:mcncashier/models/Product_Store_Inventory.dart';
import 'package:mcncashier/models/BranchTax.dart';
import 'package:mcncashier/models/Role.dart';
import 'package:mcncashier/models/Tax.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/models/Voucher_History.dart';
import 'package:mcncashier/models/Product_Categroy.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/models/Table_order.dart';
import 'package:mcncashier/models/TableDetails.dart';
import 'package:mcncashier/models/Voucher.dart';
import 'package:mcncashier/models/cancelOrder.dart';
import 'package:mcncashier/models/mst_sub_cart_details.dart';
import 'package:mcncashier/models/saveOrder.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/Order_Modifire.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/OrderAttributes.dart';
import 'package:mcncashier/models/TerminalLog.dart';
import 'package:mcncashier/services/allTablesSync.dart';

class LocalAPI {
  Future<int> terminalLog(TerminalLog log) async {
    try {
      var db = await DatabaseHelper.dbHelper.getDatabse();
      var result = await db.insert("terminal_log", log.toJson());
      return result;
    } catch (e) {
      print(e);
    }
  }

  Future<List<Category>> getAllCategory() async {
    var branchID = await CommunFun.getbranchId();
    var query = "select * from category left join category_branch on " +
        " category_branch.category_id = category.category_id where " +
        " category_branch.branch_id =" +
        branchID.toString() +
        " AND category.status = 1";

    List<Map> res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<Category> list =
        res.isNotEmpty ? res.map((c) => Category.fromJson(c)).toList() : [];

    await SyncAPICalls.logActivity(
        "Product", "geting category List", "category", branchID);

    return list;
  }

  Future<List<ProductDetails>> getProduct(String id, String branchID) async {
    var query = "SELECT product.*,group_concat(replace(asset.base64,'data:image/jpg;base64,','') , ' groupconcate_Image ') as base64 , price_type.name as price_type_Name FROM `product` " +
        " LEFT join product_category on product_category.product_id = product.product_id " +
        " LEFT join product_branch on product_branch.product_id = product.product_id " +
        " LEFT join price_type on price_type.pt_id = product.price_type_id AND price_type.status = 1 " +
        " LEFT join asset on asset.asset_type = 1 AND asset.asset_type_id = product.product_id " +
        " where product_category.category_id = " +
        id +
        " AND product_branch.branch_id = " +
        branchID +
        " AND product.status = 1 GROUP By product.product_id";
    List<Map> res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<ProductDetails> list = res.isNotEmpty
        ? res.map((c) => ProductDetails.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Product", "geting Product List", "product", id);
    return list;
  }

  Future<List<ProductDetails>> getSeachProduct(
      String searchText, String branchID) async {
    var query = "SELECT product.*,group_concat(replace(asset.base64,'data:image/jpg;base64,','') , ' groupconcate_Image ') as base64 , price_type.name as price_type_Name FROM `product` " +
        " LEFT join price_type on price_type.pt_id = product.price_type_id AND price_type.status = 1 " +
        " LEFT join asset on asset.asset_type = 1 AND asset.asset_type_id = product.product_id " +
        " where product.name LIKE '%$searchText%' OR product.sku LIKE '%$searchText%'" +
        " AND product.status = 1" +
        " GROUP By product.product_id";

    List<Map> res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<ProductDetails> list = res.isNotEmpty
        ? res.map((c) => ProductDetails.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Product", "geting Product List", "product", "1");
    return list;
  }

  Future<List<Customer>> getCustomers(teminalID) async {
    var query = "SELECT * from customer WHERE " + " customer.status = 1 ";

    teminalID;
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<Customer> list =
        res.isNotEmpty ? res.map((c) => Customer.fromJson(c)).toList() : [];
    await SyncAPICalls.logActivity(
        "Customer", "geting customer list", "customer", teminalID);

    return list;
  }

  Future<int> addCustomer(Customer customer) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var result = await db.insert("customer", customer.toJson());
    await SyncAPICalls.logActivity(
        "Customer", "Adding customer", "customer", result);

    return result;
  }

  Future<List<TablesDetails>> getTables(branchid) async {
    var query =
        "SELECT tables.*, table_order.save_order_id,table_order.number_of_pax from tables " +
            " LEFT JOIN table_order on table_order.table_id = tables.table_id " +
            " WHERE tables.status = 1 AND branch_id = " +
            branchid +
            " GROUP by tables.table_id";
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<TablesDetails> list = res.isNotEmpty
        ? res.map((c) => TablesDetails.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Tables", "Getting Tables list", "tables", branchid);

    return list;
  }

  Future<int> insertTableOrder(Table_order table_order) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from table_order where table_id =" +
        table_order.table_id.toString();
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<Table_order> list =
        res.isNotEmpty ? res.map((c) => Table_order.fromJson(c)).toList() : [];
    var result;
    if (list.length > 0) {
      result = await db.update("table_order", table_order.toJson(),
          where: 'table_id = ?', whereArgs: [table_order.table_id]);
    } else {
      result = await db.insert("table_order", table_order.toJson());
    }
    await SyncAPICalls.logActivity(
        "Tables",
        list.length > 0 ? "Update table Order" : "Insert table Order",
        "table_order",
        table_order.table_id);

    return result;
  }

  Future updateTableIdInOrder(orderid, tableid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "UPDATE orders SET table_id =" +
        tableid.toString() +
        " where app_id =" +
        orderid.toString();
    var res = await db.rawQuery(qry);
    await SyncAPICalls.logActivity(
        "assign table", "assing table to web order", "orders", tableid);
  }

  Future<int> insertTablePrinter(Printer table_printer) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from printer where printer_ip = 1"; //+
    // table_printer.printerIp.toString();
    var res = await db.rawQuery(qry);
    List<Printer> list =
        res.isNotEmpty ? res.map((c) => Printer.fromJson(c)).toList() : [];
    var result;
    if (list.length > 0) {
      result = await db.update("printer", table_printer.toJson(),
          where: 'printerIp = ?', whereArgs: [table_printer.printerIp]);
    } else {
      result = await db.insert("printer", table_printer.toJson());
    }
    await SyncAPICalls.logActivity(
        "Printer",
        list.length > 0 ? "Update table printer" : "Insert table printer",
        "printerId",
        table_printer.printerId);

    return result;
  }

  Future<List<Printer>> selectPrinterForPrint() async {
    var qry =
        "SELECT * from printer LEFT JOIN product_branch on product_branch.product_id = 1  AND printer.printer_id = product_branch.printer_id";
    // table_printer.printerIp.toString();
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<Printer> list =
        res.isNotEmpty ? res.map((c) => Printer.fromJson(c)).toList() : [];

    await SyncAPICalls.logActivity("Printer",
        list.length > 0 ? "Print KOT" : "Print KOT", "printerId", "1");

    print("=====================================");
    print(list[0].printerIp);
    print("=====================================");
    return list;
  }

  Future<int> insertShift(Shift shift) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var result;
    if (shift.shiftId != null) {
      result = await db.update("shift", shift.toJson(),
          where: 'shift_id = ?', whereArgs: [shift.shiftId]);
    } else {
      result = await db.insert("shift", shift.toJson());
    }
    var dis = shift.shiftId != null ? "Update shift" : "Insert shift";
    await SyncAPICalls.logActivity("Product", dis, "shift", result);
    return result;
  }

  Future<List<Attribute_Data>> getProductDetails(ProductDetails product) async {
    var qry = " SELECT product.product_id, category_attribute.name as attr_name,attributes.ca_id, " +
        " group_concat(product_attribute.price) as attr_types_price,group_concat(attributes.name) as attr_types ,group_concat(attributes.attribute_id) as attributeId" +
        " FROM product LEFT JOIN product_attribute on product_attribute.product_id = product.product_id and product_attribute.status = 1" +
        " LEFT JOIN category_attribute on category_attribute.ca_id = product_attribute.ca_id and category_attribute.status = 1" +
        " LEFT JOIN attributes on attributes.attribute_id = product_attribute.attribute_id and attributes.status = 1 " +
        " WHERE product.product_id = " +
        product.productId.toString() +
        " AND product_attribute.product_id = " +
        product.productId.toString() +
        "   GROUP by category_attribute.ca_id";
    List<Map> res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<Attribute_Data> list = res.length > 0
        ? res.map((c) => Attribute_Data.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Product", "Getting Product details", "product", product.productId);
    return list;
  }

  Future<List<ModifireData>> getProductModifeir(ProductDetails product) async {
    var qry =
        "SELECT modifier.name,modifier.modifier_id,modifier.is_default,product_modifier.pm_id,product_modifier.price FROM  product_modifier " +
            " LEFT JOIN modifier on modifier.modifier_id = product_modifier.modifier_id " +
            " WHERE product_modifier.product_id = " +
            product.productId.toString() +
            " AND product_modifier.status = 1" +
            " GROUP by product_modifier.pm_id";
    List<Map> res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<ModifireData> list =
        res.isNotEmpty ? res.map((c) => ModifireData.fromJson(c)).toList() : [];
    await SyncAPICalls.logActivity(
        "Product", "Getting Product modifire", "modifier", product.productId);
    return list;
  }

  Future<int> insertItemTocart(cartidd, MST_Cart cartData,
      ProductDetails product, SaveOrder orderData, tableiD, subCartData) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var cartid;
    if (cartidd == null) {
      cartid = await db.insert("mst_cart", cartData.toJson());
      await SyncAPICalls.logActivity(
          "product", "Product add in to cart", "mst_cart", cartid);
      orderData.cartId = cartid; //cartid
      await insertSaveOrders(orderData, tableiD);
    } else {
      cartData.id = cartidd;
      var res_cartid = await db.update("mst_cart", cartData.toJson(),
          where: 'id = ?', whereArgs: [cartidd]);
      cartid = cartidd;
      await SyncAPICalls.logActivity(
          "product", "Product update in to cart", "mst_cart", res_cartid);
    }

    return cartid;
  }

  Future<int> insertSaveOrders(orderData, tableiD) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var response = await db.insert("save_order", orderData.toJson());
    await SyncAPICalls.logActivity(
        "product", "save item into save order table", "save_order", 1);
    if (tableiD != null) {
      var rawQuery = 'UPDATE table_order set save_order_id = ' +
          response.toString() +
          " WHERE table_id = " +
          tableiD.toString();
      await db.rawQuery(rawQuery);
      await SyncAPICalls.logActivity("product", "update save_order_id",
          "table_order", response.toString());
    }
    return 1;
  }

  Future<int> updateTableidintocart(cartid, tableiD) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var rawQuery = 'UPDATE mst_cart SET table_id = ' +
        tableiD.toString() +
        " WHERE id = " +
        cartid.toString();
    var res = await db.rawQuery(rawQuery);
    print(res);
    await SyncAPICalls.logActivity(
        "weborder", "update table_id", "mst_cart", tableiD.toString());
    return 1;
  }

  Future<int> addintoCartDetails(cartdetails) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var cartdetailid;
    if (cartdetails.id != null) {
      cartdetailid = db.update("mst_cart_detail", cartdetails.toJson(),
          where: 'id = ?', whereArgs: [cartdetails.id]);
      cartdetailid = cartdetails.id;
    } else {
      cartdetailid = await db.insert("mst_cart_detail", cartdetails.toJson());
    }
    await SyncAPICalls.logActivity(
        "product", "insert  cart details", "mst_cart_detail", cartdetailid);
    return cartdetailid;
  }

  Future<int> addsubCartData(MSTSubCartdetails data) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var result1 = await db.insert("mst_cart_sub_detail", data.toJson());
    print(result1);
    await SyncAPICalls.logActivity(
        "product", "insert sub cart details", "mst_cart_sub_detail", result1);
    return result1;
  }

  Future<List<MSTSubCartdetails>> itemmodifireList(cartID) async {
    var qry = "SELECT  mst_cart_sub_detail.*  from mst_cart_sub_detail" +
        " LEFT JOIN mst_cart_detail on mst_cart_detail.cart_id = " +
        cartID.toString() +
        " WHERE mst_cart_sub_detail.cart_details_id = mst_cart_detail.id";

    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<MSTSubCartdetails> list = res.isNotEmpty
        ? res.map((c) => MSTSubCartdetails.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "product", "get cart modifier list", "mst_cart_sub_detail", cartID);
    return list;
  }

  Future<List<MSTCartdetails>> getCartItem(cartId) async {
    var qry =
        "SELECT * from mst_cart_detail where cart_id = " + cartId.toString();
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<MSTCartdetails> list = res.isNotEmpty
        ? res.map((c) => MSTCartdetails.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "product", "get cart list", "mst_cart_detail", cartId);
    return list;
  }

  Future<int> userCheckInOut(CheckinOut clockinOutData) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var shiftid;
    if (clockinOutData.status == "IN") {
      shiftid = await db.insert("user_checkinout", clockinOutData.toJson());
    } else {
      shiftid = await db.update("user_checkinout", clockinOutData.toJson(),
          where: 'id = ?', whereArgs: [clockinOutData.id]);
    }
    var dis = clockinOutData.status == "IN" ? "User checkin" : "user checkout";
    await SyncAPICalls.logActivity(
        "PIN number", dis, "user_checkinout", shiftid);
    return shiftid;
  }

  Future<List<SaveOrder>> getSaveOrder(id) async {
    var qry = "SELECT * from save_order WHERE id =" + id.toString();
    List<Map> res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<SaveOrder> list =
        res.isNotEmpty ? res.map((c) => SaveOrder.fromJson(c)).toList() : [];
    await SyncAPICalls.logActivity(
        "product", "get save_order", "save_order", id);

    return list;
  }

  Future<List<TablesDetails>> getTableData(branchid, tableID) async {
    var query =
        "SELECT tables.*, table_order.save_order_id,table_order.number_of_pax from tables " +
            " LEFT JOIN table_order on table_order.table_id = " +
            tableID.toString() +
            " WHERE tables.table_id= " +
            tableID.toString() +
            " AND tables.status = 1 AND branch_id = " +
            branchid;
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<TablesDetails> list = res.isNotEmpty
        ? res.map((c) => TablesDetails.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity("product", "get cart list", "mst_cart", 1);

    return list;
  }

  Future<List<MST_Cart>> getCurrentCart(cartID) async {
    var query = "SELECT * from mst_cart where id=" + cartID.toString();
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<MST_Cart> list =
        res.isNotEmpty ? res.map((c) => MST_Cart.fromJson(c)).toList() : [];
    await SyncAPICalls.logActivity("product", "get cart list", "mst_cart", 1);
    return list;
  }

  Future<List<MSTCartdetails>> getCurrentCartItems(cartID) async {
    var query =
        "SELECT * from mst_cart_detail where cart_id = " + cartID.toString();
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<MSTCartdetails> list = res.isNotEmpty
        ? res.map((c) => MSTCartdetails.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "product", "get cart details list", "mst_cart_details", 1);
    return list;
  }

  Future<List<Payments>> getPaymentMethods() async {
    var query = "SELECT * from payment where status = 1";
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<Payments> list =
        res.isNotEmpty ? res.map((c) => Payments.fromJson(c)).toList() : [];
    await SyncAPICalls.logActivity("payment", "get payment list", "payment", 1);

    return list;
  }

  Future<Orders> getcurrentOrders(orderid) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var result =
        await db.query('orders', where: "app_id = ?", whereArgs: [orderid]);
    List<Orders> list =
        result.isNotEmpty ? result.map((c) => Orders.fromJson(c)).toList() : [];
    return list[0];
  }

  Future<List<Orders>> getLastOrderAppid(terminalid) async {
    var qey = "SELECT orders.app_id from orders where terminal_id =" +
        terminalid +
        "  ORDER BY order_date DESC LIMIT 1";
    var checkisExit = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qey);
    List<Orders> list = checkisExit.length > 0
        ? checkisExit.map((c) => Orders.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<OrderDetail>> getLastOrdeDetailAppid(terminalid) async {
    var qey =
        "SELECT order_detail.app_id from order_detail where terminal_id =" +
            terminalid +
            "  ORDER BY detail_datetime DESC LIMIT 1";
    var checkisExit = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qey);
    List<OrderDetail> list = checkisExit.length > 0
        ? checkisExit.map((c) => OrderDetail.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<OrderModifire>> getLastOrderModifireAppid(terminalid) async {
    var qey =
        "SELECT order_modifier.app_id from order_modifier where terminal_id =" +
            terminalid +
            "  ORDER BY om_datetime DESC LIMIT 1";
    var checkisExit = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qey);
    List<OrderModifire> list = checkisExit.length > 0
        ? checkisExit.map((c) => OrderModifire.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<OrderAttributes>> getLastOrderAttrAppid(terminalid) async {
    var qey =
        "SELECT order_attributes.app_id from order_attributes where terminal_id =" +
            terminalid +
            "  ORDER BY oa_datetime DESC LIMIT 1";
    var checkisExit = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qey);
    List<OrderAttributes> list = checkisExit.length > 0
        ? checkisExit.map((c) => OrderAttributes.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<OrderPayment>> getLastOrderPaymentAppid(terminalid) async {
    var qey =
        "SELECT order_payment.app_id from order_payment where terminal_id =" +
            terminalid +
            "  ORDER BY op_datetime DESC LIMIT 1";
    var checkisExit = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qey);
    List<OrderPayment> list = checkisExit.length > 0
        ? checkisExit.map((c) => OrderPayment.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<int> placeOrder(Orders orderData) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var orderid = await db.insert("orders", orderData.toJson());
    await SyncAPICalls.logActivity("orders", "place order", "orders", orderid);
    return orderData.app_id;
  }

  Future<int> sendOrderDetails(OrderDetail orderDetailData) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var orderid = await db.insert("order_detail", orderDetailData.toJson());
    await SyncAPICalls.logActivity(
        "orders", "insert order details", "order_detail", orderid);
    return orderDetailData.app_id;
  }

  Future<int> sendModifireData(OrderModifire orderDetailData) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var orderid = await db.insert("order_modifier", orderDetailData.toJson());
    await SyncAPICalls.logActivity(
        "orders", "insert order modifier", "order_modifier", orderid);
    return orderDetailData.app_id;
  }

  Future<int> sendAttrData(OrderAttributes orderDetailData) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var orderid = await db.insert("order_attributes", orderDetailData.toJson());
    await SyncAPICalls.logActivity(
        "orders", "insert order attributes", "order_attributes", orderid);
    return orderDetailData.app_id;
  }

  Future<int> sendtoOrderPayment(OrderPayment paymentData) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var orderid = await db.insert("order_payment", paymentData.toJson());
    await SyncAPICalls.logActivity(
        "orders", "insert order payment", "order_payment", orderid);
    return paymentData.app_id;
  }

  Future<int> removeCartItem(cartid, tableID) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();

    var cart = // cart table
        await db.delete("mst_cart", where: 'id = ?', whereArgs: [cartid]);
    print(cart);
    await SyncAPICalls.logActivity("orders", "clear cart", "mst_cart", 1);

    await db.delete("save_order", where: 'cart_id = ?', whereArgs: [cartid]);

    await SyncAPICalls.logActivity(
        "orders", "clear save_order", "save_order", cartid);

    await db.delete("table_order", where: 'table_id = ?', whereArgs: [tableID]);

    await SyncAPICalls.logActivity(
        "orders", "clear table_order", "table_order", cartid);

    var cartDetail = await db
        .query("mst_cart_detail", where: 'cart_id = ?', whereArgs: [cartid]);

    List<MSTCartdetails> list = cartDetail.isNotEmpty
        ? cartDetail.map((c) => MSTCartdetails.fromJson(c)).toList()
        : [];
    if (list.length > 0) {
      for (var i = 0; i < list.length; i++) {
        var cartsubdatad = await db.delete("mst_cart_sub_detail",
            where: 'cart_details_id = ?', whereArgs: [list[i].id]);
        print(cartsubdatad);
      }
    }
    await SyncAPICalls.logActivity(
        "orders", "clear cart detail", "mst_cart_sub_detail", cartid);

    // cart details
    var cartd = await db
        .delete("mst_cart_detail", where: 'cart_id = ?', whereArgs: [cartid]);
    await SyncAPICalls.logActivity(
        "orders", "clear cart detail", "mst_cart_detail", cartid);
    return cartd;
  }

  Future<int> deleteCartItem(cartItem, cartID, mainCart, isLast) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    await db
        .delete("mst_cart_Detail", where: 'id = ?', whereArgs: [cartItem.id]);
    await SyncAPICalls.logActivity(
        "cart",
        "delete cart item from mst_cart_Detail",
        "mst_cart_Detail",
        cartItem.id);

    await db.delete("mst_cart_sub_detail",
        where: 'cart_details_id = ?', whereArgs: [cartItem.id]);
    await SyncAPICalls.logActivity(
        "cart",
        "delete cart item from mst_cart_sub_detail",
        "mst_cart_sub_detail",
        cartItem.id);

    if (isLast) {
      await db.delete("mst_cart", where: 'id = ?', whereArgs: [cartID]);
      await SyncAPICalls.logActivity(
          "cart", "delete cart all item", "mst_Cart", cartItem.id);
      await db.delete("save_order", where: 'cart_id = ?', whereArgs: [cartID]);
      await SyncAPICalls.logActivity("cart",
          "delete cart all item from save_order", "save_order", cartItem.id);
    } else {
      //Update cart
      await db.update("mst_cart", mainCart.toJson(),
          where: 'id = ?', whereArgs: [cartID]);
    }
    return cartID;
  }

  Future<List<MSTSubCartdetails>> getItemModifire(id) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();

    var cartDetail = await db.query("mst_cart_sub_detail",
        where: 'cart_details_id = ?', whereArgs: [id]);
    List<MSTSubCartdetails> list = cartDetail.isNotEmpty
        ? cartDetail.map((c) => MSTSubCartdetails.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity("edit cart item",
        "get modifire list mst_cart_sub_detail", "mst_cart_sub_detail", id);
    return list;
  }

  Future<List<ProductDetails>> getOrderDetails(orderid) async {
    var qry =
        "SELECT P.product_id,P.name,P.price,group_concat(replace(asset.base64,'data:image/jpg;base64,','') , ' groupconcate_Image ') as base64 FROM order_detail O " +
            " LEFT JOIN product P ON O.product_id = P.product_id" +
            " LEFT join asset on asset.asset_type_id = P.product_id " +
            " WHERE  O.order_id = " +
            orderid.toString() +
            " group by p.product_id";

    var ordersList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<ProductDetails> list = ordersList.isNotEmpty
        ? ordersList.map((c) => ProductDetails.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Transactions", "get Orders  details list", "ProductDetails", orderid);
    return list;
  }

  Future<List<OrderDetail>> getOrderDetailsList(orderid) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();

    var ordersList = await db
        .query("order_detail", where: "order_id =?", whereArgs: [orderid]);
    List<OrderDetail> list = ordersList.isNotEmpty
        ? ordersList.map((c) => OrderDetail.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "invoice", "get Orders details list", "ProductDetails", orderid);
    return list;
  }

  Future<OrderPayment> getOrderpaymentData(orderid) async {
    var qry =
        "SELECT * from order_payment where app_id = " + orderid.toString();
    var ordersList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<OrderPayment> list = ordersList.isNotEmpty
        ? ordersList.map((c) => OrderPayment.fromJson(c)).toList()
        : [];
    return list[0];
  }

  Future<List<Voucher>> checkVoucherIsExit(code) async {
    var qry = "SELECT * from voucher  where voucher_code = '" + code + "'";
    var voucherList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<Voucher> list = voucherList.isNotEmpty
        ? voucherList.map((c) => Voucher.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity("voucher", "get voucher list", "voucher", 1);
    return list;
  }

  Future<List<ProductCategory>> getProductCategory(ids) async {
    var qry =
        "SELECT * from product_category WHERE product_id =  " + ids.toString();
    var voucherList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<ProductCategory> list = voucherList.isNotEmpty
        ? voucherList.map((c) => ProductCategory.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<dynamic> updateVoucher(MSTCartdetails details, voucherId) async {
    var qry = "Update mst_cart_detail SET discount = " +
        details.discount.toString() +
        " , discount_type = " +
        details.discountType.toString() +
        " where id = " +
        details.id.toString();
    var data = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    var qry1 = "Update mst_cart SET discount = (discount +" +
        details.discount.toString() +
        " ), discount_type = " +
        details.discountType.toString() +
        " , grand_total = (grand_total- " +
        details.discount.toString() +
        ") , voucher_id = " +
        voucherId.toString() +
        " where id = " +
        details.cartId.toString();
    var data1 = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry1);
    await SyncAPICalls.logActivity(
        "voucher", "add voucher in cart", "voucher", voucherId);
    return data1;
  }

  Future<MST_Cart> getCartData(cartid) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var cartdata =
        await db.query('mst_cart', where: 'id = ?', whereArgs: [cartid]);
    List<MST_Cart> list = cartdata.isNotEmpty
        ? cartdata.map((c) => MST_Cart.fromJson(c)).toList()
        : [];
    return list[0];
  }

  Future<Branch> getbranchData(branchID) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var cartdata = await db.query('branch',
        where: 'branch_id = ?', whereArgs: [branchID.toString()]);
    List<Branch> list = cartdata.isNotEmpty
        ? cartdata.map((c) => Branch.fromJson(c)).toList()
        : [];
    return list[0];
  }

  Future<Voucher> getvoucher(voucherid) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var voucher = await db.query('voucher',
        where: 'voucher_id = ?', whereArgs: [voucherid.toString()]);
    List<Voucher> list = voucher.isNotEmpty
        ? voucher.map((c) => Voucher.fromJson(c)).toList()
        : [];
    return list[0];
  }

  Future<dynamic> getVoucherusecount(voucherid) async {
    var qry =
        "SELECT count(voucher_id) from voucher_history where voucher_id = " +
            voucherid.toString();
    var count = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    return count;
  }

  Future<dynamic> saveVoucherHistory(VoucherHistory voucherHis) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var hitid = await db.insert("voucher_history", voucherHis.toJson());
    await SyncAPICalls.logActivity(
        "order", "add voucher history in cart", "voucher_history", hitid);
    return hitid;
  }

  Future<List<BranchTax>> getTaxList(branchid) async {
    var tax = await DatabaseHelper.dbHelper.getDatabse().query('branch_tax',
        where: 'branch_id = ?', whereArgs: [branchid.toString()]);
    List<BranchTax> list =
        tax.isNotEmpty ? tax.map((c) => BranchTax.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<Tax>> getTaxName(taxId) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var tax = await db.query('tax');
    List<Tax> list =
        tax.isNotEmpty ? tax.map((c) => Tax.fromJson(c)).toList() : [];
    return list;
  }

  Future<Payments> getOrderpaymentmethod(methodID) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var paymentMeth = await db.query('payment',
        where: 'payment_id = ?', whereArgs: [methodID.toString()]);
    List<Payments> list = paymentMeth.isNotEmpty
        ? paymentMeth.map((c) => Payments.fromJson(c)).toList()
        : [];
    return list[0];
  }

  Future<User> getPaymentUser(userid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var user = await db
        .query('users', where: 'id = ?', whereArgs: [userid.toString()]);
    List<User> list =
        user.isNotEmpty ? user.map((c) => User.fromJson(c)).toList() : [];
    return list[0];
  }

  // Future<dynamic> removePromocode(voucherid) async {
  //   var qry = "SELECT count(voucher_id) from orders where voucher_id = " +
  //       voucherid.toString();
  //   var count = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
  //   return count;
  // }
  Future<List<Orders>> getOrdersList(branchid, terminalid) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from orders where branch_id = " +
        branchid.toString() +
        " AND terminal_id = " +
        terminalid.toString() +
        " AND order_source = 2";

    var ordersList = await db.rawQuery(qry);
    List<Orders> list = ordersList.isNotEmpty
        ? ordersList.map((c) => Orders.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Transactions", "get Orders list", "Orders", branchid);
    return list;
  }

  Future<List<Orders>> getOrdersListTable(branchid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from orders where branch_id = " +
        branchid.toString() +
        " AND order_source = 2 AND server_id = 0";
    var ordersList = await db.rawQuery(qry);
    List<Orders> list = ordersList.isNotEmpty
        ? ordersList.map((c) => Orders.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Order sync", "get Orders list", "Orders", branchid);
    return list;
  }

  Future<List<OrderDetail>> getOrderDetailTable(orderid) async {
    var qry =
        "SELECT * from order_detail where order_id = " + orderid.toString();
    var ordersList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<OrderDetail> list = ordersList.isNotEmpty
        ? ordersList.map((c) => OrderDetail.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Order sync", "get Orders detail list", "Orders", orderid);
    return list;
  }

  Future<List<OrderAttributes>> getOrderAttributesTable(detailid) async {
    var qry =
        "SELECT * from order_attributes where  app_id = " + detailid.toString();

    var ordersList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<OrderAttributes> list = ordersList.isNotEmpty
        ? ordersList.map((c) => OrderAttributes.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Order sync", "get Orders_modifire list", "order_attribute", detailid);
    return list;
  }

  Future<List<OrderModifire>> getOrderModifireTable(detailid) async {
    var qry =
        "SELECT * from order_modifier where app_id = " + detailid.toString();
    var ordersList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<OrderModifire> list = ordersList.isNotEmpty
        ? ordersList.map((c) => OrderModifire.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Order sync", "get Orders Modifire Table", "order_modifier", detailid);
    return list;
  }

  Future<List<OrderPayment>> getOrderPaymentTable(orderid) async {
    var qry =
        "SELECT * from order_payment where app_id = " + orderid.toString();
    var ordersList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<OrderPayment> list = ordersList.isNotEmpty
        ? ordersList.map((c) => OrderPayment.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Order sync", "get Orders payment Table", "order_payment", orderid);
    return list;
  }

  Future<dynamic> sendToKitched(ids) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var qry = "update mst_cart_detail set is_send_kichen = 1 WHERE id in(" +
        ids.toString() +
        ")";
    var ordersList = await db.rawQuery(qry);
    await SyncAPICalls.logActivity(
        "Send to kitchen", "send item to kitchen", "mst_cart_detail", 1);
    return ordersList;
  }

  Future<List<ProductStoreInventory>> checkItemAvailableinStore(
      productId) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var inventoryProd = await db.query("product_store_inventory",
        where: 'product_id = ?', whereArgs: [productId]);
    List<ProductStoreInventory> list = inventoryProd.length > 0
        ? inventoryProd.map((c) => ProductStoreInventory.fromJson(c)).toList()
        : [];
    return list;
  }

  Future removeFromInventory(OrderDetail produtdata) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var inventoryProd = await db.query("product",
        where: 'product_id = ?', whereArgs: [produtdata.product_id]);
    List<Product> list = inventoryProd.isNotEmpty
        ? inventoryProd.map((c) => Product.fromJson(c)).toList()
        : [];

    if (list[0].hasInventory == 1) {
      var intupdate = "Update product_store_inventory set qty = (qty - " +
          produtdata.detail_qty.toString() +
          ") WHERE product_id = " +
          produtdata.product_id.toString();
      var updateed = await db.rawQuery(intupdate);
      await SyncAPICalls.logActivity("Order", "update InventoryTable",
          "product_store_inventory", produtdata.product_id);
    }
  }

  Future<int> updateInvetory(OrderDetail produtdata) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var inventoryProd = await db.query("product",
        where: 'product_id = ?', whereArgs: [produtdata.product_id]);
    List<Product> list = inventoryProd.isNotEmpty
        ? inventoryProd.map((c) => Product.fromJson(c)).toList()
        : [];

    if (list[0].hasInventory == 1) {
      var intupdate = "Update product_store_inventory set qty = (qty - " +
          produtdata.detail_qty.toString() +
          ") WHERE product_id = " +
          produtdata.product_id.toString();
      var updateed = await db.rawQuery(intupdate);
      await SyncAPICalls.logActivity("Order", "update InventoryTable",
          "product_store_inventory", produtdata.product_id);
    }
  }

  Future<int> updateStoreInvetoryLogTable(
      ProductDetails produtdata, orderdata) async {}

  Future<Branch> getBranchData(branchID) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var result =
        await db.query("branch", where: 'branch_id = ?', whereArgs: [branchID]);
    List<Branch> list =
        result.isNotEmpty ? result.map((c) => Branch.fromJson(c)).toList() : [];

    await SyncAPICalls.logActivity(
        "branch details", "branch details for invoice", "branch", branchID);
    return list[0];
  }

  // 1 For New,2 For Ongoing,3 For cancelled,4 For Completed,5 For Refunded
  Future<int> updateOrderStatus(orderid, status) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var qry = "UPDATE orders SET order_status = " +
        status.toString() +
        " where app_id = " +
        orderid.toString();
    var result = db.rawUpdate(qry);
    await SyncAPICalls.logActivity(
        "order staus change", "update order status", "order_status", orderid);
    if (result != null) {
      return 1;
    } else {
      return 0;
    }
  }

  Future<int> updatePaymentStatus(paymentid, status) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var qry = "UPDATE order_payment SET op_status = " +
        status.toString() +
        " where app_id = " +
        paymentid.toString();
    var result = db.rawUpdate(qry);
    if (result != null) {
      return 1;
    } else {
      return 0;
    }
  }

  Future<int> insertCancelOrder(CancelOrder order) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var result = db.insert('order_cancel', order.toJson());
    return result;
  }

  Future<List<Table_order>> getTableOrders(tableid) async {
    var qry =
        "SELECT * from table_order where table_id = " + tableid.toString();
    var tableList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<Table_order> list = tableList.isNotEmpty
        ? tableList.map((c) => Table_order.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<User>> checkUserExit(userpin) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from users where user_pin =" + userpin.toString();
    var user = await db.rawQuery(qry);
    List<User> list =
        user.isNotEmpty ? user.map((c) => User.fromJson(c)).toList() : [];
    return list;
  }

  Future<int> deleteOrderItem(detailid) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var result =
        db.rawDelete("DELETE FROM order_detail WHERE app_id = ?", [detailid]);
    return result;
  }

  Future<List<MST_Cart>> getCartList(branchid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var result = await db.rawQuery(
        "SELECT * FROM mst_cart WHERE branch_id = " + branchid.toString());
    List<MST_Cart> list = result.isNotEmpty
        ? result.map((c) => MST_Cart.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<Printer>> getPrinter(productID) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry =
        "SELECT * from printer where printer.printer_id = (Select printer_id from product_branch WHERE product_branch.product_id = $productID)";
    var result = await db.rawQuery(qry);
    List<Printer> list = result.isNotEmpty
        ? result.map((c) => Printer.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<Printer>> getAllPrinter() async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from printer where status = 1";
    var result = await db.rawQuery(qry);
    List<Printer> list = result.isNotEmpty
        ? result.map((c) => Printer.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<Printer>> getAllPrinterForKOT() async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from printer where status = 1 ";
    var result = await db.rawQuery(qry);
    List<Printer> list = result.isNotEmpty
        ? result.map((c) => Printer.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<Printer>> getAllPrinterForecipt() async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry =
        "SELECT * from printer where printer_is_cashier = 1 AND status = 1";
    var result = await db.rawQuery(qry);
    List<Printer> list = result.isNotEmpty
        ? result.map((c) => Printer.fromJson(c)).toList()
        : [];
    return list;
  }

  Future updateWebCart(MST_Cart cart) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT id from mst_cart where id = " + cart.id.toString();

    var res = await db.rawQuery(qry);
    List<MST_Cart> list =
        res.isNotEmpty ? res.map((c) => MST_Cart.fromJson(c)).toList() : [];
    var result;
    if (list.length > 0) {
      result = await db.update("mst_cart", cart.toJson(),
          where: "id =?", whereArgs: [cart.id]);
    } else {
      result = await db.insert("mst_cart", cart.toJson());
    }
    return result;
  }

  Future updateWebCartdetails(MSTCartdetails details) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry =
        "SELECT id from mst_cart_detail where id = " + details.id.toString();

    var res = await db.rawQuery(qry);
    List<MSTCartdetails> list = res.isNotEmpty
        ? res.map((c) => MSTCartdetails.fromJson(c)).toList()
        : [];
    var result;
    if (list.length > 0) {
      result = await db.update("mst_cart_detail", details.toJson(),
          where: "id =?", whereArgs: [details.id]);
    } else {
      result = await db.insert("mst_cart_detail", details.toJson());
    }
    return result;
  }

  Future updateWebCartsubdetails(MSTSubCartdetails subdata) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT id from mst_cart_sub_detail where id = " +
        subdata.id.toString();
    var res = await db.rawQuery(qry);
    List<MSTSubCartdetails> list = res.isNotEmpty
        ? res.map((c) => MSTSubCartdetails.fromJson(c)).toList()
        : [];
    var result;
    if (list.length > 0) {
      result = await db.update("mst_cart_sub_detail", subdata.toJson(),
          where: "id =?", whereArgs: [subdata.id]);
    } else {
      result = await db.insert("mst_cart_sub_detail", subdata.toJson());
    }
    return result;
  }

  Future<int> updateInvoice(Orders order) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var result;
    if (order.order_item_count > 0) {
      result = await db
          .delete("orders", where: "app_id =?", whereArgs: [order.app_id]);
    } else {
      result = await db.update("orders", order.toJson(),
          where: "app_id =?", whereArgs: [order.app_id]);
    }
    return result;
  }

  Future<List<ProductDetails>> productdData(productid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry =
        "SELECT product.*, price_type.name as price_type_Name  from product " +
            " LEFT join price_type on price_type.pt_id = product.price_type_id AND price_type.status = 1  where product_id = " +
            productid.toString();

    var res = await db.rawQuery(qry);
    List<ProductDetails> list = res.length > 0
        ? res.map((c) => ProductDetails.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<List<Role>> getRoldata(roleID) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from role WHERE role_id = " + roleID.toString();
    var res = await db.rawQuery(qry);
    List<Role> list =
        res.isNotEmpty ? res.map((c) => Role.fromJson(c)).toList() : [];
    return list;
  }

  Future saveSyncOrder(Orders orderData) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry =
        "SELECT *  FROM orders where app_id =" + orderData.app_id.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var orderid;
    if (checkisExit.length > 0) {
      orderid = await db.update("orders", orderData.toJson(),
          where: "app_id =?", whereArgs: [orderData.app_id]);
    } else {
      orderid = await db.insert("orders", orderData.toJson());
    }
    return orderid;
  }

  Future saveSyncOrderDetails(OrderDetail orderData) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry = "SELECT *  FROM order_detail where app_id =" +
        orderData.app_id.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var orderid;
    if (checkisExit.length > 0) {
      orderid = await db.update("order_detail", orderData.toJson(),
          where: "app_id =?", whereArgs: [orderData.app_id]);
    } else {
      orderid = await db.insert("order_detail", orderData.toJson());
    }
    return orderid;
  }

  Future saveSyncOrderPaymet(OrderPayment paymentdata) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry = "SELECT *  FROM order_payment where app_id =" +
        paymentdata.app_id.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var orderid;
    if (checkisExit.length > 0) {
      orderid = await db.update("order_payment", paymentdata.toJson(),
          where: "app_id =?", whereArgs: [paymentdata.app_id]);
    } else {
      orderid = await db.insert("order_payment", paymentdata.toJson());
    }
    return orderid;
  }

  Future saveSyncOrderModifire(OrderModifire orderData) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry = "SELECT *  FROM order_modifier where app_id =" +
        orderData.app_id.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var orderid;
    if (checkisExit.length > 0) {
      orderid = await db.update("order_modifier", orderData.toJson(),
          where: "app_id =?", whereArgs: [orderData.app_id]);
    } else {
      orderid = await db.insert("order_modifier", orderData.toJson());
    }
    return orderid;
  }

  Future saveSyncOrderAttribute(OrderAttributes orderData) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry = "SELECT *  FROM order_attributes where app_id =" +
        orderData.app_id.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var orderid;
    if (checkisExit.length > 0) {
      orderid = await db.update("order_attributes", orderData.toJson(),
          where: "app_id =?", whereArgs: [orderData.app_id]);
    } else {
      orderid = await db.insert("order_attributes", orderData.toJson());
    }
    return orderid;
  }

  Future<List<CancelOrder>> getCancleOrder(branchid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from order_cancel where terminal_id = " +
        branchid.toString() +
        "AND server_id = 0";
    var ordersList = await db.rawQuery(qry);
    List<CancelOrder> list = ordersList.length > 0
        ? ordersList.map((c) => CancelOrder.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Order sync", "get Orders list", "Orders", branchid);
    return list;
  }

  Future<List<PosPermission>> getUserPermissions(userid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = " SELECT  group_concat(pos_permission.pos_permission_name) as pos_permission_name  from users" +
        " Left join user_pos_permission on user_pos_permission.user_id = users.id" +
        " left join pos_permission on pos_permission.pos_permission_id = user_pos_permission.pos_permission_id" +
        " WHERE user_id  =" +
        userid.toString();

    var permissionList = await db.rawQuery(qry);
    List<PosPermission> list = permissionList.length > 0
        ? permissionList.map((c) => PosPermission.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity("get PosPermission",
        "get PosPermission list", "pos_permission", userid);
    return list;
  }
}
