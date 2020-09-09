class ProductBranch {
  int pbId;
  String uuid;
  int productId;
  int branchId;
  int displayOrder;
  int warningStockLevel;
  int status;
  String updatedAt;
  int updatedBy;

  ProductBranch(
      {this.pbId,
      this.uuid,
      this.productId,
      this.branchId,
      this.displayOrder,
      this.warningStockLevel,
      this.status,
      this.updatedAt,
      this.updatedBy});

  ProductBranch.fromJson(Map<String, dynamic> json) {
    pbId = json['pb_id'];
    uuid = json['uuid'];
    productId = json['product_id'];
    branchId = json['branch_id'];
    displayOrder = json['display_order'];
    warningStockLevel =
        json["warningStockLevel"] != null ? json["warningStockLevel"] : 0;
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pb_id'] = this.pbId;
    data['uuid'] = this.uuid;
    data['product_id'] = this.productId;
    data['branch_id'] = this.branchId;
    data['warningStockLevel'] = this.warningStockLevel;
    data['display_order'] = this.displayOrder;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}
