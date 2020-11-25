// ignore: camel_case_types
class Customer_Liquor_Inventory_Log {
  int liId;
  int appId;
  int serverId;
  String uuid;
  int clId;
  int clAppId;
  int branchId;
  int productId;
  int customerId;
  int liType;
  double qty;
  double qtyBeforeChange;
  double qtyAfterChange;
  String updatedAt;
  int updatedBy;

  Customer_Liquor_Inventory_Log(
      {this.liId,
      this.appId,
      this.clAppId,
      this.serverId,
      this.uuid,
      this.clId,
      this.branchId,
      this.productId,
      this.customerId,
      this.liType,
      this.qty,
      this.qtyBeforeChange,
      this.qtyAfterChange,
      this.updatedAt,
      this.updatedBy});

  Customer_Liquor_Inventory_Log.fromJson(Map<String, dynamic> json) {
    liId = json['li_id'];
    appId = json["app_id"];
    clAppId = json["cl_appId"];
    serverId = json["server_id"];
    uuid = json['uuid'];
    clId = json['cl_id'];
    branchId = json['branch_id'];
    productId = json['product_id'];
    customerId = json['customer_id'];
    liType = json['li_type'];
    qty = json['qty'] is int ? (json['qty'] as int).toDouble() : json['qty'];
    qtyBeforeChange = json['qty_before_change'] is int
        ? (json['qty_before_change'] as int).toDouble()
        : json['qty_before_change'];
    qtyAfterChange = json['qty_after_change'] is int
        ? (json['qty_after_change'] as int).toDouble()
        : json['qty_after_change'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['li_id'] = this.liId;
    data["app_id"] = this.appId;
    data["cl_appId"] = this.clAppId;
    data["server_id"] = this.serverId;
    data['uuid'] = this.uuid;
    data['cl_id'] = this.clId;
    data['branch_id'] = this.branchId;
    data['product_id'] = this.productId;
    data['customer_id'] = this.customerId;
    data['li_type'] = this.liType;
    data['qty'] = this.qty;
    data['qty_before_change'] = this.qtyBeforeChange;
    data['qty_after_change'] = this.qtyAfterChange;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}
