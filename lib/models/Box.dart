class Box {
  int boxId;
  String uuid;
  int branchId;
  int racId;
  int productId;
  String name;
  String slug;
  int boxFor;
  double wineQty;
  int boxLimit;
  int status;
  String updatedAt;
  int updatedBy;

  Box(
      {this.boxId,
      this.uuid,
      this.branchId,
      this.racId,
      this.productId,
      this.name,
      this.slug,
      this.boxFor,
      this.wineQty,
      this.boxLimit,
      this.status,
      this.updatedAt,
      this.updatedBy});

  Box.fromJson(Map<String, dynamic> json) {
    boxId = json['box_id'];
    uuid = json['uuid'];
    branchId = json['branch_id'];
    racId = json['rac_id'];
    productId = json['product_id'];
    name = json['name'];
    slug = json['slug'];
    boxFor = json['box_for'];
    wineQty = json['wine_qty'] is int
        ? (json['wine_qty'] as int).toDouble()
        : json['wine_qty'];
    boxLimit = json['box_limit'];
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['box_id'] = this.boxId;
    data['uuid'] = this.uuid;
    data['branch_id'] = this.branchId;
    data['rac_id'] = this.racId;
    data['product_id'] = this.productId;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['box_for'] = this.boxFor;
    data['wine_qty'] = this.wineQty;
    data['box_limit'] = this.boxLimit;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}
