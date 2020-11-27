import 'dart:convert';

import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/helpers/ComunAPIcall.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Attribute_data.dart';
import 'package:mcncashier/models/Box.dart';
import 'package:mcncashier/models/BranchTax.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/ModifireData.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/Printer.dart';
import 'package:mcncashier/models/Rac.dart';
import 'package:mcncashier/models/SetMeal.dart';
import 'package:mcncashier/models/SetMealProduct.dart';
import 'package:mcncashier/models/mst_sub_cart_details.dart';
import 'package:mcncashier/services/allTablesSync.dart';

class ProductsList {
  var db = DatabaseHelper.dbHelper.getDatabse();
  Future<List<ProductDetails>> getProduct(context, catid, branchID) async {
    List<ProductDetails> list = [];
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.products;
      var stringParams = {"branch_id": branchID, "category_id": catid};
      var result = await APICall.localapiCall(context, apiurl, stringParams);
      if (result != null && result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => ProductDetails.fromJson(c)).toList()
            : [];
      }
    } else {
      var query = "SELECT product.*,price_type.name as price_type_Name,asset.base64,product_store_inventory.qty,category_attribute.name as attr_cat ,modifier.name as modifire_Name FROM `product` " +
          " LEFT JOIN product_category on product_category.product_id = product.product_id AND product_category.status = 1" +
          " LEFT JOIN product_branch on product_branch.product_id = product.product_id AND product_branch.status = 1" +
          " LEFT JOIN price_type on price_type.pt_id = product.price_type_id AND price_type.status = 1 " +
          " LEFT JOIN asset on asset.asset_type = 1 AND asset.asset_type_id = product.product_id AND asset.status = 1" +
          " LEFT JOIN product_attribute on product_attribute.product_id = product.product_id and product_attribute.status = 1" +
          " LEFT JOIN category_attribute on category_attribute.ca_id = product_attribute.ca_id and category_attribute.status = 1" +
          " LEFT JOIN attributes on attributes.attribute_id = product_attribute.attribute_id and attributes.status = 1" +
          " LEFT JOIN product_modifier on  product_modifier.product_id = product.product_id AND product_modifier.status = 1 " +
          " LEFT JOIN modifier on modifier.modifier_id = product_modifier.modifier_id AND modifier.status = 1 " +
          " LEFT JOIN product_store_inventory  ON  product_store_inventory.product_id = product.product_id and product_store_inventory.status = 1 " +
          " where product_category.category_id = " +
          catid.toString() +
          " AND product_branch.branch_id = " +
          branchID.toString() +
          " AND product.status = 1 AND product.has_setmeal = 0 GROUP By product.product_id";
      List<Map> res = await db.rawQuery(query);
      list = res.length > 0
          ? res.map((c) => ProductDetails.fromJson(c)).toList()
          : [];
      await SyncAPICalls.logActivity(
          "Product", "geting Product List", "product", catid);
    }

    return list;
  }

  Future<List<ProductDetails>> getSeachProduct(
      context, String searchText) async {
    List<ProductDetails> list = [];
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.search_product;
      var stringParams = {"search_text": searchText};
      var result = await APICall.localapiCall(context, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => ProductDetails.fromJson(c)).toList()
            : [];
      }
    } else {
      var query = "SELECT product.*,base64 ,product_store_inventory.qty, price_type.name as price_type_Name FROM `product` " +
          " LEFT join price_type on price_type.pt_id = product.price_type_id AND price_type.status = 1 " +
          " LEFT join asset on asset.asset_type = 1 AND asset.asset_type_id = product.product_id " +
          " LEFT join product_store_inventory  ON  product_store_inventory.product_id = product.product_id and product_store_inventory.status = 1 " +
          " where product.status = 1 AND product.has_setmeal = 0 AND " +
          " (product.name LIKE '%$searchText%' OR product.sku LIKE '%$searchText%')" +
          " GROUP By product.product_id";
      List<Map> res =
          await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
      list = res.isNotEmpty
          ? res.map((c) => ProductDetails.fromJson(c)).toList()
          : [];
      await SyncAPICalls.logActivity(
          "Product", "geting search Product List", "product", "1");
    }
    return list;
  }

  Future<List<SetMeal>> getSearchSetMealsData(
      String searchText, String branchid) async {
    List<SetMeal> list = [];
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.search_setmeal;
      var stringParams = {"search_text": searchText, "branch_id": branchid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => SetMeal.fromJson(c)).toList()
            : [];
      }
    } else {
      var qry = "select setmeal.* ,base64  from setmeal " +
          " LEFT join setmeal_branch on setmeal_branch_id =" +
          branchid +
          " AND setmeal_branch.setmeal_id = setmeal.setmeal_id " +
          " LEFT join setmeal_product on setmeal_product.setmeal_id = setmeal.setmeal_id " +
          " LEFT join asset on asset.asset_type = 2 AND asset.asset_type_id = setmeal.setmeal_id  " +
          " where setmeal.name LIKE '%$searchText%'" +
          "GROUP by setmeal.setmeal_id ";
      var mealList = await db.rawQuery(qry);
      list = mealList.isNotEmpty
          ? mealList.map((c) => SetMeal.fromJson(c)).toList()
          : [];
      await SyncAPICalls.logActivity(
          "Meals List", "get Meals List", "setmeal", branchid);
    }
    return list;
  }

  Future<List<Attribute_Data>> getProductAttributes(productid) async {
    List<Attribute_Data> list = [];
    if (productid != null) {
      var qry = "SELECT product.product_id, category_attribute.name as attr_name,attributes.ca_id, " +
          " group_concat(product_attribute.price) as attr_types_price,group_concat(attributes.name) as attr_types ,group_concat(attributes.attribute_id) as attributeId" +
          " FROM product LEFT JOIN product_attribute on product_attribute.product_id = product.product_id and product_attribute.status = 1" +
          " LEFT JOIN category_attribute on category_attribute.ca_id = product_attribute.ca_id and category_attribute.status = 1" +
          " LEFT JOIN attributes on attributes.attribute_id = product_attribute.attribute_id and attributes.status = 1 " +
          " WHERE product.product_id = " +
          productid.toString() +
          " AND product_attribute.product_id = " +
          productid.toString() +
          " GROUP by category_attribute.ca_id";
      List<Map> res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
      list = res.length > 0
          ? res.map((c) => Attribute_Data.fromJson(c)).toList()
          : [];
      await SyncAPICalls.logActivity(
          "Product", "Getting Product details", "product", productid);
    }
    return list;
  }

  Future<List<ModifireData>> getProductModifiers(productid) async {
    List<ModifireData> list = [];
    if (productid != null) {
      var qry =
          "SELECT modifier.name,modifier.modifier_id,modifier.is_default,product_modifier.pm_id,product_modifier.price FROM  product_modifier " +
              " LEFT JOIN modifier on modifier.modifier_id = product_modifier.modifier_id " +
              " WHERE product_modifier.product_id = " +
              productid.toString() +
              " AND product_modifier.status = 1" +
              " GROUP by product_modifier.pm_id";
      List<Map> res = await db.rawQuery(qry);
      list = res.isNotEmpty
          ? res.map((c) => ModifireData.fromJson(c)).toList()
          : [];
      await SyncAPICalls.logActivity(
          "Product", "Getting Product modifire", "modifier", productid);
    }
    return list;
  }

  Future<List<SetMeal>> getMealsData(branchid) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    List<SetMeal> list = [];
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.set_meals;
      var stringParams = {"branch_id": branchid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => SetMeal.fromJson(c)).toList()
            : [];
      }
    } else {
      var qry = "select setmeal.* ,  base64  from setmeal " +
          " LEFT join setmeal_branch on setmeal_branch_id =" +
          branchid +
          " AND setmeal_branch.setmeal_id = setmeal.setmeal_id " +
          " LEFT join setmeal_product on setmeal_product.setmeal_id = setmeal.setmeal_id " +
          " LEFT join asset on asset.asset_type = 2 AND asset.asset_type_id = setmeal.setmeal_id where setmeal.status = 1  GROUP by setmeal.setmeal_id ";
      var mealList = await db.rawQuery(qry);
      list = mealList.isNotEmpty
          ? mealList.map((c) => SetMeal.fromJson(c)).toList()
          : [];
      await SyncAPICalls.logActivity(
          "Meals List", "get Meals List", "setmeal", branchid);
    }
    return list;
  }

  Future<List<SetMealProduct>> getMealsProductData(setmealid) async {
    List<SetMealProduct> list = [];
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.set_meals_products;
      var stringParams = {"setmeal_Id": setmealid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => SetMealProduct.fromJson(c)).toList()
            : [];
      }
    } else {
      if (setmealid != null) {
        var qry = "SELECT setmeal_product.*,replace(asset.base64,'data:image/jpg;base64,','') as base64,product.name  FROM setmeal_product " +
            " LEFT JOIN product ON product.product_id = setmeal_product.product_id AND product.status = 1 " +
            " LEFT join asset on asset.asset_type = 1 AND asset.asset_type_id = setmeal_product.product_id AND asset.status = 1 " +
            " WHERE setmeal_product.setmeal_id = " +
            setmealid.toString() +
            " AND setmeal_product.status = 1 " +
            " GROUP by setmeal_product.setmeal_product_id";
        var mealList = await db.rawQuery(qry);
        list = mealList.isNotEmpty
            ? mealList.map((c) => SetMealProduct.fromJson(c)).toList()
            : [];
        for (var i = 0; i < list.length; i++) {
          var attrQry = "SELECT product.product_id, category_attribute.name as attr_name,attributes.ca_id, " +
              " group_concat(product_attribute.price) as attr_types_price,group_concat(attributes.name) as attr_types ,group_concat(attributes.attribute_id) as attributeId " +
              " FROM product LEFT JOIN product_attribute on product_attribute.product_id = product.product_id and product_attribute.status = 1 " +
              " LEFT JOIN category_attribute on category_attribute.ca_id = product_attribute.ca_id and category_attribute.status = 1 " +
              " LEFT JOIN attributes on attributes.attribute_id = product_attribute.attribute_id and attributes.status = 1 " +
              " WHERE product.product_id =  " +
              list[i].productId.toString() +
              " GROUP by category_attribute.ca_id";
          List<Map> res = await db.rawQuery(attrQry);
          List<Attribute_Data> attrlist = res.length > 0
              ? res.map((c) => Attribute_Data.fromJson(c)).toList()
              : [];
          if (attrlist.length > 0) {
            list[i].attributeDetails = jsonEncode(attrlist);
          }
        }
        await SyncAPICalls.logActivity("Meals product List",
            "get Meals product List", "setmeal", setmealid);
      }
    }
    return list;
  }

  Future<List<BranchTax>> getTaxList(branchid) async {
    List<BranchTax> list = [];
    var tax = await db.rawQuery(
        "SELECT branch_tax.*,tax.code From branch_tax " +
            " Left join tax on tax.tax_id = branch_tax.tax_id " +
            " WHERE branch_tax.status = 1 AND branch_id =" +
            branchid.toString());
    list = tax.isNotEmpty ? tax.map((c) => BranchTax.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<Printer>> getPrinterList(productID) async {
    List<Printer> list = [];
    if (productID != null) {
      var qry =
          "SELECT * from printer where printer.printer_id = (Select printer_id from product_branch WHERE product_branch.product_id = $productID)";
      var result = await db.rawQuery(qry);
      list = result.isNotEmpty
          ? result.map((c) => Printer.fromJson(c)).toList()
          : [];
      await SyncAPICalls.logActivity("Product",
          "get printer for add in cart product", "Printer", productID);
    }
    return list;
  }

  Future<List<MSTSubCartdetails>> getCartItemSubDetails(cartDetailsId) async {
    List<MSTSubCartdetails> list = [];
    if (cartDetailsId != null) {
      var cartDetail = await db.query("mst_cart_sub_detail",
          where: 'cart_details_id = ?', whereArgs: [cartDetailsId]);
      list = cartDetail.isNotEmpty
          ? cartDetail.map((c) => MSTSubCartdetails.fromJson(c)).toList()
          : [];
      await SyncAPICalls.logActivity(
          "edit cart item",
          "get modifire list mst_cart_sub_detail",
          "mst_cart_sub_detail",
          cartDetailsId);
    }
    return list;
  }

  Future<List<MST_Cart>> getCurrCartTotals(cartID) async {
    List<MST_Cart> list = [];
    if (cartID != null) {
      var query = "SELECT * from mst_cart where id = " + cartID.toString();
      var res = await db.rawQuery(query);
      list =
          res.length > 0 ? res.map((c) => MST_Cart.fromJson(c)).toList() : [];
      await SyncAPICalls.logActivity("product", "get cart data", "mst_cart", 1);
    }
    return list;
  }

  Future<List<MSTCartdetails>> getCartItems(cartId) async {
    List<MSTCartdetails> list = [];
    if (cartId != null) {
      var qry =
          "SELECT * from mst_cart_detail where cart_id = " + cartId.toString();
      var res = await db.rawQuery(qry);
      list = res.isNotEmpty
          ? res.map((c) => MSTCartdetails.fromJson(c)).toList()
          : [];
      await SyncAPICalls.logActivity(
          "product", "get cart list", "mst_cart_detail", cartId);
    }
    return list;
  }

  Future<dynamic> getProductDetails(
      branchid, productid, setmealid, cartdetailid, cartID) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.product_details;
      var stringParams = {
        "product_id": productid,
        "setmeal_id": setmealid,
        "branch_id": branchid,
        "cart_details_id": cartdetailid,
        "cartID": cartID
      };
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      return result;
    } else {
      // product attributes

      List<Attribute_Data> productAttr = await getProductAttributes(productid);
      List<ModifireData> productModifire = await getProductModifiers(productid);
      List<SetMealProduct> setmealProducts =
          await getMealsProductData(setmealid);
      List<BranchTax> branchtaxList = await getTaxList(branchid);
      List<Printer> printerList = await getPrinterList(productid);
      List<MST_Cart> currentCart = await getCurrCartTotals(cartID);
      List<MSTCartdetails> cartItemsList = await getCartItems(cartID);
      List<MSTSubCartdetails> cartItemSub =
          await getCartItemSubDetails(cartdetailid);

      dynamic productDetais = {
        "Attributes": productAttr,
        "Modifire": productModifire,
        "SetMealsProduct": setmealProducts,
        "BranchTax": branchtaxList,
        "PrinterList": printerList,
        "CartTotals": currentCart,
        "CartItems": cartItemsList,
        "CartSubItems": cartItemSub
      };
      return productDetais;
    }
  }

  Future<List<ProductDetails>> productdData(productid) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    List<ProductDetails> list = new List<ProductDetails>();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.productData;
      var stringParams = {
        "product_id": productid,
      };
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => ProductDetails.fromJson(c)).toList()
            : [];
      }
    } else {
      var qry =
          " SELECT product.*, price_type.name as price_type_Name , base64   from product " +
              " LEFT join price_type on price_type.pt_id = product.price_type_id AND price_type.status = 1 " +
              " LEFT join asset on asset.asset_type_id = product.product_id " +
              " where product_id = " +
              productid.toString();
      var res = await db.rawQuery(qry);
      list = res.length > 0
          ? res.map((c) => ProductDetails.fromJson(c)).toList()
          : [];
    }
    return list;
  }

  Future<List<SetMeal>> setmealData(mealid) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    List<SetMeal> list = new List<SetMeal>();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.setmealData;
      var stringParams = {
        "setmeal_id": mealid,
      };
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => SetMeal.fromJson(c)).toList()
            : [];
      }
    } else {
      var qry = "select setmeal.* ,  base64  from setmeal " +
          " LEFT join setmeal_product on setmeal_product.setmeal_id = setmeal.setmeal_id " +
          " LEFT join asset on asset.asset_type = 2 AND asset.asset_type_id = setmeal.setmeal_id " +
          " WHERE setmeal.setmeal_id = " +
          mealid.toString() +
          " AND setmeal.status = 1 GROUP by setmeal.setmeal_id ";
      var mealList = await db.rawQuery(qry);
      list = mealList.isNotEmpty
          ? mealList.map((c) => SetMeal.fromJson(c)).toList()
          : [];
      await SyncAPICalls.logActivity(
          "Meals List", "get Meals List", "setmeal", mealid);
    }
    return list;
  }

  Future<List<Rac>> getRacList(branchID) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    List<Rac> list = new List<Rac>();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.rac_data;
      var stringParams = {
        "branch_id": branchID,
      };
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0 ? data.map((c) => Rac.fromJson(c)).toList() : [];
      }
    } else {
      var qry = "SELECT * from rac where branch_id = " +
          branchID.toString() +
          " AND status = 1";
      var result = await db.rawQuery(qry);
      list =
          result.length > 0 ? result.map((c) => Rac.fromJson(c)).toList() : [];
    }
    return list;
  }

  Future<List<Box>> getBoxList(branchID, racID) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    List<Box> list = new List<Box>();
    if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.box_list;
      var stringParams = {"branch_id": branchID, "rac_id": racID};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0 ? data.map((c) => Box.fromJson(c)).toList() : [];
      }
    } else {
      var qry = "SELECT * from box where branch_id = " +
          branchID.toString() +
          " AND rac_id = " +
          racID.toString() +
          "  AND status = 1";
      var result = await db.rawQuery(qry);
      list =
          result.length > 0 ? result.map((c) => Box.fromJson(c)).toList() : [];
    }
    return list;
  }
}
