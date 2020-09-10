import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Asset.dart';
import 'package:mcncashier/models/Attributes.dart';
import 'package:mcncashier/models/Category.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/Product.dart';
import 'package:mcncashier/models/Product_Attribute.dart';
import 'package:mcncashier/models/Product_Categroy.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/models/Table.dart';
import 'package:mcncashier/models/Table_order.dart';

class LocalAPI {
  /* Future<List<Category>> getCategory() async {
    final db = await DatabaseHelper.dbHelper.getDatabse(); //databaseHelper.database;
    List<Category> list = await db.rawQuery('SELECT * FROM category');
    return list;
  }*/

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

  Future<List<Assets>> assets() async {
    var res = await DatabaseHelper.dbHelper.getDatabse().query("asset");
    List<Assets> list =
        res.isNotEmpty ? res.map((c) => Assets.fromJson(c)).toList() : [];

    print("99999999999999999999999999999");
    print(list.length);
    print("99999999999999999999999");
    return list;
  }

  Future<List<Product>> getProduct(String id) async {
    var query =
        'SELECT * FROM `product` LEFT join product_category on product_category.product_id = product.product_id where product_category.category_id = ' +
            id;
    List<Map> res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<Product> list =
        res.isNotEmpty ? res.map((c) => Product.fromJson(c)).toList() : [];
    for (var i = 0; i < list.length; i++) {
      Product product = list[i];
      var query1 =
          'SELECT base64 FROM asset WHERE asset_type = 1 AND asset_type_id =' +
              product.productId.toString();
      print(query1);
      var base64 = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query1);
      List<Assets> base1 =
          res.isNotEmpty ? base64.map((c) => Assets.fromJson(c)).toList() : [];
      if (base1.length != 0) {
        print(base1[0].base64);
        list[i].base64 = base1[0].base64.split("data:image/jpg;base64,")[1];
      }
    }
    return list;
  }

  Future<List<Assets>> catp() async {
    var cat = await DatabaseHelper.dbHelper.getDatabse().query("asset");
    List<Assets> catlist =
        cat.isNotEmpty ? cat.map((c) => Assets.fromJson(c)).toList() : [];
    return catlist;
  }

  getProductImage(String id) async {
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(
        'SELECT base64 FROM asset WHERE asset_type = 1 AND asset_type_id =' +
            id);

    if (res.isNotEmpty) {
      print("IFFFFFFFFFFFFFFFFFFF");
      return res.toString();
    } else {
      print("=======================");
      print("Elsssssssssssssssssssss");
      return "";
    }
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

  Future<List<ProductAttribute>> getPorductAttributes(Product product) async {
    var query =
        "SELECT * FROM `product_attribute` LEFT join category_attribute on category_attribute.ca_id = product_attribute.ca_id where product_attribute.product_id = " +
            product.productId.toString() +
            " AND product_attribute.status = 1 GROUP BY product_attribute.ca_id";
    print(query);
    var res = await DatabaseHelper.dbHelper.getDatabse().query(query);
    print(res);
    List<ProductAttribute> list = res.isNotEmpty
        ? res.map((c) => ProductAttribute.fromJson(c)).toList()
        : [];
    for (var i = 0; i < list.length; i++) {
      ProductAttribute attr = list[i];
      var qry1 =
          'SELECT * FROM `product_attribute` LEFT join attributes on attributes.attribute_id = product_attribute.attribute_id where product_attribute.product_id = ' +
              attr.productId.toString() +
              ' AND product_attribute.ca_id = 2 AND product_attribute.status = 1';
      print(qry1);
      var response = await DatabaseHelper.dbHelper.getDatabse().query(qry1);
      List<Attributes> attr_list = res.isNotEmpty
          ? response.map((c) => Attributes.fromJson(c)).toList()
          : [];
      print(attr_list);
    }

    return list;
  }
}
