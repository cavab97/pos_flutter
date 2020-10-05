import 'package:mcncashier/models/Asset.dart';
import 'package:mcncashier/models/Attributes.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/models/BranchTax.dart';
import 'package:mcncashier/models/Category.dart';
import 'package:mcncashier/models/Category_Attributes.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/Modifier.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/models/PosPermission.dart';
import 'package:mcncashier/models/PosRolePermission.dart';
import 'package:mcncashier/models/PosUserPermission.dart';
import 'package:mcncashier/models/Price_Type.dart';
import 'package:mcncashier/models/Printer.dart';
import 'package:mcncashier/models/Product.dart';
import 'package:mcncashier/models/ProductStoreInventoryLog.dart';
import 'package:mcncashier/models/Product_Attribute.dart';
import 'package:mcncashier/models/Product_Categroy.dart';
import 'package:mcncashier/models/Product_Modifire.dart';
import 'package:mcncashier/models/Product_Store_Inventory.dart';
import 'package:mcncashier/models/Product_branch.dart';
import 'package:mcncashier/models/Role.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/models/Table.dart';
import 'package:mcncashier/models/Tax.dart';
import 'package:mcncashier/models/Terminal.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/Voucher.dart';
import 'package:mcncashier/models/category_branch.dart';
import 'package:sqflite/sqflite.dart';

