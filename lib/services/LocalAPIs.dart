import 'dart:convert';

import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Asset.dart';
import 'package:mcncashier/models/Attribute_data.dart';
import 'package:mcncashier/models/Attributes.dart';
import 'package:mcncashier/models/Category.dart';
import 'package:mcncashier/models/Category_Attributes.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/Modifier.dart';
import 'package:mcncashier/models/ModifireData.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/Product.dart';
import 'package:mcncashier/models/Product_Attribute.dart';
import 'package:mcncashier/models/Product_Categroy.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/models/Table.dart';
import 'package:mcncashier/models/Table_order.dart';

class LocalAPI {
  Future<List<Category>> getAllCategory() async {
    var branchID = await Preferences.getStringValuesSF(Constant.BRANCH_ID);
    var query =
        "select * from category left join category_branch on category_branch.category_id = category.category_id where category_branch.branch_id =" +
            branchID.toString();
    List<Map> res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<Category> list =
        res.isNotEmpty ? res.map((c) => Category.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<ProductDetails>> getProduct(String id, String branchID) async {
    var query = "SELECT product.*,group_concat(replace(asset.base64,'data:image/jpg;base64,','') , ' groupconcate_Image ') as base64  FROM `product` " +
        " LEFT join product_category on product_category.product_id = product.product_id " +
        " Left join  product_branch on product_branch.product_id = product.product_id " +
        " LEFT join asset on asset.asset_type = 1 AND asset.asset_type_id = product.product_id " +
        " where product_category.category_id = " +
        id +
        " AND product_branch.branch_id = " +
        branchID +
        " GROUP By product.product_id";
    List<Map> res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<ProductDetails> list = res.isNotEmpty
        ? res.map((c) => ProductDetails.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<Customer>> getCustomers() async {
    var res = await DatabaseHelper.dbHelper.getDatabse().query("customer");
    List<Customer> list =
        res.isNotEmpty ? res.map((c) => Customer.fromJson(c)).toList() : [];
    return list;
  }

  Future<int> addCustomer(Customer customer) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var result = await db.insert("customer", customer.toJson());
    return result;
  }

  Future<List<Tables>> getTables() async {
    var res = await DatabaseHelper.dbHelper.getDatabse().query("tables");
    List<Tables> list =
        res.isNotEmpty ? res.map((c) => Tables.fromJson(c)).toList() : [];
    return list;
  }

  Future<int> insertTableOrder(Table_order table_order) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var result = await db.insert("table_order", table_order.toJson());
    return result;
  }

  Future<int> insertShift(Shift shift) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var result = await db.insert("shift", shift.toJson());
    return result;
  }

  Future<List<Attribute_Data>> getProductDetails(ProductDetails product) async {
    var qry = " SELECT product.product_id, product_store_inventory.qty,category_attribute.name as attr_name,attributes.ca_id, " +
        " group_concat(product_attribute.price) as attr_types_price,group_concat(attributes.name) as attr_types ,group_concat(attributes.attribute_id)" +
        " FROM product LEFT join product_store_inventory  ON  product_store_inventory.product_id = product.product_id and product_store_inventory.status = 1" +
        " LEFT JOIN product_attribute on product_attribute.product_id = product.product_id and product_attribute.status = 1" +
        " LEFT JOIN category_attribute on category_attribute.ca_id = product_attribute.ca_id and category_attribute.status = 1" +
        " LEFT JOIN attributes on attributes.attribute_id = product_attribute.attribute_id and attributes.status = 1 " +
        " WHERE product.product_id = 3 and product_store_inventory.branch_id  = 1 GROUP by category_attribute.ca_id";
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
            " GROUP by product_modifier.pm_id";
    List<Map> res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<ModifireData> list =
        res.isNotEmpty ? res.map((c) => ModifireData.fromJson(c)).toList() : [];

    return list;
  }

  Future<int> insertItemTocart(MST_Cart cartData) async {
    var db = await DatabaseHelper.dbHelper.getDatabse();
    var result = await db.insert("mst_cart", cartData.toJson());
    return result;
  }

  Future<List<MST_Cart>> getCartItem() async {
    var res = await DatabaseHelper.dbHelper.getDatabse().query("mst_cart");
    List<MST_Cart> list =
        res.isNotEmpty ? res.map((c) => MST_Cart.fromJson(c)).toList() : [];
    return list;
  }
}
