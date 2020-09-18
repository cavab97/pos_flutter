import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Attribute_data.dart';
import 'package:mcncashier/models/Category.dart';
import 'package:mcncashier/models/CheckInout.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/ModifireData.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/Product.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/models/Table_order.dart';
import 'package:mcncashier/models/TableDetails.dart';
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
    var branchID = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
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
    var query = "SELECT product.*,group_concat(replace(asset.base64,'data:image/jpg;base64,','') , ' groupconcate_Image ') as base64 ,product_store_inventory.qty , price_type.name as price_type_Name FROM `product` " +
        " LEFT join product_category on product_category.product_id = product.product_id " +
        " LEFT join  product_branch on product_branch.product_id = product.product_id " +
        " LEFT join price_type on price_type.pt_id = product.price_type_id AND price_type.status = 1 " +
        " LEFT join asset on asset.asset_type = 1 AND asset.asset_type_id = product.product_id " +
        " LEFT join product_store_inventory  ON  product_store_inventory.product_id = product.product_id and product_store_inventory.status = 1 " +
        " where product_category.category_id = " +
        id +
        " AND product_branch.branch_id = " +
        branchID +
        " AND product_store_inventory.branch_id  = " +
        branchID +
        " AND product.status = 1"
            " GROUP By product.product_id";
    List<Map> res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<ProductDetails> list = res.isNotEmpty
        ? res.map((c) => ProductDetails.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Product", "geting Product List", "product", id);
    return list;
  }

  Future<List<Customer>> getCustomers(teminalID) async {
    var query = "SELECT * from customer WHERE " +
        " customer.status = 1 " +
        " AND customer.terminal_id = " +
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

  Future<int> insertShift(Shift shift) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var result;
    if (shift.shiftId != null) {
      result = await db.update("shift", shift.toJson(),
          where: '${shift.shiftId} = ?', whereArgs: [shift.shiftId]);
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
        " WHERE product.product_id = 3  GROUP by category_attribute.ca_id";
    List<Map> res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<Attribute_Data> list = res.isNotEmpty
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
    } else {
      var res_cartid = await db.update("mst_cart", cartData.toJson(),
          where: '${cartData.id} = ?', whereArgs: [cartidd]);
      cartid = cartidd;
      await SyncAPICalls.logActivity(
          "product", "Product update in to cart", "mst_cart", res_cartid);
    }

    return cartid;
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
        "product", "insert cart details", "mst_cart_detail", cartdetailid);
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
          where: '${clockinOutData.id} = ?', whereArgs: [clockinOutData.id]);
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

  Future<List<Payments>> getPaymentMethods() async {
    var query = "SELECT * from payment where status = 1";
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<Payments> list =
        res.isNotEmpty ? res.map((c) => Payments.fromJson(c)).toList() : [];
    await SyncAPICalls.logActivity("payment", "get payment list", "payment", 1);

    return list;
  }

  Future<int> placeOrder(Orders orderData) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry =
        "SELECT *  FROM orders where app_id =" + orderData.app_id.toString();
    var checkisExit =
        await DatabaseHelper.dbHelper.getDatabse().rawQuery(checkisExitqry);
    if (checkisExit.length > 0) {
      List<Orders> list = checkisExit.isNotEmpty
          ? checkisExit.map((c) => Orders.fromJson(c)).toList()
          : [];
      orderData.app_id = list[0].app_id + 1;
    }
    var orderid = await db.insert("orders", orderData.toJson());

    await SyncAPICalls.logActivity("orders", "place order", "orders", orderid);
    return orderData.app_id;
  }

  Future<int> sendOrderDetails(OrderDetail orderDetailData) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry = "SELECT *  FROM order_detail where app_id =" +
        orderDetailData.app_id.toString();
    var checkisExit =
        await DatabaseHelper.dbHelper.getDatabse().rawQuery(checkisExitqry);
    if (checkisExit.length > 0) {
      List<OrderDetail> list = checkisExit.isNotEmpty
          ? checkisExit.map((c) => OrderDetail.fromJson(c)).toList()
          : [];
      orderDetailData.app_id = list[0].app_id + 1;
    }
    var orderid = await db.insert("order_detail", orderDetailData.toJson());
    await SyncAPICalls.logActivity(
        "orders", "insert order details", "order_detail", orderid);
    return orderDetailData.app_id;
  }

  Future<int> sendModifireData(OrderModifire orderDetailData) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry = "SELECT *  FROM order_modifier where app_id =" +
        orderDetailData.app_id.toString();
    var checkisExit =
        await DatabaseHelper.dbHelper.getDatabse().rawQuery(checkisExitqry);
    if (checkisExit.length > 0) {
      List<OrderModifire> list = checkisExit.isNotEmpty
          ? checkisExit.map((c) => OrderModifire.fromJson(c)).toList()
          : [];
      orderDetailData.app_id = list[0].app_id + 1;
    }
    var orderid = await db.insert("order_modifier", orderDetailData.toJson());
    await SyncAPICalls.logActivity(
        "orders", "insert order modifier", "order_modifier", orderid);
    return orderDetailData.app_id;
  }

  Future<int> sendAttrData(OrderAttributes orderDetailData) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry = "SELECT *  FROM order_attributes where app_id =" +
        orderDetailData.app_id.toString();
    var checkisExit =
        await DatabaseHelper.dbHelper.getDatabse().rawQuery(checkisExitqry);
    if (checkisExit.length > 0) {
      List<OrderAttributes> list = checkisExit.isNotEmpty
          ? checkisExit.map((c) => OrderAttributes.fromJson(c)).toList()
          : [];
      orderDetailData.app_id = list[0].app_id + 1;
    }
    var orderid = await db.insert("order_attributes", orderDetailData.toJson());
    await SyncAPICalls.logActivity(
        "orders", "insert order attributes", "order_attributes", orderid);
    return orderDetailData.app_id;
  }

  Future<int> sendtoOrderPayment(OrderPayment paymentData) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry = "SELECT *  FROM order_payment where app_id =" +
        paymentData.app_id.toString();
    var checkisExit =
        await DatabaseHelper.dbHelper.getDatabse().rawQuery(checkisExitqry);
    if (checkisExit.length > 0) {
      List<OrderPayment> list = checkisExit.isNotEmpty
          ? checkisExit.map((c) => OrderPayment.fromJson(c)).toList()
          : [];
      paymentData.app_id = list[0].app_id + 1;
    }
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

  Future<int> deleteCartItem(cartItem, cartID, isLast) async {
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

  Future<List<Orders>> getOrdersList(branchid, terminalid) async {
    var qry = "SELECT * from orders where branch_id = " +
        branchid.toString() +
        " AND terminal_id = " +
        terminalid.toString();

    var ordersList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<Orders> list = ordersList.isNotEmpty
        ? ordersList.map((c) => Orders.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<ProductDetails>> getOrderDetails(orderid) async {
    var qry = "SELECT product.product_id,product.name,product.has_inventory  ," +
        " replace(product.price ,product.price,order_detail.product_price) as price ,group_concat(replace(asset.base64,'data:image/jpg;base64,','') ," +
        " ' groupconcate_Image ') as base64  from order_detail  " +
        " LEFT join product on product.product_id = order_detail.product_id " +
        " LEFT join asset on asset.asset_type = 1 AND " +
        " asset.asset_type_id = product.product_id  where order_detail.order_id =" +
        orderid.toString();

    var ordersList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<ProductDetails> list = ordersList.isNotEmpty
        ? ordersList.map((c) => ProductDetails.fromJson(c)).toList()
        : [];
    return list;
  }
}
