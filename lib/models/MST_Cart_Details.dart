class MSTCartdetails {
  int cartId;
  String localID;
  int productId;
  String productName;
  int productPrice;
  int productQty;
  int productNetPrice;
  String taxId;
  String taxValue;
  int discount;
  int discountType;
  String remark;
  int isDeleted;
  int sync;
  int isSendKichen;
  String itemUnit;
  int hasCompositeInventory;
  int productPoints;
  int productTotalPoints;
  String createdAt;
  int createdBy;
  MSTCartdetails(
      {this.cartId,
      this.localID,
      this.productId,
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
      // this.sync,
      this.isSendKichen,
      this.itemUnit,
      this.hasCompositeInventory,
      // this.productPoints,
      // this.productTotalPoints,
      this.createdAt,
      this.createdBy});

  MSTCartdetails.fromJson(Map<String, dynamic> json) {
    cartId = json["cart_id"];
    localID = json["localID"];
    productId = json["product_id"];
    productName = json["product_name"];
    productPrice = json["product_price"];
    productQty = json["product_qty"];
    productNetPrice = json["product_net_price"];
    taxId = json["tax_id"];
    taxValue = json["tax_value"];
    discount = json["discount"];
    discountType = json["discount_type"];
    remark = json["remark"];
    isDeleted = json["is_deleted"];
    // sync = json["sync"];
    isSendKichen = json["is_send_kichen"];
    itemUnit = json["item_unit"];
    hasCompositeInventory = json["has_composite_inventory"];
    // productPoints = json["product_points"];
    // productTotalPoints = json["product_total_points"];
    createdAt = json["created_at"];
    createdBy = json["created_by"];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data["cart_id"] = this.cartId;
    data["localID"] = this.localID;
    data["product_id"] = this.productId;
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
    // data["sync"] = this.sync;
    data["is_send_kichen"] = this.isSendKichen;
    data["has_composite_inventory"] = this.hasCompositeInventory;
    // data["product_points"] = this.productPoints;
    // data["product_total_points"] = this.productTotalPoints;
    data["item_unit"] = this.itemUnit;
    data["created_by"] = this.createdBy;
    data["created_at"] = this.createdAt;
    return data;
  }
}
