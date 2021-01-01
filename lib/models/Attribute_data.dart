class Attribute_Data {
  int productId;
  int ca_id;
  String attributeId;
  String qty;
  String attr_name;
  String attr_types_price;
  String attr_types;
  String is_default;
  Attribute_Data(
      {this.productId,
      this.attr_name,
      this.qty,
      this.attr_types_price,
      this.attr_types,
      this.ca_id,
      this.is_default});

  Attribute_Data.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    attr_name = json["attr_name"];
    qty = json["qty"];
    attr_types = json["attr_types"].toString();
    attr_types_price = json["attr_types_price"];
    attributeId = json["attributeId"].toString();
    ca_id = json["ca_id"];
    is_default = json["is_default"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.productId;
    data["ca_id"] = this.ca_id;
    data["qty"] = this.qty;
    data["attr_name"] = this.attr_name;
    data["attr_types"] = this.attr_types.toString();
    data["attr_types_price"] = this.attr_types_price;
    data["attributeId"] = this.attributeId;
    data["is_default"] = this.is_default;
    return data;
  }
}
