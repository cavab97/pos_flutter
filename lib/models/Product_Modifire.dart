class ProductModifier {
  int pmId;
  String uuid;
  int productId;
  int modifierId;
  double price;
  int status;
  String updatedAt;
  int updatedBy;

  ProductModifier(
      {this.pmId,
      this.uuid,
      this.productId,
      this.modifierId,
      this.price,
      this.status,
      this.updatedAt,
      this.updatedBy});

  ProductModifier.fromJson(Map<String, dynamic> json) {
    pmId = json['pm_id'];
    uuid = json['uuid'];
    productId = json['product_id'];
    modifierId = json['modifier_id'];
    price = json['price'] is int
        ? (json['price'] as int).toDouble()
        : json['price'];
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pm_id'] = this.pmId;
    data['uuid'] = this.uuid;
    data['product_id'] = this.productId;
    data['modifier_id'] = this.modifierId;
    data['price'] = this.price;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}
