class OrderDetail {
  int detailId;
  String uuid;
  int order_id;
  int order_app_id;
  int branch_id;
  int terminal_id;
  int app_id;
  int product_id;
  double product_price;
  double product_old_price;
  int category_id;
  double detail_amount;
  double product_discount;
  double detail_qty;
  int detail_status;
  String product_detail;
  int issetMeal;
  int hasRacManagemant;
  String setmeal_product_detail;
  int detail_by;
  int updated_by;
  String updated_at;
  String detail_datetime;
  String base64;
  int isSync;
  int server_id;

  OrderDetail({
    this.detailId,
    this.uuid,
    this.order_id,
    this.branch_id,
    this.terminal_id,
    this.app_id,
    this.product_id,
    this.product_price,
    this.product_old_price,
    this.product_discount,
    this.category_id,
    this.detail_amount,
    this.detail_qty,
    this.product_detail,
    this.setmeal_product_detail,
    this.detail_status,
    this.detail_by,
    this.updated_by,
    this.issetMeal,
    this.hasRacManagemant,
    this.updated_at,
    this.detail_datetime,
    this.base64,
    this.isSync,
    this.server_id,
  });

  OrderDetail.fromJson(Map<String, dynamic> json) {
    detailId = json["detail_id"];
    uuid = json["uuid"];
    order_id = json["order_id"];
    order_app_id = json["order_app_id"];
    branch_id = json["branch_id"];
    terminal_id = json["terminal_id"];
    app_id = json["app_id"];
    product_id = json["product_id"];
    product_price = json["product_price"] is int
        ? (json['product_price'] as int).toDouble()
        : json['product_price'];
    product_old_price = json["product_old_price"] is int
        ? (json['product_old_price'] as int).toDouble()
        : json['product_old_price'];
    category_id = json["category_id"];
    detail_amount = json["detail_amount"] is int
        ? (json['detail_amount'] as int).toDouble()
        : json['detail_amount'];
    detail_qty = json["detail_qty"] is int
        ? (json['detail_qty'] as int).toDouble()
        : json['detail_qty'];
    detail_status = json["detail_status"];
    detail_by = json["detail_by"];
    issetMeal = json["issetMeal"];
    hasRacManagemant = json["has_rac_managemant"];
    product_discount = json["product_discount"] is int
        ? (json['product_discount'] as int).toDouble()
        : json['product_discount'];
    product_detail = json["product_detail"];
    setmeal_product_detail = json["setmeal_product_detail"];
    updated_by = json["updated_by"];
    updated_at = json["updated_at"];
    detail_datetime = json["detail_datetime"];
    base64 = json["base64"];
    isSync = json["isSync"];
    server_id = json['server_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data["detail_id"] = this.detailId;
    data["uuid"] = this.uuid;
    data["order_id"] = this.order_id;
    data["order_app_id"] = this.order_app_id;
    data["branch_id"] = this.branch_id;
    data["terminal_id"] = this.terminal_id;
    data["app_id"] = this.app_id;
    data["product_id"] = this.product_id;
    data["product_price"] = this.product_price;
    data["product_old_price"] = this.product_old_price;
    data["category_id"] = this.category_id;
    data["detail_amount"] = this.detail_amount;
    data["detail_qty"] = this.detail_qty;
    data["issetMeal"] = this.issetMeal;
    data["has_rac_managemant"] = this.hasRacManagemant;
    data["detail_status"] = this.detail_status;
    data["detail_by"] = this.detail_by;
    data["product_discount"] = this.product_discount;
    data["product_detail"] = this.product_detail;
    data["setmeal_product_detail"] = this.setmeal_product_detail;
    data["updated_by"] = this.updated_by;
    data["updated_at"] = this.updated_at;
    data["detail_datetime"] = this.detail_datetime;
    data["base64"] = this.base64;
    data["isSync"] = this.isSync;
    data["server_id"] = this.server_id;
    return data;
  }
}
