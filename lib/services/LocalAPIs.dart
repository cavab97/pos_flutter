import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Asset.dart';
import 'package:mcncashier/models/Category.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/Product.dart';
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
    var res = await DatabaseHelper.dbHelper.getDatabse().query("category");
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

  String t =
      "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";

  Future<List<Product>> getProduct(String id) async {
    //assets();
    // var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery('select * from product left join product_category using(id) where category_id="'+id+'"');
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(
        'SELECT * FROM `product` LEFT join product_category on product_category.product_id = product.product_id where product_category.category_id = ' +
            id);
    // var res = await DatabaseHelper.dbHelper.getDatabse().query("product");
    List<Product> list =
        res.isNotEmpty ? res.map((c) => Product.fromJson(c)).toList() : [];

    /* list.forEach((element) async {
      var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(
          'SELECT base64 FROM asset WHERE asset_type = 1 AND asset_type_id =' +
              element.productId.toString());
      print(res.length);

      if (res.isNotEmpty) {
        print("IFFFFFFFFFFFFFFFFFFF");
        element.base64 = t;
      }else{
        print("=======================");
        print(element.productId.toString());
        print("Elsssssssssssssssssssss");
      }
    });*/
    return list;
  }

  Future<List<ProductCategory>> catp() async {
    var cat =
        await DatabaseHelper.dbHelper.getDatabse().query("product_category");
    List<ProductCategory> catlist = cat.isNotEmpty
        ? cat.map((c) => ProductCategory.fromJson(c)).toList()
        : [];
    return catlist;
  }

  Future<String> getProductImage(String id) async {
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(
        'SELECT base64 FROM asset WHERE asset_type = 1 AND asset_type_id =' +
            id);
    return res.toString();
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
}
