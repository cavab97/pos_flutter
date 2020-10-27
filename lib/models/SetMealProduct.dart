class SetMealProduct {
  int setmealProductId;
  int setmealId;
  int productId;
  double quantity;
  int status;
  String createdAt;
  String updatedAt;
  String base64;
  String name;
  String cateAtt;
  String attr_name;
  int ca_id;
  String attr_types_price;
  String attributeId;
  int selectedid;

  //List<Attribute_Data> attributes;
  SetMealProduct(
      {this.setmealProductId,
      this.setmealId,
      this.productId,
      this.quantity,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.base64,
      this.name,
      this.cateAtt,
      this.attr_name,
      this.ca_id,
      this.attr_types_price,
      this.attributeId,
      this.selectedid});

  SetMealProduct.fromJson(Map<String, dynamic> json) {
    setmealProductId = json['setmeal_product_id'];
    setmealId = json['setmeal_id'];
    productId = json['product_id'];
    quantity = json['quantity'] is int
        ? (json['quantity'] as int).toDouble()
        : json["quantity"];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    base64 = json['base64'] != null ? json['base64'] : "";
    name = json['name'];
    attr_name = json["attr_name"];
    cateAtt = json["cateAtt"];
    ca_id = json["ca_id"];
    attr_types_price = json["attr_types_price"];
    attributeId = json["attributeId"];
    selectedid = json["selectedid"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['setmeal_product_id'] = this.setmealProductId;
    data['setmeal_id'] = this.setmealId;
    data['product_id'] = this.productId;
    data['quantity'] = this.quantity;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['base64'] = this.base64;
    data["cateAtt"] = this.cateAtt;
    data["attr_name"] = this.attr_name;
    data["ca_id"] = this.ca_id;
    data["attr_types_price"] = this.attr_types_price;
    data["attributeId"] = this.attributeId;
    data["selectedid"] = this.selectedid;
    return data;
  }
}
