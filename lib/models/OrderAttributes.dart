class OrderAttributes {
  int oa_id;
  String uuid;
  int order_id;
  int detail_id;
  int terminal_id;
  int app_id;
  int product_id;
  int attribute_id;
  double attr_price;
  int ca_id;
  String oa_datetime;
  int oa_by;
  String updated_at;
  int updated_by;
  int oa_status;

  OrderAttributes({
    this.oa_id,
    this.uuid,
    this.order_id,
    this.detail_id,
    this.terminal_id,
    this.app_id,
    this.product_id,
    this.attribute_id,
    this.attr_price,
    this.ca_id,
    this.oa_datetime,
    this.oa_by,
    this.oa_status,
    this.updated_at,
    this.updated_by,
  });

  OrderAttributes.fromJson(Map<String, dynamic> json) {
    oa_id = json["oa_id"];
    uuid = json["uuid"];
    order_id = json["order_id"];
    detail_id = json["detail_id"];
    terminal_id = json["terminal_id"];
    app_id = json["app_id"];
    product_id = json["product_id"];
    attribute_id = json["attribute_id"];
    attr_price = json["attr_price"] is int
        ? (json['attr_price'] as int).toDouble()
        : json['attr_price'];
    ca_id = json["ca_id"];
    oa_datetime = json["oa_datetime"];
    oa_by = json["oa_by"];
    oa_status = json['oa_status'];
    updated_at = json["updated_at"];
    updated_by = json["updated_by"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["oa_id"] = this.oa_id;
    data["uuid"] = this.uuid;
    data["order_id"] = this.order_id;
    data["detail_id"] = this.order_id;
    data["terminal_id"] = this.terminal_id;
    data["app_id"] = this.app_id;
    data["product_id"] = this.product_id;
    data["attribute_id"] = this.attribute_id;
    data["attr_price"] = this.attr_price;
    data["ca_id"] = this.ca_id;
    data["oa_datetime"] = this.oa_datetime;
    data["oa_by"] = this.oa_by;
    data["oa_status"] = this.oa_status;
    data["updated_at"] = this.updated_at;
    data["updated_by"] = this.updated_by;

    return data;
  }
}
