class MSTSubCartdetails {
  int id;
  int cartdetailsId;
  String localID;
  int productId;
  String modifierId;
  String modifirePrice;
  int attributeId;
  int caId;

  MSTSubCartdetails({
    this.id,
    this.cartdetailsId,
    this.localID,
    this.productId,
    this.modifierId,
    this.modifirePrice,
    this.attributeId,
    this.caId,
  });

  MSTSubCartdetails.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    cartdetailsId = json["cart_details_id"];
    localID = json["localID"];
    productId = json["product_id"];
    modifierId = json["modifier_id"];
    modifirePrice = json["modifier_price"];
    caId = json["ca_id"];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["cart_details_id"] = this.cartdetailsId;
    data["localID"] = this.localID;
    data["product_id"] = this.productId;
    data["modifier_id"] = this.modifierId;
    data["modifier_price"] = this.modifirePrice;
    data["ca_id"] = this.caId;
    return data;
  }
}
