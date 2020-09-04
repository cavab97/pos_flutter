import 'package:mcncashier/helpers/GetTableData.dart';
import 'package:mcncashier/helpers/Tables.dart';
import 'package:mcncashier/models/todo.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String todoTable = 'todo_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colDate = 'date';
  String databaseName = "MCN_POS.db";
  DatabaseHelper._createInstance();
  CreateTables createTablehelper = CreateTables();
  TableData tableDataHelper = TableData();
  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }
  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + "/" + databaseName;
    print(path);
    // if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
    _database = await openDatabase(path, version: 1, onCreate: _createDb);
    // } else {
    //   _database = await openDatabase(path, version: 1, onCreate: _onOpen;
    //   print("already exit\(path)" + path);
    // }
    getlocalData();
    return _database;
  }

  void _createDb(Database db, int newVersion) async {
    var data = await createTablehelper.createTable(db);
    print(data);
  }

  Future<int> getlocalData() async {
    Database db = await this.database;
    var result = await tableDataHelper.getRoleData(db);
    return result;
  }

  // Future<int> updateTodo(Todo todo) async {
  //   var db = await this.database;
  //   var result = await db.update(todoTable, todo.toMap(),
  //       where: '$colId = ?', whereArgs: [todo.id]);
  //   return result;
  // }
}
