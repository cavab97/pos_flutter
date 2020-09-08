class ProductAttribute {
  int paId;
  String uuid;
  int productId;
  int attributeId;
  int price;
  int status;
  String updatedAt;
  int updatedBy;

  ProductAttribute(
      {this.paId,
      this.uuid,
      this.productId,
      this.attributeId,
      this.price,
      this.status,
      this.updatedAt,
      this.updatedBy});

  ProductAttribute.fromJson(Map<String, dynamic> json) {
    paId = json['pa_id'];
    uuid = json['uuid'];
    productId = json['product_id'];
    attributeId = json['attribute_id'];
    price = json['price'];
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pa_id'] = this.paId;
    data['uuid'] = this.uuid;
    data['product_id'] = this.productId;
    data['attribute_id'] = this.attributeId;
    data['price'] = this.price;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}

class Autogenerated {
  int paId;
  String uuid;
  int productId;
  int attributeId;
  int price;
  int status;
  String updatedAt;
  int updatedBy;

  Autogenerated(
      {this.paId,
      this.uuid,
      this.productId,
      this.attributeId,
      this.price,
      this.status,
      this.updatedAt,
      this.updatedBy});

  Autogenerated.fromJson(Map<String, dynamic> json) {
    paId = json['pa_id'];
    uuid = json['uuid'];
    productId = json['product_id'];
    attributeId = json['attribute_id'];
    price = json['price'];
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pa_id'] = this.paId;
    data['uuid'] = this.uuid;
    data['product_id'] = this.productId;
    data['attribute_id'] = this.attributeId;
    data['price'] = this.price;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}
