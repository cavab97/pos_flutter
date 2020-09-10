class CategroyBranch {
  int cbId;
  String uuid;
  int categoryId;
  int branchId;
  int displayOrder;
  int status;
  String updatedAt;
  int updatedBy;

  CategroyBranch(
      {this.cbId,
      this.uuid,
      this.categoryId,
      this.branchId,
      this.displayOrder,
      this.status,
      this.updatedAt,
      this.updatedBy});

  CategroyBranch.fromJson(Map<String, dynamic> json) {
    cbId = json['cb_id'];
    uuid = json['uuid'];
    categoryId = json['category_id'];
    branchId = json['branch_id'];
    displayOrder = json['display_order'];
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cb_id'] = this.cbId;
    data['uuid'] = this.uuid;
    data['category_id'] = this.categoryId;
    data['branch_id'] = this.branchId;
    data['display_order'] = this.displayOrder;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}
