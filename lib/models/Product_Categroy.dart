class ProductCategory {
  int pcId;
  int productId;
  int categoryId;
  int branchId;
  int displayOrder;
  int status;
  String updatedAt;
  int updatedBy;

  ProductCategory(
      {this.pcId,
      this.productId,
      this.categoryId,
      this.branchId,
      this.displayOrder,
      this.status,
      this.updatedAt,
      this.updatedBy});

  ProductCategory.fromJson(Map<String, dynamic> json) {
    pcId = json['pc_id'];
    productId = json['product_id'];
    categoryId = json['category_id'];
    branchId = json['branch_id'];
    displayOrder = json['display_order'];
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pc_id'] = this.pcId;
    data['product_id'] = this.productId;
    data['category_id'] = this.categoryId;
    data['branch_id'] = this.branchId;
    data['display_order'] = this.displayOrder;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}
