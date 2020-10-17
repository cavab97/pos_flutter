import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/helpers/ComunAPIcall.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/services/allTablesSync.dart';

class ProductsList {
  var db = DatabaseHelper.dbHelper.getDatabse();
  Future<List<ProductDetails>> getProduct(
      context, String catid, String branchID) async {
    List<ProductDetails> list = [];
    var isjoin = await CommunFun.checkIsJoinServer();
    if (isjoin == true) {
      var apiurl = "http://192.168.1.115/" + Configrations.products;
      var stringParams = {"branch_id": branchID, "category_id": catid};
      var result = await APICall.localapiCall(context, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        list = result["data"];
      }
    } else {
      var query = "SELECT product.*,replace(asset.base64,'data:image/jpg;base64,','') as base64, price_type.name as price_type_Name FROM `product` " +
          " LEFT join product_category on product_category.product_id = product.product_id " +
          " LEFT join product_branch on product_branch.product_id = product.product_id " +
          " LEFT join price_type on price_type.pt_id = product.price_type_id AND price_type.status = 1 " +
          " LEFT join asset on asset.asset_type = 1 AND asset.asset_type_id = product.product_id " +
          " where product_category.category_id = " +
          catid +
          " AND product_branch.branch_id = " +
          branchID +
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
      var apiurl = "http://192.168.1.115/" + Configrations.search_product;
      var stringParams = {"search_text": searchText};
      var result = await APICall.localapiCall(context, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        list = result["data"];
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
}
