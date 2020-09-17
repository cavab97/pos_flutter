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
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/models/Table_order.dart';
import 'package:mcncashier/models/TableDetails.dart';
import 'package:mcncashier/models/mst_sub_cart_details.dart';
import 'package:mcncashier/models/saveOrder.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/Order_Modifire.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/OrderAttributes.dart';

class LocalAPI {
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
    return list;
  }

  Future<List<ProductDetails>> getProduct(String id, String branchID) async {
    var query = "SELECT product.*,group_concat(replace(asset.base64,'data:image/jpg;base64,','') , ' groupconcate_Image ') as base64 ,product_store_inventory.qty FROM `product` " +
        " LEFT join product_category on product_category.product_id = product.product_id " +
        " LEFT join  product_branch on product_branch.product_id = product.product_id " +
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
    return list;
  }

  Future<int> addCustomer(Customer customer) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var result = await db.insert("customer", customer.toJson());
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

    return list;
  }

  Future<int> insertItemTocart(cartidd, MST_Cart cartData,
      ProductDetails product, SaveOrder orderData, tableiD, subCartData) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var cartid;
    if (cartidd == null) {
      cartid = await db.insert("mst_cart", cartData.toJson());
    } else {
      var res_cartid = await db.update("mst_cart", cartData.toJson(),
          where: '${cartData.id} = ?', whereArgs: [cartidd]);
      cartid = cartidd;
    }
    orderData.cartId = cartid; //cartid
    var response = await db.insert("save_order", orderData.toJson());
    if (tableiD != null) {
      var rawQuery = 'UPDATE table_order set save_order_id = ' +
          response.toString() +
          " WHERE table_id = " +
          tableiD.toString();
      var tablesaved = await db.rawQuery(rawQuery);
      print(tablesaved);
    }
    var detailID = await addintoCartDetails(cartid, cartData, product);
    return detailID;
  }

  Future<int> addintoCartDetails(
      id, MST_Cart cartData, ProductDetails product) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    MSTCartdetails cartdetails = new MSTCartdetails();
    cartdetails.cartId = id;
    cartdetails.productId = product.productId;
    cartdetails.productName = product.name;
    cartdetails.productPrice = product.price;
    cartdetails.productQty = product.qty;
    cartdetails.discount = 0;
    cartdetails.taxValue = 0;
    cartdetails.createdAt = DateTime.now().toString();
    var result1 = await db.insert("mst_cart_detail", cartdetails.toJson());
    print(result1);
    return result1;
  }

  Future<int> addsubCartData(MSTSubCartdetails data) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var result1 = await db.insert("mst_cart_sub_detail", data.toJson());
    print(result1);
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
    return list;
  }

  Future<List<MSTCartdetails>> getCartItem(cartId) async {
    var qry =
        "SELECT * from mst_cart_detail where cart_id = " + cartId.toString();
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<MSTCartdetails> list = res.isNotEmpty
        ? res.map((c) => MSTCartdetails.fromJson(c)).toList()
        : [];
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
    return shiftid;
  }

  Future<List<SaveOrder>> getSaveOrder(id) async {
    var qry = "SELECT * from save_order WHERE id =" + id.toString();
    List<Map> res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<SaveOrder> list =
        res.isNotEmpty ? res.map((c) => SaveOrder.fromJson(c)).toList() : [];
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

    return list;
  }

  Future<List<MST_Cart>> getCurrentCart(cartID) async {
    var query = "SELECT * from mst_cart where id=" + cartID.toString();
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<MST_Cart> list =
        res.isNotEmpty ? res.map((c) => MST_Cart.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<Payments>> getPaymentMethods() async {
    var query = "SELECT * from payment where status = 1";
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<Payments> list =
        res.isNotEmpty ? res.map((c) => Payments.fromJson(c)).toList() : [];
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
    var orderid = await db.insert("order_modifier", orderDetailData.toJson());
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
    return paymentData.app_id;
  }

  Future<int> removeCartItem(cartid) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();

    var cart = // cart table
        await db.delete("mst_cart", where: 'id = ?', whereArgs: [cartid]);
    print(cart);

    var saveOrder = // cart table
        await db
            .delete("save_order", where: 'cart_id = ?', whereArgs: [cartid]);
    print(saveOrder);

    var tableOrder = // cart table
        await db
            .delete("table_order", where: 'table_id = ?', whereArgs: [cartid]);
    print(saveOrder);

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
    // cart details
    var cartd = await db
        .delete("mst_cart_detail", where: 'cart_id = ?', whereArgs: [cartid]);
    print(cart);
    return cartd;
  }
}
