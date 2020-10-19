class MSTCartdetails {
  int id;
  int cartId;
  String localID;
  int productId;
  int printer_id;
  String productName;
  double productPrice;
  double productQty;
  double productNetPrice;
  int taxId;
  double taxValue;
  double discount;
  int discountType;
  String remark;
  int isDeleted;
  int sync;
  int isSendKichen;
  String itemUnit;
  String cart_detail;
  String setmeal_product_detail;
  int issetMeal;
  int hasCompositeInventory;
  int productPoints;
  int productTotalPoints;
  String createdAt;
  int createdBy;

  MSTCartdetails(
      {this.cartId,
      this.localID,
      this.productId,
      this.printer_id,
      this.productName,
      this.productPrice,
      this.productQty,
      this.productNetPrice,
      this.taxId,
      this.taxValue,
      this.discount,
      this.discountType,
      this.remark,
      this.isDeleted,
      this.issetMeal,
      this.isSendKichen,
      this.itemUnit,
      this.hasCompositeInventory,
      this.cart_detail,
      this.setmeal_product_detail,
      this.createdAt,
      this.createdBy});

  MSTCartdetails.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    cartId = json["cart_id"];
    localID = json["localID"];
    productId = json["product_id"];
    printer_id = json["printer_id"];
    productName = json["product_name"];
    productPrice = json["product_price"] is int
        ? (json['product_price'] as int).toDouble()
        : json["product_price"];
    productQty = json["product_qty"] is int
        ? (json['product_qty'] as int).toDouble()
        : json["product_qty"];
    productNetPrice = json["product_net_price"] is int
        ? (json['product_net_price'] as int).toDouble()
        : json["product_net_price"];
    taxId = json["tax_id"];
    taxValue = json["tax_value"] is int
        ? (json['tax_value'] as int).toDouble()
        : json["tax_value"];
    discount = json["discount"] is int
        ? (json['discount'] as int).toDouble()
        : json["discount"];
    discountType = json["discount_type"];
    remark = json["remark"];
    isDeleted = json["is_deleted"];
    cart_detail = json['cart_detail'];
    setmeal_product_detail = json['setmeal_product_detail'];
    isSendKichen = json["is_send_kichen"];
    itemUnit = json["item_unit"];
    issetMeal = json["issetMeal"];
    hasCompositeInventory = json["has_composite_inventory"];
    createdAt = json["created_at"];
    createdBy = json["created_by"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["cart_id"] = this.cartId;
    data["localID"] = this.localID;
    data["product_id"] = this.productId;
    data["printer_id"] = this.printer_id;
    data["product_name"] = this.productName;
    data["product_price"] = this.productPrice;
    data["product_qty"] = this.productQty;
    data["product_net_price"] = this.productNetPrice;
    data["tax_id"] = this.taxId;
    data["tax_value"] = this.taxValue;
    data["discount"] = this.discount;
    data["discount_type"] = this.discountType;
    data["remark"] = this.remark;
    data["is_deleted"] = this.isDeleted;
    data["is_send_kichen"] = this.isSendKichen;
    data["cart_detail"] = this.cart_detail;
    data["setmeal_product_detail"] = this.setmeal_product_detail;
    data["has_composite_inventory"] = this.hasCompositeInventory;
    data["item_unit"] = this.itemUnit;
    data["issetMeal"] = this.issetMeal;
    data["created_by"] = this.createdBy;
    data["created_at"] = this.createdAt;
    return data;
  }
}
