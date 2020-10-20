class LastAppids {
  int app_id;
  int order_detail_id;
  int order_payment_id;
  int order_attr_id;
  int order_modifier_id;

  LastAppids({
    this.app_id,
    this.order_detail_id,
    this.order_payment_id,
    this.order_attr_id,
    this.order_modifier_id,
  });

  LastAppids.fromJson(Map<String, dynamic> json) {
    app_id = json["app_id"];
    order_detail_id = json["order_detail_id"];
    order_payment_id = json["order_payment_id"];
    order_attr_id = json["order_attr_id"];
    order_modifier_id = json["order_modifier_id"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["app_id"] = this.app_id;
    data["order_detail_id"] = this.order_detail_id;
    data["order_payment_id"] = this.order_payment_id;
    data["order_attr_id"] = this.order_attr_id;
    data["order_modifier_id"] = this.order_modifier_id;
    return data;
  }
}
