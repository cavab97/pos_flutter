class SetMealProduct {
  int setmealProductId;
  int setmealId;
  int productId;
  double qty;
  int status;
  String createdAt;
  String updatedAt;
  String base64;
  String name;
  String attributeDetails;

  SetMealProduct({
    this.setmealProductId,
    this.setmealId,
    this.productId,
    this.qty,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.base64,
    this.name,
    this.attributeDetails,
  });

  SetMealProduct.fromJson(Map<String, dynamic> json) {
    setmealProductId = json['setmeal_product_id'];
    setmealId = json['setmeal_id'];
    productId = json['product_id'];
    qty = json['quantity'] is int
        ? (json['quantity'] as int).toDouble()
        : json["quantity"];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    base64 = json['base64'] != null ? json['base64'] : "";
    name = json['name'];
    attributeDetails = json["attribute_details"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['setmeal_product_id'] = this.setmealProductId;
    data['setmeal_id'] = this.setmealId;
    data['product_id'] = this.productId;
    data['quantity'] = this.qty;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['name'] = this.name;
    data['base64'] = this.base64;
    data['name'] = this.name;
    data["attributeDetails"] = this.attributeDetails;
    return data;
  }
}
