import 'dart:convert';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Attribute_data.dart';
import 'package:mcncashier/models/Box.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/models/Category.dart';
import 'package:mcncashier/models/CheckInout.dart';
import 'package:mcncashier/models/Citys.dart';
import 'package:mcncashier/models/Countrys.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/Customer_Liquor_Inventory.dart';
import 'package:mcncashier/models/Customer_Liquor_Inventory_Log.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/colorTable.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/ModifireData.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/PosPermission.dart';
import 'package:mcncashier/models/Printer.dart';
import 'package:mcncashier/models/Product.dart';
import 'package:mcncashier/models/ProductStoreInventoryLog.dart';
import 'package:mcncashier/models/Product_Store_Inventory.dart';
import 'package:mcncashier/models/BranchTax.dart';
import 'package:mcncashier/models/Rac.dart';
import 'package:mcncashier/models/Role.dart';
import 'package:mcncashier/models/SetMeal.dart';
import 'package:mcncashier/models/SetMealProduct.dart';
import 'package:mcncashier/models/ShiftInvoice.dart';
import 'package:mcncashier/models/States.dart';
import 'package:mcncashier/models/Tax.dart';
import 'package:mcncashier/models/Terminal.dart';
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
import 'package:mcncashier/models/Drawer.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/Order_Modifire.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/OrderAttributes.dart';
import 'package:mcncashier/models/TerminalLog.dart';
import 'package:mcncashier/services/allTablesSync.dart';
import 'package:sqflite/sqflite.dart';

class LocalAPI {
  Future<int> terminalLog(TerminalLog log) async {
    try {
      var db = DatabaseHelper.dbHelper.getDatabse();
      var result = await db.insert("terminal_log", log.toJson());
      return result;
    } catch (e) {
      print(e);
    }
  }

  Future<Terminal> getTerminalDetails(terminalkey) async {
    var query = "SELECT * from terminal WHERE terminal_id  =$terminalkey";
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    Terminal terminalDat;
    List<Terminal> list =
        res.length > 0 ? res.map((c) => Terminal.fromJson(c)).toList() : [];
    print(list.length);
    if (list.length > 0) {
      terminalDat = list[0];
    }
    return terminalDat;
  }

  Future<List<Category>> getAllCategory() async {
    var branchID = await CommunFun.getbranchId();
    var query = "select * from category left join category_branch on " +
        " category_branch.category_id = category.category_id AND category_branch.status=1 where " +
        " category_branch.branch_id =" +
        branchID.toString() +
        " AND category.status = 1 order by category_branch.display_order ASC";

    List<Map> res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<Category> list =
        res.isNotEmpty ? res.map((c) => Category.fromJson(c)).toList() : [];

    await SyncAPICalls.logActivity(
        "Product", "geting category List", "category", branchID);
    return list;
  }

  Future<List<ProductDetails>> getProduct(String id, String branchID) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var query = "SELECT product.*,price_type.name as price_type_Name,asset.base64,product_store_inventory.qty,box.product_id as box_pId,category_attribute.name as attr_cat ,modifier.name as modifire_Name FROM `product` " +
        " LEFT JOIN product_category on product_category.product_id = product.product_id AND product_category.status = 1" +
        " LEFT JOIN product_branch on product_branch.product_id = product.product_id AND product_branch.status = 1" +
        " LEFT JOIN price_type on price_type.pt_id = product.price_type_id AND price_type.status = 1 " +
        " LEFT JOIN asset on asset.asset_type = 1 AND asset.asset_type_id = product.product_id AND asset.status = 1" +
        " LEFT JOIN product_attribute on product_attribute.product_id = product.product_id and product_attribute.status = 1" +
        " LEFT JOIN category_attribute on category_attribute.ca_id = product_attribute.ca_id and category_attribute.status = 1" +
        " LEFT JOIN attributes on attributes.attribute_id = product_attribute.attribute_id and attributes.status = 1" +
        " LEFT JOIN product_modifier on  product_modifier.product_id = product.product_id AND product_modifier.status = 1 " +
        " LEFT JOIN modifier on modifier.modifier_id = product_modifier.modifier_id AND modifier.status = 1 " +
        " LEFT JOIN product_store_inventory  ON  product_store_inventory.product_id = product.product_id and product_store_inventory.status = 1 " +
        " LEFT JOIN box ON box.product_id = product.product_id and box.status = 1 " +
        " where product_category.category_id = " +
        id.toString() +
        " AND product_branch.branch_id = " +
        branchID.toString() +
        " AND product.status = 1 AND product.has_setmeal = 0 GROUP By product.product_id";
    var res = await db.rawQuery(query);
    List<ProductDetails> list = res.length > 0
        ? res.map((c) => ProductDetails.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Product", "Getting Product List", "product", id);
    return list;
  }

  Future<List<ProductDetails>> getSeachProduct(
      String searchText, String branchID) async {
    var query = "SELECT product.*,base64 ,product_store_inventory.qty, price_type.name as price_type_Name FROM `product` " +
        " LEFT join price_type on price_type.pt_id = product.price_type_id AND price_type.status = 1 " +
        " LEFT join asset on asset.asset_type = 1 AND asset.asset_type_id = product.product_id " +
        " LEFT join product_store_inventory  ON  product_store_inventory.product_id = product.product_id and product_store_inventory.status = 1 " +
        " where product.status = 1 AND product.has_setmeal = 0 AND " +
        " (product.name LIKE '%$searchText%' OR product.sku LIKE '%$searchText%')" +
        " GROUP By product.product_id";

    List<Map> res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<ProductDetails> list = res.isNotEmpty
        ? res.map((c) => ProductDetails.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Product", "geting Product List", "product", "1");
    return list;
  }

  Future<List<SetMeal>> getSearchSetMealsData(
      String searchText, String branchid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "select setmeal.* ,base64  from setmeal " +
        " LEFT join setmeal_branch on setmeal_branch_id =" +
        branchid +
        " AND setmeal_branch.setmeal_id = setmeal.setmeal_id " +
        " LEFT join setmeal_product on setmeal_product.setmeal_id = setmeal.setmeal_id " +
        " LEFT join asset on asset.asset_type = 2 AND asset.asset_type_id = setmeal.setmeal_id  " +
        " where setmeal.name LIKE '%$searchText%'" +
        "GROUP by setmeal.setmeal_id ";
    var mealList = await db.rawQuery(qry);
    List<SetMeal> list = mealList.isNotEmpty
        ? mealList.map((c) => SetMeal.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Meals List", "get Meals List", "setmeal", branchid);
    return list;
  }

  Future<List<Customer>> getCustomers(teminalID) async {
    var query = "SELECT * from customer WHERE customer.status = 1 ";
    teminalID;
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<Customer> list =
        res.isNotEmpty ? res.map((c) => Customer.fromJson(c)).toList() : [];
    await SyncAPICalls.logActivity(
        "Customer", "geting customer list", "customer", teminalID);
    return list;
  }

  Future<int> saveCustomersFromServer(Customer customer) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry =
        "SELECT *  FROM customer where app_id =" + customer.appId.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var result;
    if (checkisExit.length > 0) {
      result = await db.update("customer", customer.toJson(),
          where: "app_id =?", whereArgs: [customer.appId]);
    } else {
      result = await db.insert("customer", customer.toJson());
    }
    await SyncAPICalls.logActivity("sync customer", "sync customer from server",
        "customer", customer.appId);
    return result;
  }

  Future<int> addCustomer(Customer customer) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var result = await db.insert("customer", customer.toJson());
    await SyncAPICalls.logActivity(
        "Customer", "add customer", "customer", result);
    return result;
  }

  Future<List<TablesDetails>> getTables(branchid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    String ctime = await CommunFun.getCurrentDateTime(DateTime.now());
    var query = "SELECT tables.*, table_order.save_order_id,table_order.assing_time as assignTime,table_order.number_of_pax ,table_order.is_merge_table " +
        " as is_merge_table,(JulianDay('" +
        ctime +
        "') - JulianDay(table_order.assing_time) " +
        " ) * 24 * 60 as occupiedMin, table_order.merged_table_id as merged_table_id, " +
        " (select tables.table_name from tables where table_order.merged_table_id = tables.table_id) as merge_table_name from tables " +
        " LEFT JOIN table_order on table_order.table_id = tables.table_id " +
        " WHERE tables.status = 1 AND branch_id = " +
        branchid +
        " GROUP by tables.table_id";
    var res = await db.rawQuery(query);
    List<TablesDetails> list = res.isNotEmpty
        ? res.map((c) => TablesDetails.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Tables", "Getting Tables list", "tables", branchid);
    return list;
  }

  Future<List<ColorTable>> getTablesColor() async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var query =
        "SELECT * FROM table_color where status = 1 ORDER by time_minute ASC ";
    var res = await db.rawQuery(query);
    List<ColorTable> list =
        res.isNotEmpty ? res.map((c) => ColorTable.fromJson(c)).toList() : [];
    await SyncAPICalls.logActivity(
        "Tables colors", "Getting Tables colors list", "tablescolor", 1);
    return list;
  }

