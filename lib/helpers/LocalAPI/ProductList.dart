import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/helpers/ComunAPIcall.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Attribute_data.dart';
import 'package:mcncashier/models/ModifireData.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/SetMeal.dart';
import 'package:mcncashier/models/SetMealProduct.dart';
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
      var query = "SELECT product.*,replace(asset.base64,'data:image/jpg;base64,','') as base64, price_type.name as price_type_Name FROM `product` " +
          " LEFT join product_category on product_category.product_id = product.product_id " +
          " LEFT join product_branch on product_branch.product_id = product.product_id " +
          " LEFT join price_type on price_type.pt_id = product.price_type_id AND price_type.status = 1 " +
          " LEFT join asset on asset.asset_type = 1 AND asset.asset_type_id = product.product_id " +
          " where product_category.category_id = " +
          catid.toString() +
          " AND product_branch.branch_id = " +
          branchID.toString() +
          " AND product.status = 1 GROUP By product.product_id";
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
      var query = "SELECT product.*,replace(asset.base64,'data:image/jpg;base64,','') as base64 , price_type.name as price_type_Name FROM `product` " +
          " LEFT join price_type on price_type.pt_id = product.price_type_id AND price_type.status = 1 " +
          " LEFT join asset on asset.asset_type = 1 AND asset.asset_type_id = product.product_id " +
          " where product.name LIKE '%$searchText%' OR product.sku LIKE '%$searchText%'" +
          " AND product.status = 1" +
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
      var qry = "select setmeal.* , replace(asset.base64,'data:image/jpg;base64,','') as base64  from setmeal " +
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

  Future<List<Attribute_Data>> getProductAttributes(context, productid) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    List<Attribute_Data> list = [];
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.product_attributes;
      var stringParams = {"product_id": productid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => Attribute_Data.fromJson(c)).toList()
            : [];
      }
    } else {
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

  Future<List<ModifireData>> getProductModifiers(context, productid) async {
    var isjoin = await CommunFun.checkIsJoinServer();
    List<ModifireData> list = [];
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.product_Modifeirs;
      var stringParams = {"product_id": productid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => ModifireData.fromJson(c)).toList()
            : [];
      }
    } else {
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
      var qry = "select setmeal.* , replace(asset.base64,'data:image/jpg;base64,','') as base64  from setmeal " +
          " LEFT join setmeal_branch on setmeal_branch_id =" +
          branchid +
          " AND setmeal_branch.setmeal_id = setmeal.setmeal_id " +
          " LEFT join setmeal_product on setmeal_product.setmeal_id = setmeal.setmeal_id " +
          " LEFT join asset on asset.asset_type = 2 AND asset.asset_type_id = setmeal.setmeal_id  GROUP by setmeal.setmeal_id ";
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
    var isjoin = await CommunFun.checkIsJoinServer();
    List<SetMealProduct> list = [];
    if (isjoin == true) {
      var apiurl =
          await Configrations.ipAddress() + Configrations.set_meals_products;
      var stringParams = {"setmeal_id": setmealid};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => SetMealProduct.fromJson(c)).toList()
            : [];
      }
    } else {
      var qry = "SELECT setmeal_product.*,replace(asset.base64,'data:image/jpg;base64,','') as base64,product.name  FROM setmeal_product " +
          " LEFT JOIN product ON product.product_id = setmeal_product.product_id " +
          " LEFT join asset on asset.asset_type = 1 AND asset.asset_type_id = setmeal_product.product_id " +
          " WHERE setmeal_product.setmeal_id = " +
          setmealid.toString() +
          " GROUP by setmeal_product.setmeal_product_id";

      var mealList = await db.rawQuery(qry);
      list = mealList.isNotEmpty
          ? mealList.map((c) => SetMealProduct.fromJson(c)).toList()
          : [];
      await SyncAPICalls.logActivity(
          "Meals product List", "get Meals product List", "setmeal", setmealid);
    }
    return list;
  }
}
