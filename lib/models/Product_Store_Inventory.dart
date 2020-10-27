class ProductStoreInventory {
  int inventoryId;
  String uuid;
  int productId;
  int branchId;
  double qty;
  int warningStockLevel;
  int status;
  int serverid;
  String updatedAt;
  int updatedBy;

  ProductStoreInventory(
      {this.inventoryId,
      this.uuid,
      this.productId,
      this.branchId,
      this.qty,
      this.warningStockLevel,
      this.status,
      this.serverid,
      this.updatedAt,
      this.updatedBy});

  ProductStoreInventory.fromJson(Map<String, dynamic> json) {
    inventoryId = json['inventory_id'];
    uuid = json['uuid'];
    productId = json['product_id'];
    branchId = json['branch_id'];
    qty = json['qty'] is int ? (json['qty'] as int).toDouble() : json['qty'];
    warningStockLevel = json['warningStockLevel'];
    status = json['status'];
    serverid = json["server_id"];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['inventory_id'] = this.inventoryId;
    data['uuid'] = this.uuid;
    data['product_id'] = this.productId;
    data['branch_id'] = this.branchId;
    data['qty'] = this.qty;
    data["server_id"] = this.serverid;
    data['warningStockLevel'] = this.warningStockLevel;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}