  Future<int> insertTableOrder(Table_order table_order) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
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

  Future<int> mergeTableOrder(Table_order table_order) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from table_order where table_id =" +
        table_order.merged_table_id.toString();
    var res = await db.rawQuery(qry);
    List<Table_order> list =
        res.isNotEmpty ? res.map((c) => Table_order.fromJson(c)).toList() : [];
    if (list.length > 0) {
      if (list[0].save_order_id != 0) {
        List<SaveOrder> cartIDs =
            await localAPI.gettableCartID(list[0].save_order_id);
        if (table_order.save_order_id == 0 && list[0].save_order_id != 0) {
          if (cartIDs.length > 0) {
            var qry1 = "UPDATE mst_cart SET table_id = " +
                table_order.table_id.toString() +
                " where id = " +
                cartIDs[0].cartId.toString();
            var result1 = await db.rawQuery(qry1);
            list[0].table_id = table_order.table_id;
            var qry2 = "UPDATE table_order SET table_id = " +
                table_order.table_id.toString() +
                " where table_id = " +
                list[0].table_id.toString();
            var res = await db.rawQuery(qry2);
            var qrysabve = "UPDATE save_order SET cart_id = " +
                cartIDs[0].cartId.toString() +
                " where id = " +
                list[0].save_order_id.toString();
            var res1 = await db.rawQuery(qrysabve);
            table_order.save_order_id = list[0].save_order_id;
          }
        } else {
          if (table_order.save_order_id != 0 && cartIDs.length > 0) {
            List<SaveOrder> carts =
                await localAPI.gettableCartID(table_order.save_order_id);
            if (carts.length > 0) {
              var detailqry = "UPDATE mst_cart_detail SET cart_id = " +
                  carts[0].cartId.toString() +
                  " where cart_id = " +
                  cartIDs[0].cartId.toString();
              var res1 = await db.rawQuery(detailqry);
            }
          }
          await deleteTableOrder(list[0].table_id);
          await deleteSaveOrder(list[0].save_order_id);
        }
      } else {
        await deleteTableOrder(list[0].table_id);
        await deleteSaveOrder(list[0].save_order_id);
      }
    }

