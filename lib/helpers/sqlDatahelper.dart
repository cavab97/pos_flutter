import 'package:mcncashier/helpers/GetTableData.dart';
import 'package:mcncashier/helpers/Tables.dart';
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

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper dbHelper = DatabaseHelper._privateConstructor();

  Database getDatabse() {
    return _database;
  }

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
    _database = await openDatabase(path, version: 1, onCreate: _createDb);
    return _database;
  }

  void _createDb(Database db, int newVersion) async {
    await createTablehelper.createTable(db);
  }

  Future<dynamic> insertData1(tablesData) async {
    Database db = await this.database;
    var result = await tableDataHelper.insertDatatable1(db, tablesData);
    return result;
  }

  Future<dynamic> insertData2_1(tablesData) async {
    Database db = await this.database;
    var result = await tableDataHelper.insertDatatable2_1(db, tablesData);
    return result;
  }

  Future<dynamic> insertData2_2(tablesData) async {
    Database db = await this.database;
    var result = await tableDataHelper.insertDatatable2_2(db, tablesData);
    return result;
  }

  Future<dynamic> insertData2_3(tablesData) async {
    Database db = await this.database;
    var result = await tableDataHelper.insertDatatable2_3(db, tablesData);
    return result;
  }

  Future<dynamic> insertData3(tablesData) async {
    Database db = await this.database;
    var result = await tableDataHelper.insertDatatable3(db, tablesData);
    return result;
  }

  Future<dynamic> insertData4_1(tablesData) async {
    Database db = await this.database;
    var result = await tableDataHelper.insertDatatable4_1(db, tablesData);
    return result;
  }

  Future<dynamic> insertData4_2(tablesData) async {
    Database db = await this.database;
    var result = await tableDataHelper.insertDatatable4_2(db, tablesData);
    return result;
  }

  Future<dynamic> insertAddressData(tablesData) async {
    Database db = await this.database;
    var result = await tableDataHelper.insertAdressData(db, tablesData);
    return result;
  }

  Future<dynamic> insertWineStoragedata(tablesData) async {
    Database db = await this.database;
    //print('insertWineStoragedata sqlDatahelper');
    var result = await tableDataHelper.insertWineStorageData(db, tablesData);
    return result;
  }

  Future<dynamic> accetsData(tablesData) async {
    Database db = await this.database;
    var result = await tableDataHelper.insertProductImage(db, tablesData);
    return result;
  }
}
