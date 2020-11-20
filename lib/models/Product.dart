class Product {
  int productId;
  String uuid;
  String name;
  String name_2;
  String description;
  String sku;
  int priceTypeId;
  String priceTypeValue;
  double price;
  double oldPrice;
  int hasInventory;
  int hasRacManagemant;
  int status;
  int hasSetmeal;
  String updatedAt;
  String deletedAt;
  int updatedBy;
  String deletedBy;
  String base64;

  Product({
    this.productId,
    this.uuid,
    this.name,
    this.name_2,
    this.description,
    this.sku,
    this.priceTypeId,
    this.priceTypeValue,
    this.price,
    this.oldPrice,
    this.hasInventory,
    this.hasRacManagemant,
    this.status,
    this.hasSetmeal,
    this.updatedAt,
    this.deletedAt,
    this.updatedBy,
    this.deletedBy,
    this.base64,
  });

  Product.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    uuid = json['uuid'];
    name = json['name'];
    name_2 = json['name_2'];
    description = json['description'];
    sku = json['sku'];
    priceTypeId = json['price_type_id'];
    priceTypeValue = json['price_type_value'];
    price = json['price'] is int
        ? (json['price'] as int).toDouble()
        : json['price'];
    oldPrice = json['old_price'] is int
        ? (json['old_price'] as int).toDouble()
        : json['old_price'];
    hasInventory = json['has_inventory'];
    hasRacManagemant = json['has_rac_managemant'];
    status = json['status'];
    hasSetmeal = json['has_setmeal'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    updatedBy = json['updated_by'];
    deletedBy = json['deleted_by'];
    //base64 = json['base64'] != null ? json['base64'] : "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.productId;
    data['uuid'] = this.uuid;
    data['name'] = this.name;
    data['name_2'] = this.name_2;
    data['description'] = this.description;
    data['sku'] = this.sku;
    data['price_type_id'] = this.priceTypeId;
    data['price_type_value'] = this.priceTypeValue;
    data['price'] = this.price;
    data['old_price'] = this.oldPrice;
    data['has_inventory'] = this.hasInventory;
    data["has_rac_managemant"] = this.hasRacManagemant;
    data['status'] = this.status;
    data['has_setmeal'] = this.hasSetmeal;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['updated_by'] = this.updatedBy;
    data['deleted_by'] = this.deletedBy;
    // data['base64'] = this.base64;
    return data;
  }
}
