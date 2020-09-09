class ProductStoreInventory {
  int inventoryId;
  String uuid;
  int productId;
  int branchId;
  String qty;
  int status;
  String updatedAt;
  int updatedBy;

  ProductStoreInventory(
      {this.inventoryId,
      this.uuid,
      this.productId,
      this.branchId,
      this.qty,
      this.status,
      this.updatedAt,
      this.updatedBy});

  ProductStoreInventory.fromJson(Map<String, dynamic> json) {
    inventoryId = json['inventory_id'];
    uuid = json['uuid'];
    productId = json['product_id'];
    branchId = json['branch_id'];
    qty = json['qty'];
    status = json['status'];
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

    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}
