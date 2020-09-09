import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Category.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/Product.dart';
import 'package:mcncashier/models/Product_Categroy.dart';

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

  Future<List<Product>> getProduct(String id) async {
   // var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery('select * from product left join product_category using(id) where category_id="'+id+'"');
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery('SELECT * FROM `product` LEFT join product_category on product_category.product_id = product.product_id where product_category.category_id = '+id);
  //  var res = await DatabaseHelper.dbHelper.getDatabse().query("product");
    List<Product> list =res.isNotEmpty ? res.map((c) => Product.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<ProductCategory>> catp() async {
    var cat = await DatabaseHelper.dbHelper.getDatabse().query("product_category");
    List<ProductCategory> catlist =
    cat.isNotEmpty ? cat.map((c) => ProductCategory.fromJson(c)).toList() : [];
    return catlist;
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
}
