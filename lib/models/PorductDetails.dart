class ProductDetails {
  int productId;
  String uuid;
  String name;
  String description;
  String sku;
  int priceTypeId;
  String priceTypeValue;
  String priceTypeName;
  double price;
  double oldPrice;
  double qty;
  int hasInventory;
  int status;
  String updatedAt;
  String deletedAt;
  int updatedBy;
  String deletedBy;
  String base64;

  ProductDetails({
    this.productId,
    this.uuid,
    this.name,
    this.description,
    this.sku,
    this.priceTypeId,
    this.priceTypeValue,
    this.price,
    this.oldPrice,
    this.priceTypeName,
    this.hasInventory,
    this.qty,
    this.status,
    this.updatedAt,
    this.deletedAt,
    this.updatedBy,
    this.deletedBy,
    this.base64,
  });

  ProductDetails.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    uuid = json['uuid'];
    name = json['name'];
    description = json['description'];
    sku = json['sku'];
    priceTypeName = json['price_type_Name'];
    priceTypeId = json['price_type_id'];
    priceTypeValue = json['price_type_value'];
    price = json['price'] is int
        ? (json['price'] as int).toDouble()
        : json['price'];

    oldPrice = json['old_price'] is int
        ? (json['old_price'] as int).toDouble()
        : json['old_price'];
    hasInventory = json['has_inventory'];
    status = json['status'];
    qty = json['qty'] != null ? double.parse(json['qty']) : 0.0;
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    updatedBy = json['updated_by'];
    deletedBy = json['deleted_by'];
    base64 = json['base64'] != null ? json['base64'] : "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.productId;
    data['uuid'] = this.uuid;
    data['name'] = this.name;
    data['description'] = this.description;
    data['sku'] = this.sku;
    data['price_type_id'] = this.priceTypeId;
    data['price_type_value'] = this.priceTypeValue;
    data['price'] = this.price;
    data['old_price'] = this.oldPrice;
    data['price_type_Name'] = this.priceTypeName;
    data['qty'] = this.qty;
    data['has_inventory'] = this.hasInventory;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['updated_by'] = this.updatedBy;
    data['deleted_by'] = this.deletedBy;
    data['base64'] = this.base64;
    return data;
  }
}
