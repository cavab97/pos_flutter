import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Customer.dart';

class LocalAPI {
  @override
  DatabaseHelper databaseHelper;

  Future<List> getCategory() async {
    final db = await databaseHelper.database;
    List<Map> list = await db.rawQuery('SELECT * FROM category');
    return list;
  }

  static getProduct() async {}

  static addCustomer(Customer customer) async {
    //var result = await db.insert("category", category.toJson());
  }
}
