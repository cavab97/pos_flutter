class MSTCartdetails {
  int id;
  int cartId;
  String localID;
  int productId;
  int printer_id;
  String productName;
  String productSecondName;
  double productPrice; // product total
  double productDetailAmount; // product net price
  double productQty;
  double productNetPrice;
  int taxId;
  double taxValue;
  String remark;
  double discountAmount;
  int discountType;
  String discountRemark;
  int isDeleted;
  int sync;
  int isSendKichen;
  int isFocProduct;
  String itemUnit;
  String cart_detail;
  String setmeal_product_detail;
  int issetMeal;
  int hasRacManagemant;
  int hasCompositeInventory;
  int productPoints;
  int productTotalPoints;
  String createdAt;
  int createdBy;
  String attrName;
  String modiName;
  String resNo;

  MSTCartdetails({
    this.cartId,
    this.localID,
    this.productId,
    this.printer_id,
    this.productName,
    this.productSecondName,
    this.productPrice,
    this.productDetailAmount,
    this.productQty,
    this.productNetPrice,
    this.taxId,
    this.taxValue,
    this.discountAmount,
    this.discountType,
    this.discountRemark,
    this.remark,
    this.issetMeal,
    this.hasRacManagemant,
    this.isSendKichen,
    this.isFocProduct,
    this.itemUnit,
    this.hasCompositeInventory,
    this.cart_detail,
    this.setmeal_product_detail,
    this.createdAt,
    this.createdBy,
    this.attrName,
    this.modiName,
    this.resNo,
  });

  MSTCartdetails.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    cartId = json["cart_id"];
    localID = json["local_id"];
    productId = json["product_id"];
    printer_id = json["printer_id"];
    productName = json["product_name"];
    productSecondName = json["name_2"];
    productPrice = json["product_price"] is int
        ? (json['product_price'] as int).toDouble()
        : json["product_price"];
    productDetailAmount = json["product_detail_amount"] is int
        ? (json['product_detail_amount'] as int).toDouble()
        : json["product_detail_amount"];
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
    remark = json["remark"];
    discountAmount = json["discount_amount"] is int
        ? (json['discount_amount'] as int).toDouble()
        : json["discount_amount"];
    discountType = json["discount_type"];
    discountRemark = json['discount_remark'];
    itemUnit = json["item_unit"];
    cart_detail = json['cart_detail'];
    setmeal_product_detail = json['setmeal_product_detail'];
    issetMeal = json["is_set_meal"];
    isFocProduct = json["is_foc_product"];
    isSendKichen = json["is_send_kichen"];
    hasRacManagemant = json["has_rac_managemant"];
    hasCompositeInventory = json["has_composite_inventory"];
    attrName = json["attr_name"];
    modiName = json["modi_name"];
    createdAt = json["created_at"];
    createdBy = json["created_by"];
    resNo = json["res_no"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["cart_id"] = this.cartId;
    data["local_id"] = this.localID;
    data["product_id"] = this.productId;
    data["printer_id"] = this.printer_id;
    data["product_name"] = this.productName;
    data["name_2"] = this.productSecondName;
    data["product_price"] = this.productPrice;
    data["product_detail_amount"] = this.productDetailAmount;
    data["product_qty"] = this.productQty;
    data["product_net_price"] = this.productNetPrice;
    data["tax_id"] = this.taxId;
    data["tax_value"] = this.taxValue;
    data["discount_amount"] = this.discountAmount;
    data["discount_type"] = this.discountType;
    data["discount_remark"] = this.discountRemark;
    data["remark"] = this.remark;
    data["cart_detail"] = this.cart_detail;
    data["setmeal_product_detail"] = this.setmeal_product_detail;
    data["item_unit"] = this.itemUnit;
    data["is_set_meal"] = this.issetMeal;
    data["is_foc_product"] = this.isFocProduct;
    data["is_send_kichen"] = this.isSendKichen;
    data["has_rac_managemant"] = this.hasRacManagemant;
    data["has_composite_inventory"] = this.hasCompositeInventory;
    data["attr_name"] = this.attrName;
    data["modi_name"] = this.modiName;
    data["created_by"] = this.createdBy;
    data["created_at"] = this.createdAt;
    data["res_no"] = this.resNo;
    return data;
  }
}
