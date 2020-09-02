import 'package:sqflite/sqflite.dart';

class TableData {
  Future<dynamic> getRoleData(Database db) async {
    List<Map> list = await db.rawQuery('SELECT * FROM role');
    return list;
  }
}
