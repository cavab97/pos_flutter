import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Asset.dart';
import 'package:mcncashier/models/Category.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/Product.dart';
import 'package:mcncashier/models/Product_Categroy.dart';
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
    return list;
  }

  Future<List<Product>> getProduct(String id) async {
    // var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery('select * from product left join product_category using(id) where category_id="'+id+'"');
    // var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery('SELECT * FROM `product` LEFT join product_category on product_category.product_id = product.product_id where product_category.category_id = '+id);
    var res = await DatabaseHelper.dbHelper.getDatabse().query("product");
    List<Product> list =
        res.isNotEmpty ? res.map((c) => Product.fromJson(c)).toList() : [];

    list.forEach((element) async {
      var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(
          'SELECT base64 FROM asset WHERE asset_type = 1 AND asset_type_id =' +
              element.productId.toString());

      if (res.isNotEmpty) {
        print("IFFFFFFFFFFFFFFFFFFF");
        element.base64 = res.toString();
      }else{
        print("=======================");
        print(element.productId.toString());
        print("Elsssssssssssssssssssss");
      }
    });
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
}