class TableData {
  Future<int> ifExists(Database db, dynamic data) async {
    try {
      int count = Sqflite.firstIntValue(await db.rawQuery(
          "SELECT COUNT(*) FROM " +
              data['table'] +
              " WHERE " +
              data['key'] +
              " = " +
              data['value'].toString() +
              ""));
      return count;
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> insertDatatable1(Database db, dynamic tablesData) async {
    print(db);
    print(tablesData);
    var branchData = tablesData["branch"];
    var userData = tablesData["user"];
    var roleData = tablesData["role"];
    var taxData = tablesData["branch_tax"];
    var taxList = tablesData["tax"];
    var posPermission = tablesData["pos_permission"];
    var posRolPermission = tablesData["pos_role_permission"];
    var userPosPermission = tablesData["user_pos_permission"];
    try {
      if (branchData.length != 0) {
        for (var i = 0; i < branchData.length; i++) {
          var branchDataitem = branchData[i];
          Branch branch = Branch.fromJson(branchDataitem);
          var data = {
            'table': "branch",
            'key': "branch_id",
            'value': branch.branchId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert("branch", branch.toJson());
            print(result);
          } else {
            var result = await db.update("branch", branch.toJson(),
                where: "branch_id =?", whereArgs: [branch.branchId]);
            print(result);
          }
        }
      }
      if (userData.length != 0) {
        for (var i = 0; i < userData.length; i++) {
          var userDataitem = userData[i];
          User user = User.fromJson(userDataitem);
          var data = {
            'table': "users",
            'key': "id",
            'value': user.id,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert("users", user.toJson());
            print(result);
          } else {
            var result = await db.update("users", user.toJson(),
                where: "id =?", whereArgs: [user.id]);
            print(result);
          }
        }
      }
      if (roleData.length != 0) {
        for (var i = 0; i < roleData.length; i++) {
          var roleDataitem = roleData[i];
          Role role = Role.fromJson(roleDataitem);
          var data = {
            'table': "role",
            'key': "role_id",
            'value': role.roleId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert("role", role.toJson());
            print(result);
          } else {
            var result = await db.update("role", role.toJson(),
                where: "role_id = ?", whereArgs: [role.roleId]);
            print(result);
          }
        }
      }
      if (taxData.length != 0) {
        for (var i = 0; i < taxData.length; i++) {
          var taxDataitem = taxData[i];
          BranchTax branchTax = BranchTax.fromJson(taxDataitem);
          var data = {
            'table': "branch_tax",
            'key': "id",
            'value': branchTax.id,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert("branch_tax", branchTax.toJson());
            print(result);
          } else {
            var result = await db.update("branch_tax", branchTax.toJson(),
                where: "id =?", whereArgs: [branchTax.id]);
            print(result);
          }
        }
      }
      if (taxList.length != 0) {
        for (var i = 0; i < taxList.length; i++) {
          var taxListitem = taxList[i];
          Tax taxval = Tax.fromJson(taxListitem);
          var data = {
            'table': "tax",
            'key': "tax_id",
            'value': taxval.taxId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert("tax", taxval.toJson());
            print(result);
          } else {
            var result = await db.update("tax", taxval.toJson(),
                where: 'tax_id =?', whereArgs: [taxval.taxId]);
            print(result);
          }
        }
      }
      if (posPermission.length != 0) {
        for (var i = 0; i < posPermission.length; i++) {
          var posPermissionitem = posPermission[i];
          PosPermission permission = PosPermission.fromJson(posPermissionitem);
          var data = {
            'table': "pos_permission",
            'key': "pos_permission_id",
            'value': permission.posPermissionId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert("pos_permission", permission.toJson());
            print(result);
          } else {
            var result = await db.update("pos_permission", permission.toJson(),
                where: 'pos_permission_id =?',
                whereArgs: [permission.posPermissionId]);
            print(result);
          }
        }
      }
      if (posRolPermission.length != 0) {
        for (var i = 0; i < posRolPermission.length; i++) {
          var posPermissionitem = posRolPermission[i];
          PosRolePermission permissionPOSrole =
              PosRolePermission.fromJson(posPermissionitem);
          var data = {
            'table': "pos_role_permission",
            'key': "pos_rp_id",
            'value': permissionPOSrole.posRpId
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert(
                "pos_role_permission", permissionPOSrole.toJson());
            print(result);
          } else {
            var result = await db.update(
                "pos_role_permission", permissionPOSrole.toJson(),
                where: 'pos_rp_id =?', whereArgs: [permissionPOSrole.posRpId]);
            print(result);
          }
        }
      }
      if (userPosPermission.length != 0) {
        for (var i = 0; i < userPosPermission.length; i++) {
          var userPosPermissionitem = userPosPermission[i];
          UserPosPermission userpermissionPOS =
              UserPosPermission.fromJson(userPosPermissionitem);
          var data = {
            'table': "user_pos_permission",
            'key': "up_pos_id",
            'value': userpermissionPOS.upPosId
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert(
                "user_pos_permission", userpermissionPOS.toJson());
            print(result);
          } else {
            var result = await db.update(
                "user_pos_permission", userpermissionPOS.toJson(),
                where: 'up_pos_id =?', whereArgs: [userpermissionPOS.upPosId]);
            print(result);
          }
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
          var data = {
            'table': "category",
            'key': "category_id",
            'value': category.categoryId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert("category", category.toJson());
            print(result);
          } else {
            var result = await db.update("category", category.toJson(),
                where: "category_id =?", whereArgs: [category.categoryId]);
            print(result);
          }
        }
      }
      if (categorybranchData.length != 0) {
        for (var i = 0; i < categorybranchData.length; i++) {
          var categorybranchDataitem = categorybranchData[i];
          CategroyBranch categroyBranch =
              CategroyBranch.fromJson(categorybranchDataitem);
          var data = {
            'table': "category_branch",
            'key': "cb_id",
            'value': categroyBranch.cbId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result =
                await db.insert("category_branch", categroyBranch.toJson());
            print(result);
          } else {
            var result = await db.update(
                "category_branch", categroyBranch.toJson(),
                where: "cb_id =?", whereArgs: [categroyBranch.cbId]);
            print(result);
          }
        }
      }
      if (productData.length != 0) {
        for (var i = 0; i < productData.length; i++) {
          var productDataitem = productData[i];
          Product product = Product.fromJson(productDataitem);
          var data = {
            'table': "product",
            'key': "product_id",
            'value': product.productId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert("product", product.toJson());
            print(result);
          } else {
            var result = await db.update("product", product.toJson(),
                where: "product_id =?", whereArgs: [product.productId]);
            print(result);
          }
        }
      }

      if (attributeData.length != 0) {
        for (var i = 0; i < attributeData.length; i++) {
          var attributeDataitem = attributeData[i];
          Attributes attribute = Attributes.fromJson(attributeDataitem);
          var data = {
            'table': "attributes",
            'key': "attribute_id",
            'value': attribute.attributeId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert("attributes", attribute.toJson());
            print(result);
          } else {
            var result = await db.update("attributes", attribute.toJson(),
                where: "attribute_id =?", whereArgs: [attribute.attributeId]);
            print(result);
          }
        }
      }
      if (catAttributeData.length != 0) {
        for (var i = 0; i < catAttributeData.length; i++) {
          var categoryattributeDataitem = catAttributeData[i];
          CategoryAttribute catattribute =
              CategoryAttribute.fromJson(categoryattributeDataitem);
          var data = {
            'table': "category_attribute",
            'key': "ca_id",
            'value': catattribute.caId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result =
                await db.insert("category_attribute", catattribute.toJson());
            print(result);
          } else {
            var result = await db.update(
                "category_attribute", catattribute.toJson(),
                where: "ca_id =?", whereArgs: [catattribute.caId]);
            print(result);
          }
        }
      }
      if (modifierData.length != 0) {
        for (var i = 0; i < modifierData.length; i++) {
          var modifierDataitem = modifierData[i];
          Modifier modifier = Modifier.fromJson(modifierDataitem);
          var data = {
            'table': "modifier",
            'key': "modifier_id",
            'value': modifier.modifierId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert("modifier", modifier.toJson());
            print(result);
          } else {
            var result = await db.update("modifier", modifier.toJson(),
                where: "modifier_id", whereArgs: [modifier.modifierId]);
            print(result);
          }
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
    var productstoreLogData = tablesData["product_store_inventory_log"];
    try {
      if (productattributeData.length != 0) {
        for (var i = 0; i < productattributeData.length; i++) {
          var productattrDataItem = productattributeData[i];
          ProductAttribute product =
              ProductAttribute.fromJson(productattrDataItem);
          var data = {
            'table': "product_attribute",
            'key': "pa_id",
            'value': product.paId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert(
              "product_attribute",
              product.toJson(),
            );
            print(result);
          } else {
            var result = await db.update("product_attribute", product.toJson(),
                where: "pa_id =?", whereArgs: [product.paId]);
            print(result);
          }
        }
      }

      if (productmodifireData.length != 0) {
        for (var i = 0; i < productmodifireData.length; i++) {
          var productmodifireDataitem = productmodifireData[i];
          ProductModifier productmodifire =
              ProductModifier.fromJson(productmodifireDataitem);

          var data = {
            'table': "product_modifier",
            'key': "pm_id",
            'value': productmodifire.pmId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result =
                await db.insert("product_modifier", productmodifire.toJson());
            print(result);
          } else {
            var result = await db.update(
                "product_modifier", productmodifire.toJson(),
                where: "pm_id =?", whereArgs: [productmodifire.pmId]);
            print(result);
          }
        }
      }
      if (productcategoryData.length != 0) {
        for (var i = 0; i < productcategoryData.length; i++) {
          var productcategoryDataitem = productcategoryData[i];
          ProductCategory productcategory =
              ProductCategory.fromJson(productcategoryDataitem);
          var data = {
            'table': "product_category",
            'key': "pc_id",
            'value': productcategory.pcId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result =
                await db.insert("product_category", productcategory.toJson());
            print(result);
          } else {
            var result = await db.update(
                "product_category", productcategory.toJson(),
                where: "pc_id =?", whereArgs: [productcategory.pcId]);
            print(result);
          }
        }
      }
      if (productbranchData.length != 0) {
        for (var i = 0; i < productbranchData.length; i++) {
          var productbranchDataitem = productbranchData[i];
          ProductBranch productbranch =
              ProductBranch.fromJson(productbranchDataitem);
          var data = {
            'table': "product_branch",
            'key': "pb_id",
            'value': productbranch.pbId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result =
                await db.insert("product_branch", productbranch.toJson());
            print(result);
          } else {
            var result = await db.update(
                "product_branch", productbranch.toJson(),
                where: "pb_id =?", whereArgs: [productbranch.pbId]);
            print(result);
          }
        }
      }
      if (productstoreData.length != 0) {
        for (var i = 0; i < productstoreData.length; i++) {
          var productstoreDataitem = productstoreData[i];
          ProductStoreInventory producatstore =
              ProductStoreInventory.fromJson(productstoreDataitem);
          var data = {
            'table': "product_store_inventory",
            'key': "inventory_id",
            'value': producatstore.inventoryId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert(
                "product_store_inventory", producatstore.toJson());
            print(result);
          } else {
            var result = await db.update(
                "product_store_inventory", producatstore.toJson(),
                where: "inventory_id =?",
                whereArgs: [producatstore.inventoryId]);
            print(result);
          }
        }
      }
      if (productstoreLogData.length != 0) {
        for (var i = 0; i < productstoreLogData.length; i++) {
          var productstoreLogDataitem = productstoreLogData[i];
          ProductStoreInventoryLog producatstorelog =
              ProductStoreInventoryLog.fromJson(productstoreLogDataitem);
          var data = {
            'table': "product_store_inventory_log",
            'key': "il_id",
            'value': producatstorelog.il_id,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert(
                "product_store_inventory_log", producatstorelog.toJson());
            print(result);
          } else {
            var result = await db.update(
                "product_store_inventory_log", producatstorelog.toJson(),
                where: "il_id =?", whereArgs: [producatstorelog.il_id]);
            print(result);
          }
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
          var data = {
            'table': "price_type",
            'key': "pt_id",
            'value': priceType.ptId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert("price_type", priceType.toJson());
            print(result);
          } else {
            var result = await db.update("price_type", priceType.toJson(),
                where: "pt_id =?", whereArgs: [priceType.ptId]);
            print(result);
          }
        }
      }
      if (printerData.length != 0) {
        for (var i = 0; i < printerData.length; i++) {
          var printerDataitem = printerData[i];
          Printer printer = Printer.fromJson(printerDataitem);
          var data = {
            'table': "printer",
            'key': "printer_id",
            'value': printer.printerId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert("printer", printer.toJson());
            print(result);
          } else {
            var result = await db.update("printer", printer.toJson(),
                where: "printer_id =?", whereArgs: [printer.printerId]);
            print(result);
          }
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
          var data = {
            'table': "customer",
            'key': "customer_id",
            'value': customer.customerId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert("customer", customer.toJson());
            print(result);
          } else {
            var result = await db.update("customer", customer.toJson(),
                where: "customer_id =?", whereArgs: [customer.customerId]);
            print(result);
          }
        }
      }

      if (terminalData != null) {
        var terminalDataitem = terminalData;
        Terminal terminal = Terminal.fromJson(terminalDataitem);
        var data = {
          'table': "terminal",
          'key': "terminal_id",
          'value': terminal.terminalId,
        };
        var count = await ifExists(db, data);
        if (count == 0) {
          var result = await db.insert("terminal", terminal.toJson());
          print(result);
        } else {
          var result = await db.update("terminal", terminal.toJson(),
              where: "terminal_id =?", whereArgs: [terminal.terminalId]);
          print(result);
        }
      }
      if (tableData.length != 0) {
        for (var i = 0; i < tableData.length; i++) {
          var tableDataitem = tableData[i];
          Tables table = Tables.fromJson(tableDataitem);
          var data = {
            'table': "tables",
            'key': "table_id",
            'value': table.tableId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert("tables", table.toJson());
            print(result);
          } else {
            var result = await db.update("tables", table.toJson(),
                where: "table_id", whereArgs: [table.tableId]);
            print(result);
          }
        }
      }
      if (paymentData.length != 0) {
        // TODO : need resaponce
        for (var i = 0; i < paymentData.length; i++) {
          var paymentDataitem = paymentData[i];
          Payments payments = Payments.fromJson(paymentDataitem);
          var data = {
            'table': "payment",
            'key': "payment_id",
            'value': payments.paymentId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert("payment", payments.toJson());
            print(result);
          } else {
            var result = await db.update("payment", payments.toJson(),
                where: "payment_id =?", whereArgs: [payments.paymentId]);
            print(result);
          }
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
    var orders = tablesData["order"];
    var orderdetail = tablesData["order_detail"];
    try {
      if (voucherData.length != 0) {
        for (var i = 0; i < voucherData.length; i++) {
          var voucherDataitem = voucherData[i];
          Voucher vouchers = Voucher.fromJson(voucherDataitem);
          var data = {
            'table': "voucher",
            'key': "voucher_id",
            'value': vouchers.voucherId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert("voucher", vouchers.toJson());
            print(result);
          } else {
            var result = await db.update("voucher", vouchers.toJson());
            print(result);
          }
        }
      }
      if (orders.length != 0) {
        for (var i = 0; i < orders.length; i++) {
          var ordersitem = orders[i];
          Orders order = Orders.fromJson(ordersitem);
          var data = {
            'table': "orders",
            'key': "order_id",
            'value': order.order_id,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert("orders", order.toJson());
            print(result);
          } else {
            var result = await db.update("orders", order.toJson());
            print(result);
          }
        }
      }
      if (orderdetail.length != 0) {
        for (var i = 0; i < orderdetail.length; i++) {
          var orderdetailitem = orderdetail[i];
          OrderDetail orderdeta = OrderDetail.fromJson(orderdetailitem);
          var data = {
            'table': "order_detail",
            'key': "detail_id",
            'value': orderdeta.detailId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert("order_detail", orderdeta.toJson());
            print(result);
          } else {
            var result = await db.update("order_detail", orderdeta.toJson());
            print(result);
          }
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
          var data = {
            'table': "shift",
            'key': "shift_id",
            'value': shift.shiftId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert("shift", shift.toJson());
            print(result);
          } else {
            var result = await db.update("shift", shift.toJson());
            print(result);
          }
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
          var data = {
            'table': "asset",
            'key': "asset_id",
            'value': accet.assetId,
          };
          var count = await ifExists(db, data);
          if (count == 0) {
            var result = await db.insert("asset", accet.toJson());
            print(result);
          } else {
            var result = await db.update("asset", accet.toJson());
            print(result);
          }
        }
      }
      return 1;
    } catch (e) {
      print(e);
      return 0;
    }
  }
}
