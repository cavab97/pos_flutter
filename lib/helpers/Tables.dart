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
        "user_pin INTEGER," +
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
        "invoice_start TEXT," +
        "order_prefix TEXT," +
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
        "is_setmeal  INTEGER," + //(0 For No, 1 For Yes)
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
        "price REAL," +
        "old_price REAL," +
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
        "price REAL," +
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
        "printer_id INTEGER," +
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
        "qty	REAL," +
        "rac_id INTEGER," +
        "box_id INTEGER," +
        "warningStockLevel	INTEGER," +
        "status	INTEGER," +
        "updated_at	TEXT," +
        "updated_by	INTEGER" +
        ")");

    // Table product_store_inventory_log
    datatables = db.execute("CREATE TABLE product_store_inventory_log (" +
        "il_id INTEGER PRIMARY KEY AUTOINCREMENT," +
        "uuid	TEXT," +
        "inventory_id	INTEGER," +
        "branch_id	INTEGER," +
        "product_id	INTEGER," +
        "employe_id	INTEGER," +
        "il_type	INTEGER," +
        "qty	REAL," +
        "qty_before_change	REAL," +
        "qty_after_change	REAL," +
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
    datatables = db.execute("CREATE TABLE payment (" +
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
        "terminal_device_token TEXT," +
        "branch_id	INTEGER," +
        "terminal_type	INTEGER," +
        "terminal_is_mother	INTEGER," +
        "terminal_name	TEXT," +
        "terminal_verified_at TEXT," +
        "terminal_key	TEXT," +
        "status	INTEGER," +
        "updated_at	TEXT," +
        "updated_by	INTEGER," +
        "deleted_at	TEXT," +
        "deleted_by	INTEGER" +
        ")");

    datatables = db.execute("CREATE TABLE voucher_history (" +
        "voucher_history_id INTEGER PRIMARY KEY," +
        "uuid TEXT," +
        "voucher_id INTEGER," +
        "order_id INTEGER," +
        "user_id INTEGER," +
        "amount REAL," +
        "created_at TEXT" +
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
        "minimum_amount  REAL," +
        "maximum_amount  REAL," +
        "uses_total INTEGER," +
        "uses_customer INTEGER," +
        "status	INTEGER," +
        "updated_at	TEXT," +
        "updated_by	INTEGER," +
        "deleted_at TEXT," +
        "deleted_by INTEGER"
            ")");

    // TABLE order
    datatables = db.execute("CREATE TABLE orders(" +
        "order_id INTEGER," +
        "uuid TEXT," +
        "branch_id INTEGER," +
        "terminal_id INTEGER," +
        "app_id INTEGER," +
        "table_no TEXT," +
        "table_id INTEGER," +
        "invoice_no TEXT," +
        "customer_id INTEGER," +
        "tax_percent INTEGER," +
        "tax_amount REAL," +
        "tax_json TEXT," +
        "voucher_id INTEGER," +
        "voucher_detail TEXT," +
        "voucher_amount REAL," +
        "sub_total REAL," +
        "sub_total_after_discount REAL," +
        "grand_total REAL," +
        "order_source INTEGER," + // 1  web, 2  app
        "order_status INTEGER," + //1 New,2 For Ongoing,3 For cancelled,4 For Completed,5 For Refunded
        "order_item_count INTEGER," +
        "order_date TEXT," +
        "server_id INTEGER," +
        "order_by INTEGER," +
        "updated_at TEXT," +
        "updated_by INTEGER" +
        ")");

    // TABLE order_detail

    datatables = db.execute("CREATE TABLE order_detail (" +
        "detail_id INTEGER," +
        "uuid TEXT," +
        "order_id INTEGER," +
        "branch_id INTEGER," +
        "terminal_id INTEGER," +
        "app_id INTEGER," +
        "product_id INTEGER," +
        "product_price REAL," +
        "product_old_price INTEGER," +
        "product_discount REAL," +
        "product_detail TEXT," +
        "category_id INTEGER," +
        "detail_amount REAL," +
        "detail_qty REAL," +
        "detail_status INTEGER," +
        "detail_datetime TEXT," +
        'updated_at TEXT,' +
        'updated_by INTEGER,' +
        "detail_by INTEGER" +
        ")");

    // TABLE order_modifier
    datatables = db.execute("CREATE TABLE order_modifier(" +
        "om_id INTEGER," +
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
    // TABLE order_modifier
    datatables = db.execute("CREATE TABLE order_attributes(" +
        "oa_id INTEGER," +
        "uuid TEXT," +
        "order_id INTEGER," +
        "detail_id INTEGER," +
        "terminal_id INTEGER," +
        "app_id INTEGER," +
        "product_id INTEGER," +
        "attribute_id INTEGER," +
        "attr_price INTEGER," +
        "ca_id INTEGER," +
        "oa_status INTEGER," +
        "oa_datetime TEXT," +
        "oa_by INTEGER," +
        "updated_at TEXT," +
        "updated_by INTEGER" +
        ")");

    // TABLE order_payment
    datatables = db.execute("CREATE TABLE order_payment (" +
        "op_id INTEGER," +
        "uuid TEXT," +
        "order_id INTEGER," +
        "branch_id  INTEGER," +
        "terminal_id INTEGER," +
        "app_id INTEGER," +
        "op_method_id INTEGER," +
        "op_amount REAL," +
        "op_method_response TEXT," +
        "op_status INTEGER," + // 1 New,2 For Ongoing,3 For cancelled,4 For Completed,5 For Refunded
        "op_datetime TEXT," +
        "op_by INTEGER," +
        "updated_at TEXT," +
        "updated_by INTEGER" +
        ")");
// TABLE order_payment
    datatables = db.execute("CREATE TABLE order_cancel (" +
        "id INTEGER ," +
        "order_id INTEGER," +
        "localID TEXT," +
        "reason TEXT," +
        "status INTEGER," + // New,2 For Ongoing,3 For cancelled,4 For Completed,5 For Refunded
        "created_by INTEGER," +
        "updated_by INTEGER," +
        "created_at TEXT," +
        "updated_at TEXT," +
        "server_id INTEGER," +
        "terminal_id INTEGER" +
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
        "merged_table_id  INTEGER," +
        "number_of_pax  INTEGER," +
        "table_seat  TEXT," +
        "save_order_id  INTEGER," +
        "merged_pax TEXT," +
        "table_locked_by  INTEGER," +
        "is_order_merged  REAl" +
        ")");

    datatables = db.execute("CREATE TABLE mst_cart(" +
        'id INTEGER PRIMARY KEY AUTOINCREMENT,' +
        'localID TEXT,' +
        'user_id INTEGER,' +
        'branch_id INTEGER,' +
        'sub_total REAL,' + //DOUBLE
        'discount REAL,' +
        'discount_type INTEGER,' +
        'remark TEXT,' +
        'table_id INTEGER,' +
        'tax REAL,' +
        'tax_json TEXT,' +
        'grand_total REAL,' +
        'total_qty  REAL,' +
        'is_deleted   INTEGER,' +
        'created_by  INTEGER,' +
        'created_at  TEXT,' +
        'sync NUMERIC,' +
        'cust_mobile TEXT,' +
        'cust_email TEXT,' +
        'customer_terminal INTEGER,' +
        'voucher_id INTEGER,' +
        'voucher_detail TEXT,' +
        'sub_total_after_discount REAL,' +
        'source NUMERIC,' + //1 For Web, 2 For App
        'total_item REAL,' +
        'cart_order_number TEXT,' +
        'cart_payment_id INTEGER,' +
        'cart_payment_response TEXT,' +
        'cart_payment_status NUMERIC' + //0 For Pending, 1 For complete
        ')');

    datatables = db.execute("CREATE TABLE mst_cart_sub_detail (" +
        " id INTEGER PRIMARY KEY AUTOINCREMENT," +
        " cart_details_id INTEGER," +
        " localID TEXT," +
        " product_id INTEGER," +
        " modifier_id INTEGER," +
        " modifier_price  REAL," +
        " attr_price  REAL," +
        " attribute_id INTEGER," +
        " ca_id INTEGER" +
        ")");

    datatables = db.execute("CREATE TABLE mst_cart_detail( " +
        'id INTEGER PRIMARY KEY AUTOINCREMENT,' +
        'cart_id INTEGER,' +
        'localID INTEGER,' +
        'product_id INTEGER,' +
        'printer_id INTEGER,' +
        'product_name TEXT,' +
        'product_price REAL,' +
        'product_net_price REAL,' +
        'product_qty REAL,' +
        'tax_id INTEGER,' +
        'tax_value REAL,' + //varchar
        'discount REAL,' + //DOUBLE
        'discount_type  INTEGER,' + //int
        'remark TEXT,' +
        'cart_detail TEXT,' +
        'is_deleted   INTEGER,' +
        'created_by  INTEGER,' +
        'created_at  TEXT,' +
        'is_send_kichen NUMERIC,' +
        'item_unit TEXT,' +
        'has_composite_inventory NUMERIC' + //BOOLEAN
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

    datatables = db.execute("CREATE TABLE tax(" +
        "tax_id INTEGER PRIMARY KEY," +
        "uuid TEXT," +
        "code TEXT," +
        "description TEXT," +
        "rate TEXT," +
        "is_fixed NUMERIC," +
        "status  INTEGER," +
        "updated_by INTEGER," +
        "updated_at TEXT" +
        ")");

    datatables = db.execute("CREATE TABLE branch_tax(" +
        "id INTEGER PRIMARY KEY," +
        "tax_id INTEGER," +
        "branch_id INTEGER," +
        "rate  INTEGER," +
        "status  INTEGER," +
        "updated_by INTEGER," +
        "updated_at TEXT" +
        ")");
    datatables = db.execute("CREATE TABLE save_order( " +
        "id INTEGER PRIMARY KEY AUTOINCREMENT," +
        "cart_id INTEGER," +
        "order_Name," +
        "number_of_pax INTEGER," +
        "is_table_order NUMERIC," +
        "created_At TEXT" +
        ")");

    datatables = db.execute("CREATE TABLE user_checkinout( " +
        "id INTEGER PRIMARY KEY AUTOINCREMENT," +
        "localID TEXT," +
        "user_id INTEGER," +
        "branch_id INTEGER," +
        "status INTEGER," +
        "timeinout TEXT," +
        "created_at TEXT," +
        "terminalid INTEGER," +
        "sync INTEGER" +
        ")");

    datatables = db.execute("CREATE TABLE terminal_log ( " +
        "id INTEGER PRIMARY KEY AUTOINCREMENT," +
        "uuid INTEGER," +
        "terminal_id INTEGER," +
        "branch_id INTEGER," +
        "module_name TEXT," +
        "discription TEXT," +
        "activity_date TEXT," +
        "activity_time TEXT," +
        "table_name TEXT," +
        "entity_id INTEGER," +
        "status NUMERIC," +
        "updated_at TEXT," +
        "updated_by INTEGER" +
        ")");

    // This table used fo store language
    datatables = db.execute("CREATE TABLE app_language( " +
        "language_id INTEGER PRIMARY KEY AUTOINCREMENT," +
        "name TEXT," +
        "code TEXT," +
        "country_id INTEGER," +
        "icon TEXT," +
        "currency TEXT," +
        "currency_sign TEXT," +
        "created_at TEXT" +
        ")");

    //  datatables = db.execute("CREATE TABLE voucher_log ( " +
    //     "id INTEGER PRIMARY KEY AUTOINCREMENT," +
    //     ")");

//POS ROle USer Table
    datatables = db.execute("CREATE TABLE pos_permission ( " +
        'pos_permission_id INTEGER,' +
        'pos_permission_name TEXT,' +
        'pos_permission_updated_at TEXT,' +
        'pos_permission_updated_by INTEGER' +
        ")");

    datatables = db.execute("CREATE TABLE pos_role_permission ( " +
        "pos_rp_id INTEGER PRIMARY KEY AUTOINCREMENT," +
        "pos_rp_uuid TEXT," +
        "pos_rp_role_id INTEGER," +
        "pos_rp_permission_id INTEGER," +
        "pos_rp_permission_status NUMERIC," +
        "pos_rp_updated_at TEXT," +
        "pos_rp_updated_by INTEGER" +
        ")");

    datatables = db.execute("CREATE TABLE user_pos_permission ( " +
        "up_pos_id INTEGER PRIMARY KEY AUTOINCREMENT," +
        "up_pos_uuid TEXT," +
        "user_id INTEGER," +
        "status NUMERIC," +
        "pos_permission_id INTEGER," +
        "updated_at TEXT," +
        "updated_by INTEGER" +
        ")");

// ShiftInvoice
    datatables = db.execute("CREATE TABLE shift_invoice ( " +
        "id INTEGER PRIMARYKEY AUTOINCREAMENT," +
        "shift_id INTEGER," +
        "invoice_id INTEGER," +
        "status INTEGER," +
        "created_by INTEGER," +
        "updated_by INTEGER," +
        "created_at TEXT," +
        "updated_at TEXT," +
        "sync NUMERIC," +
        "serverId INTEGER," +
        "localID TEXT," +
        "terminal_id INTEGER," +
        "shift_terminal_id INTEGER" +
        ")");

    //set Meal Tables \
    datatables = db.execute("CREATE TABLE setmeal ( " +
        "setmeal_id INTIGER PRIMARYKEY," +
        "uuid TEXT," +
        "name TEXT," +
        "price REAL," +
        "status NUMERIC," +
        "created_at TEXT," +
        "created_by INTIGER," +
        "updated_at TEXT," +
        "updated_by INTIGER" +
        ")");

    datatables = db.execute("CREATE TABLE setmeal_branch ( " +
        "setmeal_branch_id INTEGER," +
        "uuid TEXT," +
        "setmeal_id INTEGER," +
        "branch_id INTEGER," +
        "status NUMERIC," +
        "updated_at TEXT," +
        "updated_by INTEGER" +
        ")");

    datatables = db.execute("CREATE TABLE setmeal_product ( " +
        "setmeal_product_id INTEGERT," +
        "setmeal_id INTEGERT," +
        "product_id INTEGERT," +
        "quantity REAL," +
        "status NUMERIC," +
        "created_at TEXT," +
        "updated_at INTEGERT" +
        ")");
    return datatables;
  }
}

// DAtaType For flutter
// **** INTEGER
// INT
// INTEGER
// TINYINT
// SMALLINT
// MEDIUMINT
// BIGINT
// UNSIGNED BIG INT
// INT2
// INT8

// *** TEXT

// CHARACTER(20)
// VARCHAR(255)
// VARYING CHARACTER(255)
// NCHAR(55)
// NATIVE CHARACTER(70)
// NVARCHAR(100)
// TEXT
// CLOB

/// ***  BLOB
//  BLOB
// no datatype specified

// *** REAL

//  REAL
// DOUBLE
// DOUBLE PRECISION
// FLOAT

// NUMERIC

// NUMERIC
// DECIMAL(10,5)
// BOOLEAN
// DATE
// DATETIME
