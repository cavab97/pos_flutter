import 'package:mcncashier/helpers/sqlDatahelper.dart';

class LocalAPI {
  @override
  DatabaseHelper databaseHelper;

  Future<List> getCategory() async {
    final db = await databaseHelper.database;
    List<Map> list = await db.rawQuery('SELECT * FROM category');
    return list;
  }

  static getProduct() async {
    
  }
}
