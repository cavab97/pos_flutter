import 'package:sqflite/sqflite.dart';

class CreateTables {
  Future<dynamic> createTable(Database db) {
    // Role Table
    var datatables;
    datatables = db.execute("CREATE TABLE role (" +
        "role_id	INTEGER PRIMARY KEY," +
        "role_name TEXT," +
        "uuid TEXT," +
        "role_status INTEGER," +
        "role_updated_at	TEXT," +
        "role_updated_by INTEGER" +
        ");");
    // db.transaction((txn) async {
    //   int id1 = await txn.rawInsert(
    //       'INSERT INTO role(role_id, role_name, uuid,role_status,role_updated_at,role_updated_by)' +
    //           'VALUES(1, "test","tetstsfsdf" ,0,"20-12-2020 11:44:32",1)');
    //   print('inserted1: $id1');
    //   int id2 = await txn.rawInsert(
    //       'INSERT INTO role(role_id, role_name, uuid,role_status,role_updated_at,role_updated_by)' +
    //           'VALUES(2, "test", "dfsdfsdfsdf",1,"20-12-2020 11:44:32",2)');
    //   print('inserted2: $id2');
    // });

    // // module table
    datatables = db.execute("CREATE TABLE module(" +
        "module_id	INTEGER PRIMARY KEY," +
        "module_name TEXT," +
        "module_updated_at TEXT," +
        "module_updated_by INTEGER);");

    // Table role_permission table
    datatables = db.execute("CREATE TABLE role_permission(" +
        "rp_id INTEGER PRIMARY KEY," +
        "rp_uuid TEXT," +
        "rp_role_id	INTEGER ," +
        "rp_module_id INTEGER," +
        "rp_updated_at TEXT," +
        "rp_updated_by INTEGER);");

    // user  table

    datatables = db.execute("CREATE TABLE users (" +
        "id INTEGER PRIMARY KEY," +
        "terminal_id INTEGER," +
        "app_id INTEGER," +
        "uuid TEXT," +
        "name TEXT," +
        "email TEXT," +
        "role INTEGER," +
        "username TEXT," +
        "password TEXT," +
        "country_code TEXT ," +
        "mobile TEXT," +
        "profile TEXT," +
        "commision_percent REAL," +
        "user_pin TEXT," +
        "api_token TEXT," +
        "status INTEGER," +
        "is_admin INTEGER," +
        "device_id TEXT ," +
        "device_token TEXT," +
        "auth_key TEXT," +
        "last_login TEXT," +
        "created_at TEXT," +
        "updated_at TEXT," +
        "deleted_at TEXT," +
        "created_by INTEGER," +
        "updated_by INTEGER," +
        "deleted_by INTEGER" +
        ")");

    // db.transaction((txn) async {
    //   int id1 = await txn.rawInsert('INSERT INTO users(' +
    //       'id,terminal_id,app_id,uuid,name,role,username,password,country_code,' +
    //       'mobile,profile,commision_percent,pin,status,device_id,device_token,' +
    //       'auth_key,last_login,remember_token)' +
    //       'VALUES(1,1,1,"uuid","name",2,"username","password","country_code","mobile",' +
    //       '"profile",0,"013234",1,"device_id","device_token","auth_key","last_login","remember_token"'
    //           ')');
    //   print('inserted1: $id1');
    // });

    //customer_address TABLE
    //TODO : table create address

    datatables = db.execute("CREATE TABLE customer_address(" +
        "address_id INTEGER PRIMARY KEY," +
        "terminal_id INTEGER," +
        "app_id INTEGER," +
        "uuid TEXT" +
        "user_id INTEGER," +
        "address_line1 TEXT," +
        "address_line2 TEXT," +
        "latitude TEXT," +
        "longitude TEXT ," +
        "is_default INTEGER," +
        "status INTEGER," +
        "updated_at TEXT," +
        "updated_by INTEGER" +
        ")");

    // user_permission table
    datatables = db.execute("CREATE TABLE user_permission(" +
        "up_id INTEGER PRIMARY KEY," +
        "up_uuid TEXT ," +
        "user_id  INTEGER," +
        "status INTEGER," +
        "permission_id INTEGER," +
        "up_updated_at TEXT," +
        "up_updated_by INTEGER)");

    // Branch TABLE
    datatables = db.execute("CREATE TABLE branch (" +
        "branch_id	INTEGER PRIMARY KEY," +
        "uuid	TEXT," +
        "name	TEXT," +
        "address	TEXT," +
        "contact_no	TEXT," +
        "email	TEXT," +
        "contact_person	TEXT," +
        "open_from	TEXT," +
        "closed_on	TEXT," +
        "tax INTEGER," +
        "branch_banner TEXT," +
        "latitude	TEXT," +
        "longitude	TEXT," +
        "status	INTEGER," +
        "updated_at	TEXT," +
        "updated_by	INTEGER," +
        "deleted_at TEXT," +
        "deleted_by INTEGER," +
        "base64 TEXT"
            ")");

    // Table	category
    datatables = db.execute("CREATE TABLE category (" +
        "category_id INTEGER PRIMARY KEY," +
        "uuid TEXT," +
        "name TEXT," +
        "category_icon TEXT," +
        "slug TEXT," +
        "parent_id INTEGER," +
        "is_for_web INTEGER," +
        "status INTEGER," +
        "updated_at TEXT," +
        "updated_by INTEGER," +
        "deleted_at TEXT," +
        "deleted_by INTEGER"
            ")");

    // Table	category_branch
    datatables = db.execute("CREATE TABLE category_branch(" +
        "cb_id INTEGER PRIMARY KEY," +
        "uuid TEXT," +
        "status INTEGER," +
        "category_id INTEGER," +
        "branch_id INTEGER ," +
        "updated_at TEXT," +
        "updated_by INTEGER," +
        "display_order INTEGER)");

    //  Table	attributes

    datatables = db.execute("CREATE TABLE attributes (" +
        "attribute_id INTEGER PRIMARY KEY," +
        "uuid TEXT," +
        "is_default INTEGER," +
        "ca_id INTEGER," +
        "name TEXT," +
        "status INTEGER," +
        "updated_at TEXT, " +
        "updated_by INTEGER," +
        "deleted_at TEXT, " +
        "deleted_by INTEGER" +
        ");");

    //Table	modifier

    datatables = db.execute("CREATE TABLE modifier(" +
        "modifier_id INTEGER PRIMARY KEY," +
        "uuid TEXT," +
        "name TEXT," +
        "is_default INTEGER," +
        "status INTEGER," +
        "updated_at TEXT," +
        "updated_by INTEGER ," +
        "deleted_at TEXT," +
        "deleted_by INTEGER" +
        ");");

    //  Table	price_type

    datatables = db.execute("CREATE TABLE price_type(" +
        "pt_id INTEGER PRIMARY KEY," +
        "uuid TEXT," +
        "name TEXT," +
        // "is_default INTEGER ," +
        "status INTEGER," +
        "updated_at TEXT," +
        "updated_by INTEGER," +
        "deleted_at TEXT," +
        "deleted_by INTEGER" +
        ");");

    // Table product

    datatables = db.execute("CREATE TABLE product(" +
        "product_id INTEGER PRIMARY KEY," +
        "name TEXT," +
        "uuid TEXT," +
        "description TEXT," +
        "sku TEXT," +
        "price_type_id INTEGER," +
        "price_type_value TEXT ," +
        "price INTEGER," +
        "old_price INTEGER," +
        "has_inventory INTEGER," +
        "status INTEGER," +
        "updated_at TEXT," +
        "updated_by INTEGER," +
        "deleted_at TEXT," +
        "deleted_by INTEGER" +
        ")");

    // Table product_category
    datatables = db.execute("CREATE TABLE product_category(" +
        "pc_id INTEGER PRIMARY KEY," +
        "product_id INTEGER," +
        "category_id INTEGER," +
        "branch_id INTEGER," +
        "display_order INTEGER," +
        "status INTEGER," +
        "updated_at TEXT," +
        "updated_by INTEGER" +
        ")");

    // Table product_attribute
    datatables = db.execute("CREATE TABLE product_attribute(" +
        "pa_id INTEGER PRIMARY KEY," +
        "uuid TEXT," +
        "product_id INTEGER," +
        "attribute_id INTEGER," +
        "ca_id INTEGER," +
        "price INTEGER," +
        "status INTEGER," +
        "updated_at TEXT," +
        "updated_by INTEGER" +
        ")");

    // Table product_modifier
    datatables = db.execute("CREATE TABLE product_modifier(" +
        "pm_id INTEGER PRIMARY KEY," +
        "uuid TEXT," +
        "product_id INTEGER," +
        "modifier_id INTEGER," +
        "price INTEGER," +
        "status INTEGER," +
        "updated_at TEXT," +
        "updated_by INTEGER" +
        ")");

    // Table product_branch
    datatables = db.execute("CREATE TABLE product_branch(" +
        "pb_id INTEGER PRIMARY KEY," +
        "uuid TEXT," +
        "product_id INTEGER," +
        "branch_id INTEGER," +
        "warningStockLevel INTEGER," +
        "display_order INTEGER," +
        "status INTEGER," +
        "updated_at TEXT," +
        "updated_by INTEGER" +
        ")");

    // Table asset
    datatables = db.execute("CREATE TABLE asset (" +
        "asset_id	INTEGER PRIMARY KEY," +
        "uuid	TEXT," +
        "asset_type	INTEGER," +
        "asset_type_id	INTEGER," +
        "asset_path	TEXT," +
        "status	INTEGER," +
        "updated_at	TEXT," +
        "updated_by	INTEGER," +
        "base64 TEXT" +
        ")");

    // Table product_store_inventor
    datatables = db.execute("CREATE TABLE product_store_inventory (" +
        "inventory_id	INTEGER PRIMARY KEY," +
        "uuid	TEXT," +
        "product_id	INTEGER," +
        "branch_id	INTEGER," +
        "qty	TEXT," +
        "warningStockLevel	INTEGER," +
        "status	INTEGER," +
        "updated_at	TEXT," +
        "updated_by	INTEGER" +
        ")");

    // Table product_store_inventory_log
    datatables = db.execute("CREATE TABLE product_store_inventory_log (" +
        "il_id	INTEGER PRIMARY KEY," +
        "uuid	TEXT," +
        "inventory_id	INTEGER," +
        "branch_id	INTEGER," +
        "product_id	INTEGER," +
        "employe_id	INTEGER," +
        "il_type	INTEGER," +
        "qty	TEXT," +
        "qty_before_change	TEXT," +
        "qty_after_change	TEXT," +
        "updated_at	TEXT," + // 1 = Add , 2 = Deduct
        "updated_by	INTEGER" +
        ")");

    // Table printer
    datatables = db.execute("CREATE TABLE printer (" +
        "printer_id	INTEGER PRIMARY KEY," +
        "uuid	TEXT," +
        "branch_id	INTEGER," +
        "printer_name	TEXT," +
        "printer_ip	TEXT," +
        "printer_is_cashier	INTEGER," +
        "status	INTEGER," +
        "updated_at	TEXT," +
        "updated_by	INTEGER," +
        "deleted_at	TEXT," +
        "deleted_by	INTEGER" +
        ")");

    // Table kitchen_department
    datatables = db.execute("CREATE TABLE kitchen_department (" +
        "kitchen_id	INTEGER PRIMARY KEY," +
        "uuid	TEXT," +
        "branch_id	INTEGER," +
        "kitchen_name	TEXT," +
        "kitchen_printer_id	INTEGER," +
        "status	INTEGER," +
        "updated_at	TEXT," +
        "updated_by	INTEGER" +
        ")");

    // TABLE payment_master
    datatables = db.execute("CREATE TABLE payment_master (" +
        "payment_id	INTEGER PRIMARY KEY," +
        "uuid	TEXT," +
        "name	TEXT," +
        "status	INTEGER," +
        "updated_at	INTEGER," +
        "updated_by	INTEGER" +
        ")");

    // TABLE table
    datatables = db.execute("CREATE TABLE tables (" +
        "table_id	INTEGER PRIMARY KEY," +
        "uuid	TEXT," +
        "branch_id	INTEGER," +
        "table_type	INTEGER," +
        "table_name	TEXT," +
        "table_qr	TEXT," +
        "table_capacity	INTEGER," +
        "status	INTEGER," +
        "available_status INTEGER," +
        "updated_at	TEXT," +
        "updated_by	INTEGER," +
        "deleted_at	TEXT," +
        "deleted_by	INTEGER" +
        ")");

    // TABLE terminal
    //type :  1 = Cashier , 2 For Waiter , 3 For Attendance
    // is mother = 1  = Yes , 0 = No
    datatables = db.execute("CREATE TABLE terminal (" +
        "terminal_id INTEGER PRIMARY KEY," +
        "uuid	TEXT," +
        "terminal_device_id	TEXT," +
        "branch_id	INTEGER," +
        "terminal_type	INTEGER," +
        "terminal_is_mother	INTEGER," +
        "terminal_name	TEXT," +
        "terminal_key	TEXT," +
        "status	INTEGER," +
        "updated_at	TEXT," +
        "updated_by	INTEGER," +
        "deleted_at	TEXT," +
        "deleted_by	INTEGER" +
        ")");

    // TABLE voucher
    datatables = db.execute("CREATE TABLE voucher (" +
        "voucher_id	INTEGER PRIMARY KEY," +
        "uuid	TEXT," +
        "voucher_name	TEXT," +
        "voucher_banner	TEXT," +
        "voucher_code	TEXT," +
        "voucher_discount_type	INTEGER," +
        "voucher_discount	REAL," +
        "voucher_applicable_from	TEXT," +
        "voucher_applicable_to	TEXT," +
        "voucher_categories	TEXT," +
        "voucher_products	TEXT," +
        "status	INTEGER," +
        "updated_at	TEXT," +
        "updated_by	INTEGER" +
        ")");

    // TABLE order
    datatables = db.execute("CREATE TABLE orders(" +
        "order_id INTEGER PRIMARY KEY," +
        "uuid TEXT," +
        "branch_id INTEGER," +
        "terminal_id INTEGER," +
        "app_id INTEGER," +
        "table_no TEXT," +
        "invoice_no TEXT," +
        "customer_id INTEGER," +
        "tax_percent INTEGER," +
        "tax_amount REAL," +
        "voucher_id INTEGER," +
        "voucher_amount REAL," +
        "sub_total REAL," +
        "sub_total_after_discount REAL," +
        "grand_total REAL," +
        "order_source INTEGER," +
        "order_status INTEGER," +
        "order_item_count INTEGER," +
        "order_date TEXT," +
        "order_by INTEGER" +
        ")");

    // TABLE order_detail

    datatables = db.execute("CREATE TABLE order_detail (" +
        "detail_id INTEGER PRIMARY KEY," +
        "uuid TEXT," +
        "order_id INTEGER," +
        "branch_id INTEGER," +
        "terminal_id INTEGER," +
        "app_id INTEGER," +
        "product_id INTEGER," +
        "category_id INTEGER," +
        "detail_attribute_id INTEGER," +
        "detail_attribute_price INTEGER," +
        "detail_amount REAL," +
        "detail_qty INTEGER," +
        "detail_status INTEGER" +
        "detail_datetime TEXT," +
        "detail_by INTEGER" +
        ")");

    // TABLE order_modifier
    datatables = db.execute("CREATE TABLE order_modifier(" +
        "om_id INTEGER PRIMARY KEY," +
        "uuid TEXT," +
        "order_id INTEGER," +
        "detail_id INTEGER," +
        "terminal_id INTEGER," +
        "app_id INTEGER," +
        "product_id INTEGER," +
        "modifier_id INTEGER," +
        "om_amount INTEGER," +
        "om_status INTEGER," +
        "om_datetime TEXT," +
        "om_by INTEGER," +
        "updated_at TEXT," +
        "updated_by INTEGER" +
        ")");

    // TABLE order_payment
    datatables = db.execute("CREATE TABLE order_payment (" +
        "op_id INTEGER PRIMARY KEY," +
        "uuid TEXT," +
        "order_id INTEGER," +
        "branch_id  INTEGER," +
        "terminal_id INTEGER," +
        "app_id INTEGER," +
        "op_method_id INTEGER," +
        "op_amount INTEGER ," +
        "op_method_response TEXT," +
        "op_status INTEGER," +
        "op_datetime TEXT," +
        "op_by INTEGER," +
        "updated_at TEXT," +
        "updated_by INTEGER" +
        ")");

    //Table customer

    datatables = db.execute("CREATE TABLE customer (" +
        "customer_id	INTEGER," +
        "uuid	char TEXT," +
        "app_id	INTEGER," +
        "terminal_id	INTEGER," +
        "first_name	TEXT," +
        "username TEXT," +
        "last_name	TEXT," +
        "name	TEXT," +
        "email	TEXT," +
        "role INTEGER," +
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
        "deleted_at	TEXT," +
        "deleted_by	INTEGER" +
        ")");

    //Tble  Table Order

    datatables = db.execute("CREATE TABLE table_order (" +
        "id	INTEGER PRIMARY KEY AUTOINCREMENT," +
        "table_id	INTEGER," +
        "is_merge_table  TEXT," +
        "merged_table_id  TEXT," +
        "number_of_pax  INTEGER," +
        "table_seat  TEXT," +
        "save_order_id  TEXT," +
        "merged_pax TEXT," +
        "table_locked_by  INTEGER," +
        "is_order_merged  REAl" +
        ")");

    datatables = db.execute("CREATE TABLE mst_cart(" +
        'id INTEGER PRIMARY KEY AUTOINCREMENT,' +
        'localID TEXT,' +
        'user_id INTEGER,' +
        'branch_id INTEGER,' +
        'sub_total REAL,' +
        'discount REAL,' +
        'discount_type INTEGER,' +
        'remark TEXT,' +
        'tax REAL,' +
        'grand_total REAL,' +
        'total_qty  INTEGER,' +
        'is_open INTEGER,' +
        'is_deleted   REAL,' +
        'created_by  INTEGER,' +
        'created_at  TEXT,' +
        'sync  REAL,' +
        'customer_terminal INTEGER,' +
        'queue_number INTEGER,' +
        'service_charge_rate REAL,' +
        'service_charge_amount INTEGER,' +
        'redeem_points REAL,' +
        'redeem_point_amount REAL,' +
        'product_points REAL' +
        ')');

    datatables = db.execute("CREATE TABLE shift(" +
        "shift_id INTEGER PRIMARY KEY AUTOINCREMENT," +
        "uuid TEXT," +
        "user_id INTEGER," +
        "branch_id INTEGER," +
        "start_amount INTEGER," +
        "end_amount INTEGER," +
        "status INTEGER," +
        "updated_by INTEGER," +
        "updated_at TEXT," +
        "app_id INTEGER," +
        "terminal_id INTEGER" +
        ")");

    datatables = db.execute("CREATE TABLE category_attribute(" +
        "ca_id INTEGER PRIMARY KEY," +
        "uuid TEXT," +
        "slug  TEXT," +
        "name  TEXT," +
        "status  INTEGER," +
        "updated_by INTEGER," +
        "updated_at TEXT" +
        ")");

    // datatables = db.execute("CREATE TABLE branch_tax(" +
    //     "id INTEGER PRIMARY KEY," +
    //     "tax_id INTEGER," +
    //     "brnach_id INTEGER," +
    //     "name  TEXT," +
    //     "rate  INTEGER," +
    //     "status  INTEGER," +
    //     "updated_by INTEGER," +
    //     "updated_at TEXT" +
    //     ")");
    return datatables;
  }
}
