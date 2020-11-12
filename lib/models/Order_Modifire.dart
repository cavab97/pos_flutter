class OrderModifire {
  int om_id;
  String uuid;
  int order_id;
  int order_app_id;
  int detail_app_id;
  int detail_id;
  int terminal_id;
  int app_id;
  int product_id;
  int modifier_id;
  double om_amount;
  int om_status;
  String om_datetime;
  int om_by;
  String updated_at;
  int updated_by;
  String name;

  OrderModifire(
      {this.om_id,
      this.uuid,
      this.order_id,
      this.order_app_id,
      this.detail_app_id,
      this.detail_id,
      this.terminal_id,
      this.app_id,
      this.product_id,
      this.modifier_id,
      this.om_amount,
      this.om_status,
      this.om_datetime,
      this.om_by,
      this.updated_at,
      this.updated_by,
      this.name});

  OrderModifire.fromJson(Map<String, dynamic> json) {
    om_id = json["om_id"];
    uuid = json["uuid"];
    order_app_id = json["order_app_id"];
    detail_app_id = json["detail_app_id"];
    order_id = json["order_id"];
    detail_id = json["detail_id"];
    terminal_id = json["terminal_id"];
    app_id = json["app_id"];
    product_id = json["product_id"];
    modifier_id = json["modifier_id"];
    om_amount = json["om_amount"] is int
        ? (json['om_amount'] as int).toDouble()
        : json['om_amount'];
    om_status = json["om_status"];
    om_datetime = json["om_datetime"];
    om_by = json["om_by"];
    updated_at = json["updated_at"];
    updated_by = json["updated_by"];
    name = json["name"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["om_id"] = this.om_id;
    data["uuid"] = this.uuid;
    data["detail_app_id"] = this.detail_app_id;
    data["order_app_id"] = this.order_app_id;
    data["order_id"] = this.order_id;
    data["detail_id"] = this.detail_id;
    data["terminal_id"] = this.terminal_id;
    data["app_id"] = this.app_id;
    data["product_id"] = this.product_id;
    data["modifier_id"] = this.modifier_id;
    data["om_amount"] = this.om_amount;
    data["om_status"] = this.om_status;
    data["om_datetime"] = this.om_datetime;
    data["om_by"] = this.om_by;
    data["updated_at"] = this.updated_at;
    data["updated_by"] = this.updated_by;
    data["name"] = this.name;
    return data;
  }
}
