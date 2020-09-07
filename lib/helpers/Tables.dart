import 'package:sqflite/sqflite.dart';

class CreateTables {
  Future<dynamic> createTable(Database db) {
    // Role Table
    var datatables;
    datatables = db.execute(
        "CREATE TABLE role (role_id	 INTEGER ,role_name TEXT,uuid TEXT ,role_status INTEGER," +
            "role_updated_at	TEXT,role_updated_by INTEGER);");
    db.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO role(role_id, role_name, uuid,role_status,role_updated_at,role_updated_by)' +
              'VALUES(1, "test","tetstsfsdf" ,0,"20-12-2020 11:44:32",1)');
      print('inserted1: $id1');
      int id2 = await txn.rawInsert(
          'INSERT INTO role(role_id, role_name, uuid,role_status,role_updated_at,role_updated_by)' +
              'VALUES(2, "test", "dfsdfsdfsdf",1,"20-12-2020 11:44:32",2)');
      print('inserted2: $id2');
    });

    // // module table
    datatables = db.execute(
        "CREATE TABLE module (module_id	INTEGER,module_name TEXTL,module_updated_at	TEXT," +
            "module_updated_by INTEGER);");

    // Table role_permission table
    datatables = db.execute(
        "CREATE TABLE role_permission (rp_id INTEGER,	rp_uuid TEXT,rp_role_id	INTEGER ," +
            "rp_module_id INTEGER,rp_updated_at TEXT,rp_updated_by INTEGER);");

    // user  tabl

    datatables = db.execute(
        "CREATE TABLE user (id INTEGER,terminal_id INTEGER,app_id INTEGER," +
            "uuid Text,name TEXT,role INTEGER,username TEXT,password TEXT,country_code TEXT ,mobile TEXT," +
            "profile TEXT,commision_percent REAL ,pin TEXT ,status INTEGER,device_id TEXT ,device_token TEXT" +
            "auth_key TEXT, last_login TEXT,remember_token TEXT" +
            ")");

    //customer_address TABLE
    //TODO : table create address

    datatables = db.execute(" CREATE TABLE customer_address (" +
        "address_id INTEGER,terminal_id INTEGER,app_id INTEGER,uuid TEXT" +
        "user_id INTEGER,address_line1 TEXT,address_line2 TEXT ,latitude TEXT,logitude TEXT ," +
        "is_default INTEGER,status INTEGER,updated_at TEXT ,updated_by INTEGER" +
        ")");

    // user_permission table
    datatables = db.execute(
        "CREATE TABLE user_permission (up_id INTEGER,up_uuid TEXT ,user_id  INTEGER," +
            "status INTEGER,permission_id INTEGER ,up_updated_at TEXT,up_updated_by INTEGER);");

    // Branch TABLE
    // TODO : table create branch

    // Table	category

    datatables = db.execute(
        "CREATE TABLE category (category_id INTEGER,uuid TEXT," +
            "name TEXT,category_icon TEXT ,parent_id INTEGER,is_for_web INTEGER," +
            "status INTEGER,updated_at TEXT,updated_by INTEGER);");

    // Table	category_branch
    datatables = db.execute(
        "CREATE TABLE category_branch (cb_id INTEGER,uuid TEXT,category_id INTEGER," +
            "branch_id INTEGER ,display_order INTEGER);");

    //  Table	attributes

    datatables = db.execute(
        "CREATE TABLE attributes (attribute_id INTEGER,uuid TEXT,name TEXT," +
            "is_default INTEGER ,status INTEGER,updated_at TEXT, updated_by INTEGER);");

    //Table	modifier

    datatables = db.execute(
        "CREATE TABLE modifier(modifier_id INTEGER,uuid TEXT,name TEXT,is_default INTEGER," +
            "status INTEGER,updated_at TEXT, updated_by INTEGER);");

    //  Table	price_type

    datatables = db.execute(
        "CREATE TABLE price_type(pt_id INTEGER,uuid TEXT,name TEXT,is_default INTEGER ," +
            "status INTEGER,updated_at TEXT, updated_by INTEGER);");

    // Table product

    datatables = db.execute(
        "CREATE TABLE product(product_id INTEGER,name TEXT,description TEXT,sku TEXT,price_type_id INTEGER," +
            "price INTEGER,old_price INTEGER,has_inventory INTEGER,status INTEGER,updated_at TEXT,updated_by INTEGER" +
            ")");

    // Table product_category
    datatables = db.execute(
        "CREATE TABLE product_category(product_id INTEGER,category_id INTEGER,branch_id TEXT,display_order INTEGER" +
            "status INTEGER,updated_at TEXT,updated_by INTEGER" +
            ")");

    // Table product_attribute
    datatables = db.execute(
        "CREATE TABLE product_attribute(pa_id INTEGER,uuid TEXT,product_id INTEGER,attribute_id INTEGER" +
            "price INTEGER,status INTEGER,updated_at TEXT,updated_by INTEGER" +
            ")");

    // Table product_modifier
    datatables = db.execute(
        "CREATE TABLE product_modifier(pm_id INTEGER,uuid TEXT,product_id INTEGER,modifier_id INTEGER" +
            "price INTEGER,status INTEGER,updated_at TEXT,updated_by INTEGER" +
            ")");

    // Table product_branch
    datatables = db.execute(
        "CREATE TABLE product_branch(pb_id INTEGER,uuid TEXT,product_id INTEGER,branch_id INTEGER" +
            "display_order INTEGER,status INTEGER,updated_at TEXT,updated_by INTEGER" +
            ")");

    // Table asset
    // TODO  : create

    // Table product_store_inventory
    // TODO  : create

    // Table product_store_inventory_log
    // TODO  : create

    // Table printer
    // TODO  : create

    // Table kitchen_department
    // TODO  : kitchen_department

    // Table Shift
    // TODO  : Shift

    // Table Shift_details
    // TODO  : Shift_details

    // TABLE payment_master
    // TODO  : payment_master

    // TABLE table
    // TODO  : table

    // TABLE terminal
    // TODO  : terminal

    // TABLE voucher
    // TODO  : voucher

    // TABLE order
    datatables = db.execute(
        "CREATE TABLE orders(order_id INTEGER,uuid TEXT,branch_id INTEGER,terminal_id INTEGER," +
            "app_id INTEGER,table_no TEXT ,invoice_no TEXT,customer_id INTEGER,tax_percent INTEGER," +
            "tax_amount REAL,voucher_id INTEGER,voucher_amount REAL,sub_total REAL,sub_total_after_discount REAL,grand_total REAL," +
            "order_source INTEGER,order_status INTEGER,order_item_count INTEGER,order_date TEXT,order_by INTEGER" +
            ")");

    // TABLE order_detail

    datatables = db.execute(
        "CREATE TABLE order_detail (detail_id INTEGER,uuid TEXT,order_id INTEGER,branch_id INTEGER," +
            "terminal_id INTEGER,app_id INTEGER,product_id INTEGER,category_id INTEGER,detail_attribute_id INTEGER," +
            "detail_attribute_price INTEGER,detail_amount REAL,detail_qty INTEGER,detail_status INTEGER" +
            "detail_datetime TEXT,detail_by INTEGER" +
            ")");

    // TABLE order_modifier
    datatables = db.execute(
        "CREATE TABLE order_modifier (om_id INTEGER,uuid TEXT,order_id INTEGER,detail_id INTEGER,terminal_id INTEGER," +
            "app_id INTEGER,product_id INTEGER,modifier_id INTEGER,om_amount REAL,om_status INTEGER,om_datetime TEXT,om_by INTEGER" +
            ")");

    // TABLE order_payment
    datatables = db.execute(
        "CREATE TABLE order_payment (op_id INTEGER,uuid TEXT,order_id INTEGER,branch_id INTEGER,terminal_id INTEGER," +
            "app_id INTEGER,op_method_id INTEGER,op_amount REAL,op_method_response TEXT,op_status INTEGER,op_datetime TEXT,op_by INTEGER" +
            ")");

    //Table customer

    datatables = db.execute("CREATE TABLE order_payment (customer_id " +
        "customer_id	INTEGER," +
        "uuid	char TEXT," +
        "app_id	INTEGER," +
        "terminal_id	INTEGER," +
        "first_name	TEXT," +
        "last_name	TEXT," +
        "name	TEXT," +
        "email	TEXT," +
        "phonecode	INTEGER," +
        "mobile	TEXT," +
        "password	TEXT," +
        "address	TEXT," +
        "country_id	INTEGER," +
        "state_id	INTEGER," +
        "city_id	INTEGER," +
        "zipcode	TEXT," +
        "api_token	TEXT," +
        "profile	TEXT," +
        "last_login	TEXT," +
        "status	INTEGER," +
        "created_at	TEXT," +
        "created_by	INTEGER," +
        "updated_at	TEXT," +
        "updated_by	INTEGER," +
        ")");

    return datatables;
  }
}