    await insertTableOrder(table_order);
    await SyncAPICalls.logActivity(
        " Orders Tables",
        list.length > 0 ? "Update table Order" : "Insert table Order",
        "table_order",
        table_order.table_id);
    return 1;
  }

  Future deleteTableOrder(tableID) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    await db.delete("table_order", where: 'table_id = ?', whereArgs: [tableID]);
    await SyncAPICalls.logActivity(
        "table Order", "delete table Order", "table_order", tableID);
  }

  Future deleteSaveOrder(id) async {
    if (id != 0) {
      var db = DatabaseHelper.dbHelper.getDatabse();
      await db.delete("save_order", where: 'id  =?', whereArgs: [id]);
      await SyncAPICalls.logActivity(
          "delete save Order", "delete save Order", "save_order", id);
    }
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
    return list;
  }

  Future<int> insertShift(Shift shift, shiftId) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var result;
    if (shiftId != null) {
      var qry = "UPDATE shift set end_amount = " +
          shift.endAmount.toString() +
          " ,updated_at = '" +
          shift.updatedAt +
          "' where app_id = " +
          shift.appId.toString();
      result = await db.rawQuery(qry);
    } else {
      result = await db.insert("shift", shift.toJson());
    }
    var dis = shiftId != null ? "Update shift" : "Insert shift";
    await SyncAPICalls.logActivity("Product", dis, "shift", shift.appId);
    return shift.appId;
  }

  Future<List<Shift>> getShiftData(shiftId) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var result =
        await db.query('shift', where: "app_id = ?", whereArgs: [shiftId]);
    List<Shift> list =
        result.isNotEmpty ? result.map((c) => Shift.fromJson(c)).toList() : [];
    await SyncAPICalls.logActivity("shift", "shift data", "shift", shiftId);
    return list;
  }

  Future<List<Attribute_Data>> getProductDetails(productId) async {
    var qry = " SELECT product.product_id, category_attribute.name as attr_name,attributes.ca_id, " +
        " group_concat(product_attribute.price) as attr_types_price,group_concat(attributes.name) as attr_types ,group_concat(attributes.attribute_id) as attributeId , group_concat(attributes.is_default) as is_default" +
        " FROM product LEFT JOIN product_attribute on product_attribute.product_id = product.product_id and product_attribute.status = 1" +
        " LEFT JOIN category_attribute on category_attribute.ca_id = product_attribute.ca_id and category_attribute.status = 1" +
        " LEFT JOIN attributes on attributes.attribute_id = product_attribute.attribute_id and attributes.status = 1 " +
        " WHERE product.product_id = " +
        productId.toString() +
        " AND product_attribute.product_id = " +
        productId.toString() +
        " GROUP by category_attribute.ca_id";
    List<Map> res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<Attribute_Data> list = res.length > 0
        ? res.map((c) => Attribute_Data.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Product", "Getting Product details", "product", productId);
    return list;
  }

  Future<List<ModifireData>> getProductModifeir(productId) async {
    var qry =
        "SELECT modifier.name,modifier.modifier_id,modifier.is_default,product_modifier.pm_id,product_modifier.price FROM  product_modifier " +
            " LEFT JOIN modifier on modifier.modifier_id = product_modifier.modifier_id " +
            " WHERE product_modifier.product_id = " +
            productId.toString() +
            " AND product_modifier.status = 1" +
            " GROUP by product_modifier.pm_id";
    List<Map> res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<ModifireData> list =
        res.isNotEmpty ? res.map((c) => ModifireData.fromJson(c)).toList() : [];
    await SyncAPICalls.logActivity(
        "Product", "Getting Product modifire", "modifier", productId);
    return list;
  }

  Future<int> insertItemTocart(cartidd, MST_Cart cartData,
      ProductDetails product, SaveOrder orderData, tableiD) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
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

    await SyncAPICalls.logActivity(
        "weborder", "update table_id", "mst_cart", tableiD.toString());
    return 1;
  }

  Future<int> addintoCartDetails(cartdetails) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var cartdetailid;
    var newObj = cartdetails.toJson();
    newObj.remove("attrName");
    newObj.remove("modiName");
    if (cartdetails.id != null) {
      cartdetailid = db.update("mst_cart_detail", newObj,
          where: 'id = ?', whereArgs: [cartdetails.id]);
      cartdetailid = cartdetails.id;
    } else {
      cartdetailid = await db.insert("mst_cart_detail", newObj);
    }
    await SyncAPICalls.logActivity(
        "product", "insert  cart details", "mst_cart_detail", cartdetailid);
    return cartdetailid;
  }

  Future<int> deletesubcartDetail(cartdetailsId) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var result = await db.delete("mst_cart_sub_detail",
        where: "cart_details_id =?", whereArgs: [cartdetailsId]);
    await SyncAPICalls.logActivity(
        "cart", "delete sub cart Detail", "mst_sub_cart_detail", cartdetailsId);
    return result;
  }

  Future<int> addsubCartData(MSTSubCartdetails data) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var result1 = await db.insert("mst_cart_sub_detail", data.toJson());
    await SyncAPICalls.logActivity(
        "product", "insert sub cart details", "mst_cart_sub_detail", result1);
    return result1;
  }

  Future<List<MSTSubCartdetails>> itemmodifireList(detailid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT  * from mst_cart_sub_detail WHERE cart_details_id  = " +
        detailid.toString();
    var res = await db.rawQuery(qry);
    List<MSTSubCartdetails> list = res.isNotEmpty
        ? res.map((c) => MSTSubCartdetails.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "product", "get cart modifier list", "mst_cart_sub_detail", detailid);
    return list;
  }

  Future<List<MSTCartdetails>> getCartItem(cartId) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = " SELECT mst_cart_detail.* ,group_concat(attributes.name) as attrName ,group_concat(modifier.name) as modiName from mst_cart_detail " +
        " LEFT JOIN mst_cart_sub_detail on mst_cart_sub_detail.cart_details_id = mst_cart_detail.id AND  (mst_cart_sub_detail.attribute_id != '' OR mst_cart_sub_detail.modifier_id != '' )" +
        " LEFT JOIN attributes on attributes.attribute_id = mst_cart_sub_detail.attribute_id  AND  mst_cart_sub_detail.attribute_id != " +
        " '' " +
        " LEFT JOIN modifier on modifier.modifier_id = mst_cart_sub_detail.modifier_id AND mst_cart_sub_detail.modifier_id != " +
        " '' " +
        " where cart_id =" +
        cartId.toString() +
        " group by mst_cart_detail.id";
    var res = await db.rawQuery(qry);
    List<MSTCartdetails> list = res.isNotEmpty
        ? res.map((c) => MSTCartdetails.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "product", "get cart list", "mst_cart_detail", cartId);
    return list;
  }

  /*Future<List<MSTCartdetails>> getSplitBillData(cartId) async {
    var qry =
        "SELECT mst_cart_detail.*, replace(asset.base64,'data:image/jpg;base64,','') as base64  FROM `mst_cart_detail` LEFT join asset on asset.asset_type = 1 AND asset.asset_type_id = mst_cart_detail.product_id  where cart_id =  " +
            cartId.toString();
    ;
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<MSTCartdetails> list = res.isNotEmpty
        ? res.map((c) => MSTCartdetails.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "product", "get split bill data", "mst_cart_detail", cartId);
    return list;
  }*/

  Future<int> deleteCartItemFromSplitBill(
      cartItem, cartID, mainCart, isLast) async {
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

  Future<int> userCheckInOut(CheckinOut clockinOutData) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var shiftid;
    if (clockinOutData.status == "IN") {
      shiftid = await db.insert("user_checkinout", clockinOutData.toJson());
    } else {
      shiftid = await db.update("user_checkinout", clockinOutData.toJson(),
          where: 'id = ?', whereArgs: [clockinOutData.id]);
    }
    var dis = clockinOutData.status == "IN" ? "User checkin" : "user checkout";
    await SyncAPICalls.logActivity(
        "PIN number", dis, "user_checkinout", clockinOutData.userId);
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
    var query = "SELECT payment.* , base64  from payment " +
        " LEFT join asset on asset.asset_type = 3 AND asset.asset_type_id = payment.payment_id " +
        " WHERE payment.status = 1";
    //var query = "SELECT *  from payment WHERE status = 1";
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<Payments> list =
        res.isNotEmpty ? res.map((c) => Payments.fromJson(c)).toList() : [];
    await SyncAPICalls.logActivity("payment", "get payment list", "payment", 1);
    return list;
  }

  Future<Orders> getcurrentOrders(orderid, terminalID) async {
    var query =
        "SELECT * from orders WHERE app_id=$orderid AND terminal_id=$terminalID";
    //var query = "SELECT *  from payment WHERE status = 1";
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);

    /* var db = DatabaseHelper.dbHelper.getDatabse();
    var result =
        await db.query('orders', where: "app_id = ?", whereArgs: [orderid]);*/
    Orders order;
    List<Orders> list =
        res.length > 0 ? res.map((c) => Orders.fromJson(c)).toList() : [];
    if (list.length > 0) {
      order = list[0];
    }
    return order;
  }

  Future<List<OrderAttributes>> getOrderAttributes(orderid) async {
    var query = "SELECT order_attributes.*,attributes.name from order_attributes " +
        " LEFT join attributes on attributes.attribute_id =  order_attributes.attribute_id WHERE order_attributes.order_app_id = " +
        orderid.toString();
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<OrderAttributes> list = res.isNotEmpty
        ? res.map((c) => OrderAttributes.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<OrderModifire>> getOrderModifire(orderid) async {
    var query = "SELECT order_modifier.*,modifier.name  from order_modifier " +
        " LEFT JOIN modifier on modifier.modifier_id = order_modifier.modifier_id" +
        " WHERE order_modifier.order_app_id  = " +
        orderid.toString();
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<OrderModifire> list = res.isNotEmpty
        ? res.map((c) => OrderModifire.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<Orders>> getLastOrderAppid(terminalid) async {
    var qey = "SELECT orders.app_id from orders where terminal_id =" +
        terminalid +
        " ORDER BY order_date DESC LIMIT 1";
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
            "  ORDER BY app_id DESC LIMIT 1";
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
            "  ORDER BY app_id DESC LIMIT 1";
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
            "  ORDER BY app_id DESC LIMIT 1";
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
            "  ORDER BY app_id DESC LIMIT 1";
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
    var data = orderDetailData.toJson();
    data.remove("base64");
    var orderid = await db.insert("order_detail", data);
    await SyncAPICalls.logActivity(
        "orders", "insert order details", "order_detail", orderid);
    return orderDetailData.app_id;
  }

  Future<int> sendModifireData(OrderModifire orderDetailData) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var newObj = orderDetailData.toJson();
    newObj.remove("name");
    var orderid = await db.insert("order_modifier", newObj);
    await SyncAPICalls.logActivity(
        "orders", "insert order modifier", "order_modifier", orderid);
    return orderDetailData.app_id;
  }

  Future<int> sendAttrData(OrderAttributes orderDetailData) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var newObj = orderDetailData.toJson();
    newObj.remove("name");
    var orderid = await db.insert("order_attributes", newObj);
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

  Future<int> sendtoShiftInvoice(ShiftInvoice shiftInvoiceData) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var invoiceid = await db.insert("shift_invoice", shiftInvoiceData.toJson());
    await SyncAPICalls.logActivity(
        "orders", "insert shift invoice", "shift_invoice", invoiceid);
    return shiftInvoiceData.invoice_id;
  }

  Future<int> clearCartItem(cartid, tableID) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    await db.delete("mst_cart", where: 'id = ?', whereArgs: [cartid]);
    await SyncAPICalls.logActivity("orders", "clear cart", "mst_cart", 1);
    await db.delete("save_order", where: 'cart_id = ?', whereArgs: [cartid]);
    var qry = "Update table_order set save_order_id = 0 where table_id =" +
        tableID.toString();
    var res = await db.rawQuery(qry);
    var cartDetail = await db
        .query("mst_cart_detail", where: 'cart_id = ?', whereArgs: [cartid]);
    await SyncAPICalls.logActivity(
        "orders", "clear cart detail", "mst_cart_detail", cartid);
    List<MSTCartdetails> list = cartDetail.isNotEmpty
        ? cartDetail.map((c) => MSTCartdetails.fromJson(c)).toList()
        : [];
    if (list.length > 0) {
      for (var i = 0; i < list.length; i++) {
        var cartsubdatad = await db.delete("mst_cart_sub_detail",
            where: 'cart_details_id = ?', whereArgs: [list[i].id]);
      }
      await SyncAPICalls.logActivity(
          "orders", "clear cart detail", "mst_cart_sub_detail", cartid);
    }
    return cartid;
  }

  Future<int> removeCartItem(cartid, tableID) async {
    var db = DatabaseHelper.dbHelper.getDatabse();

    var cart = // cart table
        await db.delete("mst_cart", where: 'id = ?', whereArgs: [cartid]);

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

    // if (isLast) {
    //   await db.delete("mst_cart", where: 'id = ?', whereArgs: [cartID]);
    //   await SyncAPICalls.logActivity(
    //       "cart", "delete cart all item", "mst_Cart", cartItem.id);
    //   await db.delete("save_order", where: 'cart_id = ?', whereArgs: [cartID]);

    //   await SyncAPICalls.logActivity("cart",
    //       "delete cart all item from save_order", "save_order", cartItem.id);
    // } else {
    //Update cart
    await db.update("mst_cart", mainCart.toJson(),
        where: 'id = ?', whereArgs: [cartID]);
    // }
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

  // Future<List<ProductDetails>> getOrderDetails(orderid, terminalID) async {
  //   var db = DatabaseHelper.dbHelper.getDatabse();
  //   var qry = "SELECT P.product_id,P.name,P.price, base64" +
  //       " FROM order_detail O " +
  //       " LEFT JOIN product P ON O.product_id = P.product_id" +
  //       " LEFT JOIN asset on asset.asset_type_id = P.product_id " +
  //       " WHERE O.terminal_id = " +
  //       terminalID.toString() +
  //       "  AND O.order_app_id = " +
  //       orderid.toString();
  //   var ordersList = await db.rawQuery(qry);
  //   List<ProductDetails> list = ordersList.isNotEmpty
  //       ? ordersList.map((c) => ProductDetails.fromJson(c)).toList()
  //       : [];
  //   await SyncAPICalls.logActivity(
  //       "Transactions", "get Orders details list", "ProductDetails", orderid);
  //   return list;
  // }

  Future<List<OrderDetail>> getOrderDetailsList(orderid, terminalid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();

    var qry = "SELECT DISTINCT order_detail.*,asset.base64 from order_detail LEFT JOIN" +
        " asset on asset.base64 =(SELECT base64  from asset WHERE asset.asset_type_id = order_detail.product_id AND asset.status = 1 AND " +
        " asset.asset_type = CASE WHEN order_detail.issetMeal == 1 THEN  2 ELSE  1 END ORDER By asset.asset_id DESC LIMIT 1) " +
        " WHERE terminal_id =  " +
        terminalid.toString() +
        " AND order_app_id = " +
        orderid.toString() +
        " ORDER By order_detail.app_id ASC";
    var ordersList = await db.rawQuery(qry);
    List<OrderDetail> list = ordersList.isNotEmpty
        ? ordersList.map((c) => OrderDetail.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "invoice", "get Orders details list", "ProductDetails", orderid);

    // var qry1 = "SELECT * from order_detail WHERE terminal_id = " +
    //     terminalid.toString() +
    //     " AND order_app_id = " +
    //     orderid.toString();
    // var ordersList1 = await db.rawQuery(qry1);
    // List<OrderDetail> list1 = ordersList1.isNotEmpty
    //     ? ordersList1.map((c) => OrderDetail.fromJson(c)).toList()
    //     : [];
    // print(list1);
    return list;
  }

  Future<List<OrderPayment>> getOrderpaymentData(orderid, terminalid) async {
    OrderPayment data = new OrderPayment();
    var qry = "SELECT * from order_payment where terminal_id = " +
        terminalid.toString() +
        " AND order_app_id = " +
        orderid.toString();
    var ordersList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<OrderPayment> list = ordersList.length > 0
        ? ordersList.map((c) => OrderPayment.fromJson(c)).toList()
        : [];
    // if (list.length > 0) {
    //   data = list[0];
    // }
    return list;
  }

  Future<List<Voucher>> checkVoucherIsExit(code) async {
    var qry = "SELECT * from voucher where voucher_code = '" + code + "'";
//     var qry = "SELECT voucher.*,count(voucher_history.voucher_id) as total_used from voucher "+
// " LEFT JOIN voucher_history on voucher_history.voucher_id = voucher.voucher_id "+
// " where voucher_code = "+ code.toString();

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

  Future<dynamic> addVoucherIndetail(MSTCartdetails details, voucherId) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var newObj = details.toJson();
    newObj.remove("attrName");
    newObj.remove("modiName");
    var data = await db.update("mst_cart_detail", newObj,
        where: "id =?", whereArgs: [details.id]);
    await SyncAPICalls.logActivity(
        "voucher", "add voucher in cart", "voucher", voucherId);
    return data;
  }

  Future<dynamic> addVoucherInOrder(
      MST_Cart details, Voucher voucherDetail) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var data1 = await db.update("mst_cart", details.toJson(),
        where: "id =?", whereArgs: [details.id]);
    await SyncAPICalls.logActivity(
        "voucher", "add voucher in cart", "voucher", voucherDetail.voucherId);
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
    var db = DatabaseHelper.dbHelper.getDatabse();
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
    int count1 = Sqflite.firstIntValue(count);
    return count1;
  }

  Future<dynamic> saveVoucherHistory(VoucherHistory voucherHis) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var hitid = await db.insert("voucher_history", voucherHis.toJson());
    await SyncAPICalls.logActivity(
        "order", "add voucher history in cart", "voucher_history", hitid);
    return hitid;
  }

  Future<List<BranchTax>> getTaxList(branchid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from branch_tax WHERE branch_id = " +
        branchid.toString() +
        " AND status = 1";
    var tax = await db.rawQuery(qry);
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

  Future<List<Payments>> getOrderpaymentmethod(orderid, terminalid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from payment " +
        " LEFT JOIN order_payment on order_payment.op_method_id = payment.payment_id " +
        " WHERE order_payment.terminal_id = " +
        terminalid.toString() +
        " AND order_payment.order_app_id = " +
        orderid.toString();
    var paymentMeth = await db.rawQuery(qry);
    List<Payments> list = paymentMeth.isNotEmpty
        ? paymentMeth.map((c) => Payments.fromJson(c)).toList()
        : [];
    return list;
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
  Future<List<Orders>> getOrdersList(branchid, terminalid, int offset) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from orders  " +
        " where branch_id = " +
        branchid.toString() +
        " AND terminal_id = " +
        terminalid.toString() +
        " ORDER By orders.order_date DESC LIMIT 10 OFFSET  " +
        offset.toString();
    print(qry);
    var ordersList = await db.rawQuery(qry);
    List<Orders> list = ordersList.isNotEmpty
        ? ordersList.map((c) => Orders.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Transactions", "get Orders list", "Orders", branchid);
    return list;
  }

  Future<List<Orders>> getOrdersListTable(branchid, terminalId) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from orders where (branch_id = " +
        branchid.toString() +
        " AND order_source = 2 AND server_id = 0 AND terminal_id = " +
        terminalId.toString() +
        ") OR (branch_id = " +
        branchid.toString() +
        " AND order_source = 2 AND isSync = 0 AND terminal_id = " +
        terminalId.toString() +
        ")";
    var ordersList = await db.rawQuery(qry);
    List<Orders> list = ordersList.isNotEmpty
        ? ordersList.map((c) => Orders.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Order sync", "get Orders list", "Orders", branchid);
    return list;
  }

  Future<List<OrderDetail>> getOrderDetailTable(orderid, terminalId) async {
    var qry = "SELECT * from order_detail where isSync = 0 AND terminal_id = " +
        terminalId.toString() +
        " AND order_app_id = " +
        orderid.toString();
    var ordersList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<OrderDetail> list = ordersList.isNotEmpty
        ? ordersList.map((c) => OrderDetail.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Order sync", "get Orders detail list", "Orders", orderid);
    return list;
  }

  Future<List<OrderAttributes>> getOrderAttributesTable(
      detailid, terminalId) async {
    var qry =
        "SELECT * from order_attributes where isSync = 0 AND  terminal_id = " +
            terminalId.toString() +
            " AND detail_app_id = " +
            detailid.toString();

    var ordersList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<OrderAttributes> list = ordersList.isNotEmpty
        ? ordersList.map((c) => OrderAttributes.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Order sync", "get Orders_modifire list", "order_attribute", detailid);
    return list;
  }

  Future<List<OrderModifire>> getOrderModifireTable(
      detailid, terminalId) async {
    var qry =
        "SELECT * from order_modifier where isSync = 0 AND terminal_id = " +
            terminalId.toString() +
            " AND detail_app_id = " +
            detailid.toString();
    var ordersList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<OrderModifire> list = ordersList.isNotEmpty
        ? ordersList.map((c) => OrderModifire.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Order sync", "get Orders Modifire Table", "order_modifier", detailid);
    return list;
  }

  Future<List<OrderPayment>> getOrderPaymentTable(orderid, terminalid) async {
    var qry =
        "SELECT * from order_payment where isSync = 0 AND terminal_id = " +
            terminalid.toString() +
            " AND order_app_id = " +
            orderid.toString();
    var ordersList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<OrderPayment> list = ordersList.isNotEmpty
        ? ordersList.map((c) => OrderPayment.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Order sync", "get Orders payment Table", "order_payment", orderid);
    return list;
  }

  Future<List<VoucherHistory>> getVoucherHistoryTable(
      orderid, terminalid) async {
    var qry =
        "SELECT * from voucher_history where server_id = 0 AND terminal_id = " +
            terminalid.toString() +
            " AND app_order_id = " +
            orderid.toString();
    var ordersList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<VoucherHistory> list = ordersList.isNotEmpty
        ? ordersList.map((c) => VoucherHistory.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity("Order voucherHistory sync",
        "get Orders history Table", "voucher_history", orderid);
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
    await SyncAPICalls.logActivity("check Item Available in Store",
        "check Item Available in Store", "product_store_inventory", 1);
    return list;
  }

  Future<List<ProductStoreInventory>> removeFromInventory(
      OrderDetail produtdata) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var inventoryProd = await db.query("product",
        where: 'product_id = ?', whereArgs: [produtdata.product_id]);
    List<Product> list = inventoryProd.isNotEmpty
        ? inventoryProd.map((c) => Product.fromJson(c)).toList()
        : [];
    var intupdate = "Update product_store_inventory set qty = (qty - " +
        produtdata.detail_qty.toString() +
        ") WHERE product_id = " +
        produtdata.product_id.toString();
    var updateed = await db.rawUpdate(intupdate);
    var productitem = await db.query("product_store_inventory",
        where: 'product_id = ?', whereArgs: [produtdata.product_id]);
    List<ProductStoreInventory> inventory = productitem.length > 0
        ? productitem.map((c) => ProductStoreInventory.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity("Order", "update InventoryTable",
        "product_store_inventory", produtdata.product_id);
    return inventory;
  }

  Future<List<ProductStoreInventory>> getStoreInventoryData(productID) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var inventoryProd = await db.query("product_store_inventory",
        where: 'product_id = ?', whereArgs: [productID]);
    List<ProductStoreInventory> list = inventoryProd.length > 0
        ? inventoryProd.map((c) => ProductStoreInventory.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<int> updateInvetory(List<ProductStoreInventory> data) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    if (data.length > 0) {
      for (var i = 0; i < data.length; i++) {
        var inventory = await db.update(
            "product_store_inventory", data[i].toJson(),
            where: "inventory_id =?", whereArgs: [data[i].inventoryId]);
        await SyncAPICalls.logActivity("Order", "update InventoryTable",
            "product_store_inventory", data[i].productId);
      }
      return 1;
    }
  }

  Future<int> updateStoreInvetoryLogTable(
      List<ProductStoreInventoryLog> log) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    if (log.length > 0) {
      for (var i = 0; i < log.length; i++) {
        var inventory =
            await db.insert("product_store_inventory_log", log[i].toJson());
        await SyncAPICalls.logActivity("product_store_inventory_log insert",
            "insert", "product_store_inventory_log", log[i].inventory_id);
      }
    }
    return 1;
  }

  Future<Branch> getBranchData(branchID) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var result =
        await db.query("branch", where: 'branch_id = ?', whereArgs: [branchID]);
    List<Branch> list =
        result.isNotEmpty ? result.map((c) => Branch.fromJson(c)).toList() : [];

    await SyncAPICalls.logActivity(
        "branch details", "branch details for invoice", "branch", branchID);
    return list[0];
  }

  // 1 For New,2 For Ongoing,3 For cancelled,4 For Completed,5 For Refunded
  Future updateOrderStatus(Orders orderdata) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    await db.update("orders", orderdata.toJson(),
        where: "app_id =?", whereArgs: [orderdata.app_id]);
    await SyncAPICalls.logActivity("order staus change", "update order status",
        "order_status", orderdata.app_id);
  }

  Future<int> updatePaymentStatus(
      orderid, terminalid, status, upDate, userid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var result;
    var qry = "UPDATE order_payment SET op_status = " +
        status.toString() +
        " , isSync = 0 ,updated_at = '" +
        upDate.toString() +
        "' ,updated_by =" +
        userid.toString() +
        " where terminal_id = " +
        terminalid.toString() +
        " AND order_app_id = " +
        orderid.toString();
    result = db.rawUpdate(qry);
    await SyncAPICalls.logActivity("order payment status",
        "update payment status", "order_paymemt", orderid);
    if (result != null) {
      return 1;
    } else {
      return 0;
    }
  }

  Future<int> insertCancelOrder(CancelOrder order) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var result = db.insert('order_cancel', order.toJson());
    await SyncAPICalls.logActivity(
        "order cancel", "order cancel", "order_cancel", 1);
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
    var qry = "SELECT * from users where user_pin =" +
        userpin.toString() +
        " AND status = 1";
    var user = await db.rawQuery(qry);
    List<User> list =
        user.isNotEmpty ? user.map((c) => User.fromJson(c)).toList() : [];
    return list;
  }

  Future<int> deleteOrderItem(detailid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var result =
        db.rawDelete("DELETE FROM order_detail WHERE app_id = ?", [detailid]);
    await SyncAPICalls.logActivity(
        "delete order item", "delete order items", "order_detail", detailid);
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
    await SyncAPICalls.logActivity(
        "update web cart", "update web cart", "mst_cart", cart.id);
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
    var newObj = details.toJson();
    newObj.remove("attrName");
    newObj.remove("modiName");
    if (list.length > 0) {
      result = await db.update("mst_cart_detail", newObj,
          where: "id =?", whereArgs: [details.id]);
    } else {
      result = await db.insert("mst_cart_detail", newObj);
    }
    await SyncAPICalls.logActivity("update Web Cart details",
        "update Web Cart details", "mst_cart_detail", 1);
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
    await SyncAPICalls.logActivity("update Web Cart sub details",
        "update Web Cart sub details", "mst_cart_sub_detail", 1);
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
    await SyncAPICalls.logActivity(
        "update orders", "update orders", "orders", order.app_id);
    return result;
  }

  Future<List<ProductDetails>> productdData(productid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry =
        " SELECT product.*, price_type.name as price_type_Name , base64   from product " +
            " LEFT join price_type on price_type.pt_id = product.price_type_id AND price_type.status = 1 " +
            " LEFT join asset on asset.asset_type_id = product.product_id " +
            " where product_id = " +
            productid.toString();

    var res = await db.rawQuery(qry);
    List<ProductDetails> list = res.length > 0
        ? res.map((c) => ProductDetails.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<List<SetMeal>> setmealData(mealid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "select setmeal.* ,  base64  from setmeal " +
        " LEFT join setmeal_product on setmeal_product.setmeal_id = setmeal.setmeal_id " +
        " LEFT join asset on asset.asset_type = 2 AND asset.asset_type_id = setmeal.setmeal_id " +
        " WHERE setmeal.setmeal_id = " +
        mealid.toString() +
        " AND setmeal.status = 1 GROUP by setmeal.setmeal_id ";
    var mealList = await db.rawQuery(qry);
    List<SetMeal> list = mealList.isNotEmpty
        ? mealList.map((c) => SetMeal.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Meals List", "get Meals List", "setmeal", mealid);
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
    var checkisExitqry = "SELECT * FROM orders where terminal_id = " +
        orderData.terminal_id.toString() +
        " AND app_id =" +
        orderData.app_id.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);

    if (checkisExit.length > 0) {
      await db.update("orders", orderData.toJson(),
          where: "app_id =? AND terminal_id =?",
          whereArgs: [orderData.app_id, orderData.terminal_id]);
    } else {
      await db.insert("orders", orderData.toJson());
    }
    await SyncAPICalls.logActivity(
        "save Sync Order", "save Sync Order", "orders", orderData.app_id);
  }

  Future saveSyncOrderDetails(OrderDetail orderData) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry = "SELECT *  FROM order_detail where terminal_id = " +
        orderData.terminal_id.toString() +
        " AND app_id =" +
        orderData.app_id.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var newObj = orderData.toJson();
    newObj.remove("base64");
    if (checkisExit.length > 0) {
      await db.update("order_detail", newObj,
          where: "app_id =?  AND terminal_id =? ",
          whereArgs: [orderData.app_id, orderData.terminal_id]);
    } else {
      await db.insert("order_detail", newObj);
    }
    await SyncAPICalls.logActivity("save Sync OrderDetails",
        "save Sync OrderDetails", "orderdetails", orderData.app_id);
  }

  Future saveSyncOrderPaymet(OrderPayment paymentdata) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry = "SELECT *  FROM order_payment where terminal_id = " +
        paymentdata.terminal_id.toString() +
        " AND app_id =" +
        paymentdata.app_id.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);

    if (checkisExit.length > 0) {
      await db.update("order_payment", paymentdata.toJson(),
          where: "app_id =? AND terminal_id =?",
          whereArgs: [paymentdata.app_id, paymentdata.terminal_id]);
    } else {
      await db.insert("order_payment", paymentdata.toJson());
    }
    await SyncAPICalls.logActivity("save Sync order payment",
        "save Sync order payment", "order_payment", paymentdata.app_id);
  }

  Future saveSyncOrderModifire(OrderModifire orderData) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry = "SELECT *  FROM order_modifier where terminal_id = " +
        orderData.terminal_id.toString() +
        " AND app_id =" +
        orderData.app_id.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var newObj = orderData.toJson();
    newObj.remove("name");
    if (checkisExit.length > 0) {
      await db.update("order_modifier", newObj,
          where: "app_id =?  AND terminal_id =?",
          whereArgs: [orderData.app_id, orderData.terminal_id]);
    } else {
      await db.insert("order_modifier", newObj);
    }
    await SyncAPICalls.logActivity("save Sync order modifire",
        "save Sync order modifire", "order_modifier", orderData.app_id);
  }

  Future saveSyncOrderAttribute(OrderAttributes orderData) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry =
        "SELECT *  FROM order_attributes where terminal_id = " +
            orderData.terminal_id.toString() +
            " AND app_id =" +
            orderData.app_id.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var orderid;
    var newObj = orderData.toJson();
    newObj.remove("name");
    if (checkisExit.length > 0) {
      orderid = await db.update("order_attributes", newObj,
          where: "app_id =? AND  terminal_id =?",
          whereArgs: [orderData.app_id, orderData.terminal_id]);
    } else {
      orderid = await db.insert("order_attributes", newObj);
    }
    await SyncAPICalls.logActivity("save Sync order attributes",
        "save Sync order attributes", "order_attributes", orderData.app_id);
    return orderid;
  }

  Future<List<CancelOrder>> getCancleOrder(terminalid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from order_cancel where isSync = 0 AND terminal_id = " +
        terminalid.toString() +
        " AND server_id = 0";
    var ordersList = await db.rawQuery(qry);
    List<CancelOrder> list = ordersList.length > 0
        ? ordersList.map((c) => CancelOrder.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Order sync", "get Orders list", "Orders", terminalid);
    return list;
  }

  Future saveVoucherHistoryTable(VoucherHistory voucher) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry = "SELECT *  FROM voucher_history where terminal_id = " +
        voucher.terminal_id.toString() +
        " AND app_id =" +
        voucher.app_id.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    if (checkisExit.length > 0) {
      await db.update("voucher_history", voucher.toJson(),
          where: "app_id =? AND terminal_id =?",
          whereArgs: [voucher.app_id, voucher.terminal_id]);
    } else {
      await db.insert("voucher_history", voucher.toJson());
    }
    await SyncAPICalls.logActivity("save Sync voucher history",
        "save Sync voucher history", "voucher_history", voucher.app_id);
  }

  Future<List<PosPermission>> getUserPermissions(userid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = " SELECT  group_concat(pos_permission.pos_permission_name) as pos_permission_name  from users" +
        " Left join user_pos_permission on user_pos_permission.user_id = users.id  AND user_pos_permission.status = 1" +
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

  Future<List<ProductStoreInventory>> getProductStoreInventoryTable(
      branchid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from product_store_inventory where branch_id = " +
        branchid.toString();
    var ordersList = await db.rawQuery(qry);
    List<ProductStoreInventory> list = ordersList.length > 0
        ? ordersList.map((c) => ProductStoreInventory.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "sync inventory",
        "get product store inventory table",
        "product_store_inventory",
        branchid);
    return list;
  }

  Future<List<ProductStoreInventoryLog>> getProductStoreInventoryLogTable(
      inventoryid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry =
        "SELECT * from product_store_inventory_log where IFNULL(server_id,'') = '' AND inventory_id = " +
            inventoryid.toString();
    var inList = await db.rawQuery(qry);
    List<ProductStoreInventoryLog> list = inList.length > 0
        ? inList.map((c) => ProductStoreInventoryLog.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "sync inventory log",
        "get product store inventory log table",
        "product_store_inventory_log",
        inventoryid);
    return list;
  }

  Future<int> saveSyncInvStoreTable(
      ProductStoreInventory storeInventory) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry =
        "SELECT *  FROM product_store_inventory where inventory_id =" +
            storeInventory.inventoryId.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var inveID;
    if (checkisExit.length > 0) {
      inveID = await db.update(
          "product_store_inventory", storeInventory.toJson(),
          where: "inventory_id =?", whereArgs: [storeInventory.inventoryId]);
    } else {
      inveID =
          await db.insert("product_store_inventory", storeInventory.toJson());
    }
    return inveID;
  }

  Future<int> saveSyncInvStoreLogTable(ProductStoreInventoryLog logData) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry =
        "SELECT *  FROM product_store_inventory_log where il_id =" +
            logData.il_id.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var orderid;
    if (checkisExit.length > 0) {
      orderid = await db.update("product_store_inventory_log", logData.toJson(),
          where: "il_id =?", whereArgs: [logData.il_id]);
    } else {
      orderid =
          await db.insert("product_store_inventory_log", logData.toJson());
    }
    return orderid;
  }

  Future<int> saveSyncCancelTable(CancelOrder orderData) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry = "SELECT *  FROM order_cancel where order_app_id =" +
        orderData.order_app_id.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var inveID;
    if (checkisExit.length > 0) {
      inveID = await db.update("order_cancel", orderData.toJson(),
          where: "order_app_id =? AND terminal_id =?",
          whereArgs: [orderData.order_app_id, orderData.terminalId]);
    } else {
      inveID = await db.insert("order_cancel", orderData.toJson());
    }
    await SyncAPICalls.logActivity("save Sync order cancel",
        "save Sync order cancel", "order_cancel", orderData.order_app_id);
    return inveID;
  }

  Future<List<Orders>> getShiftInvoiceData(branchid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from orders where branch_id = " + branchid.toString();
    var ordersList = await db.rawQuery(qry);
    List<Orders> list = ordersList.isNotEmpty
        ? ordersList.map((c) => Orders.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Order sync", "get Orders list", "Orders", branchid);
    return list;
  }

  Future<List<SetMeal>> getMealsData(branchid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "select setmeal.* ,  base64  from setmeal " +
        " LEFT join setmeal_branch on setmeal_branch_id =" +
        branchid +
        " AND setmeal_branch.setmeal_id = setmeal.setmeal_id " +
        " LEFT join setmeal_product on setmeal_product.setmeal_id = setmeal.setmeal_id " +
        " LEFT join asset on asset.asset_type = 2 AND asset.asset_type_id = setmeal.setmeal_id where setmeal.status = 1  GROUP by setmeal.setmeal_id ";
    var mealList = await db.rawQuery(qry);
    List<SetMeal> list = mealList.isNotEmpty
        ? mealList.map((c) => SetMeal.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Meals List", "get Meals List", "setmeal", branchid);
    return list;
  }

  Future<List<SetMealProduct>> getMealsProductData(setmealid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT setmeal_product.*,replace(asset.base64,'data:image/jpg;base64,','') as base64,product.name  FROM setmeal_product " +
        " LEFT JOIN product ON product.product_id = setmeal_product.product_id AND product.status = 1 " +
        " LEFT join asset on asset.asset_type = 1 AND asset.asset_type_id = setmeal_product.product_id AND asset.status = 1 " +
        " WHERE setmeal_product.setmeal_id = " +
        setmealid.toString() +
        " AND setmeal_product.status = 1 " +
        " GROUP by setmeal_product.setmeal_product_id";
    // var qry = "SELECT setmeal_product.*,group_concat(attributes. name, ',') as attr_name," +
    //     " attributes.ca_id, group_concat(product_attribute.price) as attr_types_price," +
    //     " category_attribute.name as cateAtt,group_concat(attributes.attribute_id) as attributeId, base64,product.name FROM setmeal_product" +
    //     " LEFT JOIN product ON product.product_id = setmeal_product.product_id" +
    //     " LEFT JOIN product_attribute on product_attribute.product_id = setmeal_product.product_id and product_attribute.status = 1" +
    //     " LEFT JOIN category_attribute on category_attribute.ca_id = product_attribute.ca_id and category_attribute.status = 1" +
    //     " LEFT JOIN attributes on attributes.attribute_id = product_attribute.attribute_id and attributes.status = 1" +
    //     " LEFT JOIN asset on asset.asset_type = 1 AND asset.asset_type_id = setmeal_product.product_id" +
    //     " WHERE setmeal_product.setmeal_id = " +
    //     setmealid.toString() +
    //     " GROUP by setmeal_product.setmeal_product_id";

    var mealList = await db.rawQuery(qry);
    List<SetMealProduct> list = mealList.isNotEmpty
        ? mealList.map((c) => SetMealProduct.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Meals product List", "get Meals product List", "setmeal", setmealid);
    for (var i = 0; i < list.length; i++) {
      var attrQry = "SELECT product.product_id, category_attribute.name as attr_name,attributes.ca_id, " +
          " group_concat(product_attribute.price) as attr_types_price,group_concat(attributes.name) as attr_types ,group_concat(attributes.attribute_id) as attributeId " +
          " FROM product LEFT JOIN product_attribute on product_attribute.product_id = product.product_id and product_attribute.status = 1 " +
          " LEFT JOIN category_attribute on category_attribute.ca_id = product_attribute.ca_id and category_attribute.status = 1 " +
          " LEFT JOIN attributes on attributes.attribute_id = product_attribute.attribute_id and attributes.status = 1 " +
          " WHERE product.product_id =  " +
          list[i].productId.toString() +
          " GROUP by category_attribute.ca_id";
      List<Map> res = await db.rawQuery(attrQry);
      List<Attribute_Data> attrlist = res.length > 0
          ? res.map((c) => Attribute_Data.fromJson(c)).toList()
          : [];
      if (attrlist.length > 0) {
        list[i].attributeDetails = jsonEncode(attrlist);
      }
    }

    return list;
  }

  Future<List<Drawerdata>> getPayinOutammount(shiftid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from drawer where shift_id = " + shiftid.toString();
    var mealList = await db.rawQuery(qry);
    List<Drawerdata> list = mealList.isNotEmpty
        ? mealList.map((c) => Drawerdata.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "Meals product List", "Meals product List", "drawer", shiftid);
    return list;
  }

  Future<int> saveInOutDrawerData(Drawerdata drawerData) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var inveID = await db.insert("drawer", drawerData.toJson());
    await SyncAPICalls.logActivity(
        "save in out", "in out drawer data", "drawer", drawerData.shiftId);
    return inveID;
  }

  Future<List<SaveOrder>> gettableCartID(saveorderid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "select save_order.cart_id from table_order " +
        " LEFT join save_order on save_order.id = table_order.save_order_id " +
        " WHERE table_order.save_order_id = " +
        saveorderid.toString();
    var result = await db.rawQuery(qry);
    List<SaveOrder> list = result.length > 0
        ? result.map((c) => SaveOrder.fromJson(c)).toList()
        : [];
    print(list);
    if (list.length > 0 && list[0].cartId != null) {
      return list;
    } else {
      return [];
    }
  }

  Future changeTable(tableID, totableid, cartid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "UPDATE table_order SET table_id= " +
        totableid.toString() +
        " where table_id = " +
        tableID.toString();
    var result = await db.rawQuery(qry);
    print(result);
    if (cartid != null) {
      var qry1 = "UPDATE mst_cart SET table_id = " +
          totableid.toString() +
          " where  id = " +
          cartid.toString();
      var result1 = await db.rawQuery(qry1);
      print(result1);
    }
    await SyncAPICalls.logActivity(
        "table selection", "change table", "table_order", cartid);
  }

  Future makeAsFocProduct(MSTCartdetails focProduct, isUpdate, MST_Cart cart,
      MSTCartdetails cartitem) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var newObj = focProduct.toJson();
    newObj.remove("attrName");
    newObj.remove("modiName");
    if (isUpdate) {
      var data = await db.update("mst_cart_detail", newObj,
          where: "id =?", whereArgs: [focProduct.id]);
    } else {
      var data = await db.insert(
        "mst_cart_detail",
        newObj,
      );
    }
    var res = await db.update("mst_cart", cart.toJson(),
        where: "id =?", whereArgs: [cart.id]);
    await SyncAPICalls.logActivity(
        "mst_cart_detail", "Added Foc Product", "mst_cart_detail", cart.id);
  }

  Future deleteOrderid(orderid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var res =
        await db.delete("orders", where: "app_id =?", whereArgs: [orderid]);
    print(res);
    await SyncAPICalls.logActivity(
        "delete order", "delete order", "orders", orderid);
  }

  Future<List<Countrys>> getCountrysList() async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var contryList = await db.query("country");
    List<Countrys> list = contryList.isNotEmpty
        ? contryList.map((c) => Countrys.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<States>> getStatesList() async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var stateList = await db.query("state");
    List<States> list = stateList.isNotEmpty
        ? stateList.map((c) => States.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<Citys>> getCitysList() async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var cityList = await db.query("city");
    List<Citys> list = cityList.isNotEmpty
        ? cityList.map((c) => Citys.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<Customer>> getCustomersforSend(teminalID) async {
    var query =
        "SELECT * from customer WHERE IFNULL(server_id,'')='' AND terminal_id = " +
            teminalID.toString();
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<Customer> list =
        res.isNotEmpty ? res.map((c) => Customer.fromJson(c)).toList() : [];
    await SyncAPICalls.logActivity(
        "Customer", "geting customer list for sync", "customer", teminalID);
    return list;
  }

  Future<int> getLastCustomerid(terminalid) async {
    var qry = "SELECT customer.app_id from customer where terminal_id =" +
        terminalid +
        "  ORDER BY app_id DESC LIMIT 1";
    var checkisExit = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<Customer> list = checkisExit.length > 0
        ? checkisExit.map((c) => Customer.fromJson(c)).toList()
        : [];
    if (list.length > 0) {
      return list[0].appId;
    } else {
      return 0;
    }
  }

  Future<List<Rac>> getRacList(branchID) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from rac where branch_id = " +
        branchID.toString() +
        " AND status = 1";
    var result = await db.rawQuery(qry);
    List<Rac> list =
        result.length > 0 ? result.map((c) => Rac.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<Box>> getBoxList(branchID, racID, customerid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    // var qry = "SELECT * from box where branch_id = " +
    //     branchID.toString() +
    //     " AND rac_id = " +
    //     racID.toString() +
    //     "  AND status = 1";
    var qry = "SELECT * from box LEFT JOIN customer_liquor_inventory on" +
        " customer_liquor_inventory.cl_box_id = box.box_id" +
        " where box.branch_id = " +
        branchID.toString() +
        " AND box.rac_id = " +
        racID.toString() +
        " AND box.status = 1 " +
        " AND customer_liquor_inventory.cl_customer_id = " +
        customerid.toString();
    var result = await db.rawQuery(qry);
    List<Box> list =
        result.length > 0 ? result.map((c) => Box.fromJson(c)).toList() : [];
    return list;
  }

  Future<int> getLastCustomerInventory() async {
    var qey = "SELECT app_id from customer_liquor_inventory " +
        " ORDER BY app_id DESC LIMIT 1";
    var checkisExit = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qey);
    List<Customer_Liquor_Inventory> list = checkisExit.length > 0
        ? checkisExit.map((c) => Customer_Liquor_Inventory.fromJson(c)).toList()
        : [];
    if (list.length > 0) {
      return list[0].appId;
    } else {
      return 0;
    }
  }

  Future<int> getLastCustomerInventoryLog() async {
    var qey = "SELECT app_id from customer_liquor_inventory_log " +
        " ORDER BY app_id DESC LIMIT 1";
    var checkisExit = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qey);
    List<Customer_Liquor_Inventory_Log> list = checkisExit.length > 0
        ? checkisExit
            .map((c) => Customer_Liquor_Inventory_Log.fromJson(c))
            .toList()
        : [];
    if (list.length > 0) {
      return list[0].appId;
    } else {
      return 0;
    }
  }

  Future<int> insertWineInventory(
      Customer_Liquor_Inventory data, isUpdate) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var invData = data.toJson();
    await invData.remove("name");
    var result;
    if (isUpdate) {
      result = await db.update("customer_liquor_inventory", invData,
          where: "app_id =?", whereArgs: [data.appId]);
    } else {
      result = await db.insert("customer_liquor_inventory", invData);
    }
    await SyncAPICalls.logActivity("customer liquor inventory",
        "insert Wine inventory", "customer_liquor_inventory", data.clBranchId);
    return result;
  }

  Future<int> insertWineInventoryLog(Customer_Liquor_Inventory_Log data) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var result =
        await db.insert("customer_liquor_inventory_log", data.toJson());
    await SyncAPICalls.logActivity(
        "customer liquor inventory log",
        "insert Wine inventory log",
        "customer_liquor_inventory_log",
        data.branchId);
    return result;
  }

  Future<List<Customer_Liquor_Inventory>> getCustomerRedeem(customerid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry =
        "SELECT customer_liquor_inventory.*,box.name from customer_liquor_inventory" +
            " LEFT JOIN box on box.box_id = customer_liquor_inventory.cl_box_id " +
            " WHERE cl_customer_id = " +
            customerid.toString();
    var result = await db.rawQuery(qry);
    List<Customer_Liquor_Inventory> list = result.length > 0
        ? result.map((c) => Customer_Liquor_Inventory.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<Customer_Liquor_Inventory>> getCustomersWineInventory(
      branchID) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var query =
        "SELECT * from customer_liquor_inventory WHERE IFNULL(server_id,'')='' AND cl_branch_id = " +
            branchID.toString();
    var res = await db.rawQuery(query);
    List<Customer_Liquor_Inventory> list = res.isNotEmpty
        ? res.map((c) => Customer_Liquor_Inventory.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "customer_liquor_inventory",
        "geting customer Wine inventory list for sync",
        "customer_liquor_inventory",
        branchID);
    return list;
  }

  Future<List<Customer_Liquor_Inventory_Log>> getCustomersWineInventoryLogs(
      branchID, appid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var query =
        "SELECT * from customer_liquor_inventory_log WHERE IFNULL(server_id,'')='' AND cl_appId = " +
            appid.toString();
    var res = await db.rawQuery(query);
    List<Customer_Liquor_Inventory_Log> list = res.isNotEmpty
        ? res.map((c) => Customer_Liquor_Inventory_Log.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "customer_liquor_inventory",
        "geting customer Wine inventory Log list for sync",
        "customer_liquor_inventory",
        branchID);
    return list;
  }

  Future<int> saveSuctomerWineInventory(
      Customer_Liquor_Inventory customerInv) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry =
        "SELECT *  FROM customer_liquor_inventory where app_id =" +
            customerInv.appId.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var result;
    if (checkisExit.length > 0) {
      result = await db.update(
          "customer_liquor_inventory", customerInv.toJson(),
          where: "app_id =?", whereArgs: [customerInv.appId]);
    } else {
      result =
          await db.insert("customer_liquor_inventory", customerInv.toJson());
    }
    return result;
  }

  Future<int> saveSuctomerWineInventoryLogs(
      Customer_Liquor_Inventory_Log customerInv) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry =
        "SELECT *  FROM customer_liquor_inventory_log where app_id =" +
            customerInv.appId.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var result;
    if (checkisExit.length > 0) {
      result = await db.update(
          "customer_liquor_inventory_log", customerInv.toJson(),
          where: "app_id =?", whereArgs: [customerInv.appId]);
    } else {
      result = await db.insert(
          "customer_liquor_inventory_log", customerInv.toJson());
    }
    return result;
  }

  Future<List<Box>> getBoxForProduct(productId) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from box where product_id = " +
        productId.toString() +
        " AND status = 1";
    var result = await db.rawQuery(qry);
    List<Box> list =
        result.length > 0 ? result.map((c) => Box.fromJson(c)).toList() : [];
    return list;
  }

  Future<dynamic> getTotalPayment(terminalid, branchid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from order_payment WHERE terminal_id = " +
        terminalid +
        " AND branch_id =" +
        branchid +
        " GROUP by op_method_id";
    var result = await db.rawQuery(qry);
    List<OrderPayment> list = result.length > 0
        ? result.map((c) => OrderPayment.fromJson(c)).toList()
        : [];
    List<Payments> paymentMethods = [];
    if (list.length > 0) {
      for (var i = 0; i < list.length; i++) {
        OrderPayment opayment = list[i];
        var qry = "SELECT * FROM payment WHERE payment_id = " +
            opayment.op_method_id.toString();
        var result = await db.rawQuery(qry);
        List<Payments> plist = result.length > 0
            ? result.map((c) => Payments.fromJson(c)).toList()
            : [];
        paymentMethods.add(plist[0]);
      }
    }
    var data = {"payment_method": paymentMethods, "payments": list};
    return data;
  }

  Future<int> getLastShiftAppID(terminalid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT shift.app_id from shift where terminal_id =" +
        terminalid +
        "  ORDER BY app_id DESC LIMIT 1";
    var checkisExit = await db.rawQuery(qry);
    List<Shift> list = checkisExit.length > 0
        ? checkisExit.map((c) => Shift.fromJson(c)).toList()
        : [];
    if (list.length > 0) {
      return list[0].appId;
    } else {
      return 0;
    }
  }

  Future<int> getLastShiftInvoiceAppID(terminalid) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry =
        "SELECT shift_invoice.app_id from shift_invoice where terminal_id =" +
            terminalid +
            "  ORDER BY app_id DESC LIMIT 1";
    var checkisExit = await db.rawQuery(qry);
    List<ShiftInvoice> list = checkisExit.length > 0
        ? checkisExit.map((c) => ShiftInvoice.fromJson(c)).toList()
        : [];
    if (list.length > 0) {
      return list[0].app_id;
    } else {
      return 0;
    }
  }

  Future<List<Shift>> getShiftDatabaseTable(branchid, termianlId) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from shift WHERE branch_id = " +
        branchid.toString() +
        " AND terminal_id = " +
        termianlId.toString() +
        " AND server_id = 0";
    var shiftList = await db.rawQuery(qry);
    List<Shift> list = shiftList.length > 0
        ? shiftList.map((c) => Shift.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "shift", "get shift table for sync", "shift", branchid);
    return list;
  }

  Future<List<ShiftInvoice>> getShiftInvoiceTable(termianlId) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry =
        "SELECT * from shift_invoice WHERE server_id = 0 AND terminal_id = " +
            termianlId.toString();
    var inList = await db.rawQuery(qry);
    List<ShiftInvoice> list = inList.length > 0
        ? inList.map((c) => ShiftInvoice.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "sync inventory log",
        "get product store inventory log table",
        "product_store_inventory_log",
        termianlId);
    return list;
  }

  Future<int> saveShiftDatafromSync(Shift shift) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry =
        "SELECT *  FROM shift where app_id =" + shift.appId.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var result;
    if (checkisExit.length > 0) {
      result = await db.update("shift", shift.toJson(),
          where: "app_id =?", whereArgs: [shift.appId]);
    } else {
      result = await db.insert("shift", shift.toJson());
    }
    await SyncAPICalls.logActivity(
        "sync shift data", "Save shift data from server", "shift", shift.appId);
    return result;
  }

  Future<int> saveShiftInvoiceDatafromSync(ShiftInvoice shiftInv) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry = "SELECT *  FROM shift_invoice where app_id =" +
        shiftInv.app_id.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var result;
    if (checkisExit.length > 0) {
      result = await db.update("shift_invoice", shiftInv.toJson(),
          where: "app_id =?", whereArgs: [shiftInv.app_id]);
    } else {
      result = await db.insert("shift_invoice", shiftInv.toJson());
    }
    await SyncAPICalls.logActivity("sync shift details",
        "Save shift details from server", "shift_details", shiftInv.app_id);
    return result;
  }

  Future<int> getLastVoucherHistoryid(terminalid) async {
    var qry = "SELECT app_id from voucher_history where terminal_id =" +
        terminalid +
        " ORDER BY app_id DESC LIMIT 1";
    var checkisExit = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<VoucherHistory> list = checkisExit.length > 0
        ? checkisExit.map((c) => VoucherHistory.fromJson(c)).toList()
        : [];
    if (list.length > 0) {
      return list[0].app_id;
    } else {
      return 0;
    }
  }

  Future<List<TerminalLog>> getTerminalLogTables(branchid, termianlId) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var qry = "SELECT * from terminal_log  WHERE branch_id = " +
        branchid.toString() +
        " AND terminal_id = " +
        termianlId.toString() +
        " AND isSync = 0";
    var shiftList = await db.rawQuery(qry);
    List<TerminalLog> list = shiftList.length > 0
        ? shiftList.map((c) => TerminalLog.fromJson(c)).toList()
        : [];

    await SyncAPICalls.logActivity("terminal log",
        "terminal log table for sync", "terminal_log", branchid);
    return list;
  }

  Future<int> saveTerminalLogFromSync(TerminalLog log) async {
    var db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry =
        "SELECT *  FROM terminal_log where id =" + log.id.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var result;
    if (checkisExit.length > 0) {
      result = await db.update("terminal_log", log.toJson(),
          where: "id =?", whereArgs: [log.id]);
    } else {
      result = await db.insert("terminal_log", log.toJson());
    }
    await SyncAPICalls.logActivity("sync terminal log",
        "Save terminal log from server", "terminal_log", log.id);
    return result;
  }
}
