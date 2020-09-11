class MST_Cart {
  int id;
  String localID;
  int user_id;
  int branch_id;
  double sub_total;
  double discount;
  int discount_type;
  String remark;
  double tax;
  double grand_total;
  int total_qty;
  int is_open;
  int is_deleted;
  int created_by;
  String created_at;
  int sync;
  int customer_terminal;
  int queue_number;
  double service_charge_rate;
  int service_charge_amount;
  double redeem_points;
  double redeem_point_amount;
  double product_points;

  MST_Cart({
    this.id,
    this.localID,
    this.user_id,
    this.branch_id,
    this.sub_total,
    this.discount,
    this.discount_type,
    this.remark,
    this.tax,
    this.grand_total,
    this.total_qty,
    this.is_open,
    this.is_deleted,
    this.created_by,
    this.created_at,
    this.sync,
    this.customer_terminal,
    this.queue_number,
    this.service_charge_rate,
    this.service_charge_amount,
    this.redeem_points,
    this.redeem_point_amount,
    this.product_points,
  });

  MST_Cart.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    localID = json["localID"];
    user_id = json["user_id"];
    branch_id = json["branch_id"];
    sub_total = json["sub_total"];
    discount = json["discount"];
    discount_type = json["discount_type"];
    remark = json["remark"];
    tax = json["tax"];
    grand_total = json["grand_total"];
    total_qty = json["total_qty"];
    is_open = json["is_open"];
    is_deleted = json["is_deleted"];
    created_by = json["created_by"];
    created_at = json["created_by"];
    sync = json["sync"];
    customer_terminal = json["customer_terminal"];
    queue_number = json["queue_number"];
    service_charge_rate = json["service_charge_rate"];
    service_charge_amount = json["service_charge_amount"];
    redeem_points = json["redeem_points"];
    redeem_point_amount = json["redeem_point_amount"];
    product_points = json["product_points"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data["id"] = this.id;
    data["localID"] = this.localID;
    data["user_id"] = this.user_id;
    data["branch_id"] = this.branch_id;
    data["sub_total"] = this.sub_total;
    data["discount"] = this.discount;
    data["discount_type "] = this.discount_type;
    data["remark"] = this.remark;
    data["tax"] = this.tax;
    data["grand_total"] = this.grand_total;
    data["total_qty"] = this.total_qty;
    data["is_open"] = this.is_open;
    data["is_deleted"] = this.is_deleted;
    data["created_by"] = this.created_by;
    data["created_at"] = this.created_at;
    data["sync"] = this.sync;
    data["customer_terminal"] = this.customer_terminal;
    data["queue_number"] = this.queue_number;
    data["service_charge_rate"] = this.service_charge_rate;
    data["service_charge_amount"] = this.service_charge_amount;
    data["redeem_points"] = this.redeem_points;
    data["redeem_point_amount"] = this.redeem_point_amount;
    data["product_points"] = this.product_points;

    return data;
  }
}
