class MSTSubCartdetails {
  int id;
  int cartdetailsId;
  String localID;
  int cartDetailsProductId;
  int modifierId;
  int modifierOptionId;
  double variantQty;

  MSTSubCartdetails({
    this.id,
    this.cartdetailsId,
    this.localID,
    this.cartDetailsProductId,
    this.modifierId,
    this.modifierOptionId,
    this.variantQty,
  });

  MSTSubCartdetails.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    cartdetailsId = json["cart_details_id"];
    localID = json["localID"];
    cartDetailsProductId = json["cart_details_product_id"];
    modifierId = json["modifier_id"];
    modifierOptionId = json["modifier_option_id"];
    variantQty = json["variant_qty"];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["cart_details_id"] = this.cartdetailsId;
    data["localID"] = this.localID;
    data["cart_details_product_id"] = this.cartDetailsProductId;
    data["modifier_id"] = this.modifierId;
    data["modifier_option_id"] = this.modifierOptionId;
    data["variant_qty"] = this.variantQty;
    return data;
  }
}
