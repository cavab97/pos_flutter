// ignore: camel_case_types
class Customer_Liquor_Inventory {
  int clId;
  String uuid;
  int appId;
  int serverId;
  int clCustomerId;
  int clProductId;
  int clBranchId;
  int clRacId;
  int clBoxId;
  int type;
  double clTotalQuantity;
  String clExpiredOn;
  double clLeftQuantity;
  int status;
  String updatedAt;
  int updatedBy;
  String name;

  Customer_Liquor_Inventory({
    this.clId,
    this.appId,
    this.serverId,
    this.uuid,
    this.clCustomerId,
    this.clProductId,
    this.clBranchId,
    this.clRacId,
    this.clBoxId,
    this.type,
    this.clTotalQuantity,
    this.clExpiredOn,
    this.clLeftQuantity,
    this.status,
    this.updatedAt,
    this.updatedBy,
    this.name,
  });

  Customer_Liquor_Inventory.fromJson(Map<String, dynamic> json) {
    clId = json['cl_id'];
    uuid = json['uuid'];
    appId = json['app_id'];
    serverId = json['server_id'];
    clCustomerId = json['cl_customer_id'];
    clProductId = json['cl_product_id'];
    clBranchId = json['cl_branch_id'];
    clRacId = json['cl_rac_id'];
    clBoxId = json['cl_box_id'];
    type = json['type'];
    clTotalQuantity = json['cl_total_quantity'] is int
        ? (json['cl_total_quantity'] as int).toDouble()
        : json['cl_total_quantity'];
    clExpiredOn = json['cl_expired_on'];
    clLeftQuantity = json['cl_left_quantity'] is int
        ? (json['cl_left_quantity'] as int).toDouble()
        : json['cl_left_quantity'];
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    name = json["name"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cl_id'] = this.clId;
    data['uuid'] = this.uuid;
    data["app_id"] = this.appId;
    data["server_id"] = this.serverId;
    data['cl_customer_id'] = this.clCustomerId;
    data['cl_product_id'] = this.clProductId;
    data['cl_branch_id'] = this.clBranchId;
    data['cl_rac_id'] = this.clRacId;
    data['cl_box_id'] = this.clBoxId;
    data['type'] = this.type;
    data['cl_total_quantity'] = this.clTotalQuantity;
    data['cl_expired_on'] = this.clExpiredOn;
    data['cl_left_quantity'] = this.clLeftQuantity;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    data["name"] = this.name;
    return data;
  }
}
