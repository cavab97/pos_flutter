import 'package:flutter/services.dart';
import 'package:mcncashier/models/Asset.dart';
import 'package:mcncashier/models/Attributes.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/models/Category.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/models/Pinter.dart';
import 'package:mcncashier/models/Price_Type.dart';
import 'package:mcncashier/models/Product.dart';
import 'package:mcncashier/models/Product_Attribute.dart';
import 'package:mcncashier/models/Product_Categroy.dart';
import 'package:mcncashier/models/Product_Modifire.dart';
import 'package:mcncashier/models/Product_Store_Inventory.dart';
import 'package:mcncashier/models/Product_branch.dart';
import 'package:mcncashier/models/Category_Attributes.dart';
import 'package:mcncashier/models/Role.dart';
import 'package:mcncashier/models/Modifier.dart';
import 'package:mcncashier/models/Terminal.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/models/Tax.dart';
import 'package:mcncashier/models/Table.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/models/Voucher.dart';
import 'package:mcncashier/models/category_branch.dart';
import 'package:sqflite/sqflite.dart';

class TableData {
  Future<int> ifExists(Database db, dynamic data) async {
    int count = Sqflite.firstIntValue(await db.rawQuery(
        "SELECT COUNT(*) FROM $data['table'] WHERE $data['key'] =$data['value']"));
    return count;
  }

  Future<dynamic> insertDatatable1(Database db, dynamic tablesData) async {
    print(db);
    print(tablesData);
    var branchData = tablesData["branch"];
    var userData = tablesData["user"];
    var roleData = tablesData["role"];
    var taxData = tablesData["branch_tax"];
    try {
      if (branchData.length != 0) {
        for (var i = 0; i < branchData.length; i++) {
          var branchDataitem = branchData[i];
          Branch branch = Branch.fromJson(branchDataitem);
          // var data = {
          //   'table': "branch",
          //   'key': "branch_id",
          //   'value': branch.branchId,
          // };
          // var count = await ifExists(db, data);
          // if (count == 0) {
          var result = await db.insert("branch", branch.toJson());
          print(result);
          // } else {
          //   var result = await db.update("branch", branch.toJson());
          //   print(result);
          // }
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
      if (taxData.length != 0) {
        for (var i = 0; i < taxData.length; i++) {
          var taxDataitem = taxData[i];
          Tax role = Tax.fromJson(taxDataitem);
          var result = await db.insert("branch_tax", role.toJson());
          print(result);
        }
      }
      return 1;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  Future<dynamic> insertDatatable2_1(Database db, dynamic tablesData) async {
    print(db);
    print(tablesData);
    var categoryData = tablesData["category"];
    var attributeData = tablesData["attributes"];
    var productData = tablesData["product"];
    var categorybranchData = tablesData["category_branch"];
    var catAttributeData = tablesData["category_attribute"];
    var modifierData = tablesData["modifier"];

    try {
      if (categoryData.length != 0) {
        for (var i = 0; i < categoryData.length; i++) {
          var categoryDataitem = categoryData[i];
          Category category = Category.fromJson(categoryDataitem);
          var result = await db.insert("category", category.toJson());
          print(result);
        }
      }
      if (categorybranchData.length != 0) {
        for (var i = 0; i < categorybranchData.length; i++) {
          var categorybranchDataitem = categorybranchData[i];
          CategroyBranch categroyBranch =
              CategroyBranch.fromJson(categorybranchDataitem);
          var result =
              await db.insert("category_branch", categroyBranch.toJson());
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

      if (attributeData.length != 0) {
        for (var i = 0; i < attributeData.length; i++) {
          var attributeDataitem = attributeData[i];
          Attributes attribute = Attributes.fromJson(attributeDataitem);
          var result = await db.insert("attributes", attribute.toJson());
          print(result);
        }
      }
      if (catAttributeData.length != 0) {
        for (var i = 0; i < catAttributeData.length; i++) {
          var categoryattributeDataitem = catAttributeData[i];
          CategoryAttribute catattribute =
              CategoryAttribute.fromJson(categoryattributeDataitem);
          var result =
              await db.insert("category_attribute", catattribute.toJson());
          print(result);
        }
      }
      if (modifierData.length != 0) {
        for (var i = 0; i < modifierData.length; i++) {
          var modifierDataitem = modifierData[i];
          Modifier modifier = Modifier.fromJson(modifierDataitem);
          var result = await db.insert("modifier", modifier.toJson());
          print(result);
        }
      }
      return 1;
    } catch (e) {
      print(e);
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
      print(e);
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
      print(e);
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

      if (terminalData != null) {
        var terminalDataitem = terminalData;
        Terminal terminal = Terminal.fromJson(terminalDataitem);
        var result = await db.insert("terminal", terminal.toJson());
        print(result);
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
          Payments payments = Payments.fromJson(paymentDataitem);
          var result = await db.insert("payment", payments.toJson());
          print(result);
        }
      }
      return 1;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  Future<dynamic> insertDatatable4_1(Database db, dynamic tablesData) async {
    print(db);
    print(tablesData);
    var voucherData = tablesData["voucher"];
    try {
      if (voucherData.length != 0) {
        for (var i = 0; i < voucherData.length; i++) {
          var voucherDataitem = voucherData[i];
          Voucher vouchers = Voucher.fromJson(voucherDataitem);
          var result = await db.insert("voucher", vouchers.toJson());
          print(result);
        }
      }
      return 1;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  Future<dynamic> insertDatatable4_2(Database db, dynamic tablesData) async {
    print(db);
    print(tablesData);
    var shiftdata = tablesData["shift"];
    try {
      if (shiftdata.length != 0) {
        for (var i = 0; i < shiftdata.length; i++) {
          var shiftdataitem = shiftdata[i];
          Shift shift = Shift.fromJson(shiftdataitem);
          var result = await db.insert("shift", shift.toJson());
          print(result);
        }
      }
      return 1;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  Future<dynamic> insertProductImage(Database db, dynamic tablesData) async {
    print(db);
    print(tablesData);
    var imageData = tablesData["product_image"];
    try {
      if (imageData.length != 0) {
        for (var i = 0; i < imageData.length; i++) {
          var imageDataitem = imageData[i];
          Assets accet = Assets.fromJson(imageDataitem);
          var result = await db.insert("asset", accet.toJson());
          print(result);
        }
      }
      return 1;
    } catch (e) {
      print(e);
      return 0;
    }
  }
}
