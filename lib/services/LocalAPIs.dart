import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Category.dart';
import 'package:mcncashier/models/Product.dart';

class LocalAPI {
 /* Future<List<Category>> getCategory() async {
    final db = await DatabaseHelper.dbHelper.getDatabse(); //databaseHelper.database;
    List<Category> list = await db.rawQuery('SELECT * FROM category');
    return list;
  }*/

  Future<List<Category>> getAllCategory() async {
    var res = await DatabaseHelper.dbHelper.getDatabse().query("category");
    List<Category> list = res.isNotEmpty ? res.map((c) => Category.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<Product>>  getProduct() async {
    var res = await DatabaseHelper.dbHelper.getDatabse().query("product");
    List<Product> list = res.isNotEmpty ? res.map((c) => Product.fromJson(c)).toList() : [];
    return list;
  }
}
