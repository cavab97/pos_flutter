import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/models/Category.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/Pinter.dart';
import 'package:mcncashier/models/Price_Type.dart';
import 'package:mcncashier/models/Product.dart';
import 'package:mcncashier/models/Product_Attribute.dart';
import 'package:mcncashier/models/Product_Categroy.dart';
import 'package:mcncashier/models/Product_Modifire.dart';
import 'package:mcncashier/models/Product_Store_Inventory.dart';
import 'package:mcncashier/models/Product_branch.dart';
import 'package:mcncashier/models/Role.dart';
import 'package:mcncashier/models/Terminal.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/models/Table.dart';
import 'package:sqflite/sqflite.dart';

class TableData {
  // Future<dynamic> getRoleData(Database db) async {
  //   List<Map> list = await db.rawQuery('SELECT * FROM role');
  //   return list;
  // }

  Future<dynamic> ifExists(dynamic data) {
    //  Cursor cursor = null;
    //  String checkQuery = "SELECT " + KEY_NAME + " FROM " + TABLE_SHOP + " WHERE " + KEY_NAME + "= '"+model.getName() + "'";
    //   cursor= db.rawQuery(checkQuery,null);
    //   boolean exists = (cursor.getCount() > 0);
    //   cursor.close();
    //   return exists;
  }
  Future<dynamic> insertDatatable1(Database db, dynamic tablesData) async {
    print(db);
    print(tablesData);
    var branchData = tablesData["branch"];
    var userData = tablesData["user"];
    var roleData = tablesData["role"];
    try {
      if (branchData.length != 0) {
        for (var i = 0; i < branchData.length; i++) {
          var branchDataitem = branchData[i];
          Branch branch = Branch.fromJson(branchDataitem);
          var result = await db.insert("branch", branch.toJson());
          print(result);
        }
      }
      if (userData.length != 0) {
        for (var i = 0; i < userData.length; i++) {
          var userDataitem = userData[i];
          User user = User.fromJson(userDataitem);
          var result = await db.insert("users", user.toJson());
          print(result);
        }
      }
      if (roleData.length != 0) {
        for (var i = 0; i < roleData.length; i++) {
          var roleDataitem = roleData[i];
          Role role = Role.fromJson(roleDataitem);
          var result = await db.insert("role", role.toJson());
          print(result);
        }
      }
      return 1;
    } catch (e) {
      return 0;
    }
  }

  Future<dynamic> insertDatatable2_1(Database db, dynamic tablesData) async {
    print(db);
    print(tablesData);
    var categoryData = tablesData["category"];
    var productData = tablesData["product"];
    try {
      if (categoryData.length != 0) {
        for (var i = 0; i < categoryData.length; i++) {
          var categoryDataitem = categoryData[i];
          Category category = Category.fromJson(categoryDataitem);
          var result = await db.insert("category", category.toJson());
          print(result);
        }
      }
      if (productData.length != 0) {
        for (var i = 0; i < productData.length; i++) {
          var productDataitem = productData[i];
          Product product = Product.fromJson(productDataitem);
          var result = await db.insert("product", product.toJson());
          print(result);
        }
      }
      return 1;
    } catch (e) {
      return 0;
    }
  }

  Future<dynamic> insertDatatable2_2(Database db, dynamic tablesData) async {
    print(db);
    print(tablesData);
    var productattributeData = tablesData["product_attribute"];
    var productmodifireData = tablesData["product_modifier"];
    var productcategoryData = tablesData["product_category"];
    var productbranchData = tablesData["product_branch"];
    var productstoreData = tablesData["product_store_inventory"];
    try {
      if (productattributeData.length != 0) {
        for (var i = 0; i < productattributeData.length; i++) {
          var productattrDataItem = productattributeData[i];
          ProductAttribute product =
              ProductAttribute.fromJson(productattrDataItem);
          var result = await db.insert("product_attribute", product.toJson());
          print(result);
        }
      }

      if (productmodifireData.length != 0) {
        for (var i = 0; i < productmodifireData.length; i++) {
          var productmodifireDataitem = productmodifireData[i];
          ProductModifier productmodifire =
              ProductModifier.fromJson(productmodifireDataitem);
          var result =
              await db.insert("product_modifier", productmodifire.toJson());
          print(result);
        }
      }
      if (productcategoryData.length != 0) {
        for (var i = 0; i < productcategoryData.length; i++) {
          var productcategoryDataitem = productcategoryData[i];
          ProductCategory productcategory =
              ProductCategory.fromJson(productcategoryDataitem);
          var result =
              await db.insert("product_category", productcategory.toJson());
          print(result);
        }
      }
      if (productbranchData.length != 0) {
        for (var i = 0; i < productbranchData.length; i++) {
          var productbranchDataitem = productbranchData[i];
          ProductBranch productbranch =
              ProductBranch.fromJson(productbranchDataitem);
          var result =
              await db.insert("product_branch", productbranch.toJson());
          print(result);
        }
      }
      if (productstoreData.length != 0) {
        for (var i = 0; i < productstoreData.length; i++) {
          var productstoreDataitem = productstoreData[i];
          ProductStoreInventory producatstore =
              ProductStoreInventory.fromJson(productstoreDataitem);
          var result = await db.insert(
              "product_store_inventory", producatstore.toJson());
          print(result);
        }
      }
      return 1;
    } catch (e) {
      return 0;
    }
  }

  Future<dynamic> insertDatatable2_3(Database db, dynamic tablesData) async {
    print(tablesData);
    var pricetypeData = tablesData["price_type"];
    var printerData = tablesData["printer"];
    try {
      if (pricetypeData.length != 0) {
        for (var i = 0; i < pricetypeData.length; i++) {
          var pricetypeDataitem = pricetypeData[i];
          Pricetype priceType = Pricetype.fromJson(pricetypeDataitem);
          var result = await db.insert("price_type", priceType.toJson());
          print(result);
        }
      }
      if (printerData.length != 0) {
        for (var i = 0; i < printerData.length; i++) {
          var printerDataitem = printerData[i];
          Printer printer = Printer.fromJson(printerDataitem);
          var result = await db.insert("printer", printer.toJson());
          print(result);
        }
      }
      return 1;
    } catch (e) {
      return 0;
    }
  }

  Future<dynamic> insertDatatable3(Database db, dynamic tablesData) async {
    print(tablesData);
    var customerData = tablesData["customer"];
    var terminalData = tablesData["terminal"];
    var tableData = tablesData["table"];
    var paymentData = tablesData["payment"];
    try {
      if (customerData.length != 0) {
        for (var i = 0; i < customerData.length; i++) {
          var customerDataitem = customerData[i];
          Customer customer = Customer.fromJson(customerDataitem);
          var result = await db.insert("customer", customer.toJson());
          print(result);
        }
      }

      if (terminalData.length != 0) {
        for (var i = 0; i < terminalData.length; i++) {
          var terminalDataitem = terminalData[i];
          Terminal terminal = Terminal.fromJson(terminalDataitem);
          var result = await db.insert("terminal", terminal.toJson());
          print(result);
        }
      }
      if (tableData.length != 0) {
        for (var i = 0; i < tableData.length; i++) {
          var tableDataitem = tableData[i];
          Tables table = Tables.fromJson(tableDataitem);
          var result = await db.insert("tables", table.toJson());
          print(result);
        }
      }
      if (paymentData.length != 0) {
        // TODO : need resaponce
        for (var i = 0; i < paymentData.length; i++) {
          var paymentDataitem = paymentData[i];
          //Payment table = Tables.fromJson(paymentDataitem);
          //var result = await db.insert("tables", table.toJson());
          //print(result);
        }
      }
      return 1;
    } catch (e) {
      return 0;
    }
  }

  Future<dynamic> insertDatatable4_1(Database db, dynamic tablesData) async {
    print(db);
    print(tablesData);
    return 1;
  }

  Future<dynamic> insertDatatable4_2(Database db, dynamic tablesData) async {
    print(db);
    print(tablesData);
    return 1;
  }
}
