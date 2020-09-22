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
  String tax_json;
  double grand_total;
  double total_qty;
  int voucherId;
  int is_deleted;
  int created_by;
  String created_at;
  // int sync;
  int customer_terminal;

  // double service_charge_rate;
  // int service_charge_amount;
  // double redeem_points;
  // double redeem_point_amount;
  // double product_points;

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
    this.tax_json,
    this.voucherId,
    this.grand_total,
    this.total_qty,
    this.is_deleted,
    this.created_by,
    this.created_at,
    this.customer_terminal,
  });

  MST_Cart.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    localID = json["localID"];
    user_id = json["user_id"];
    branch_id = json["branch_id"];
    sub_total = json["sub_total"] is int
        ? (json['sub_total'] as int).toDouble()
        : json['sub_total'];
    discount = json["discount"] is int
        ? (json['discount'] as int).toDouble()
        : json['discount'];
    discount_type = json["discount_type"];
    remark = json["remark"];
    tax = json["tax"] is int ? (json['tax'] as int).toDouble() : json['tax'];
    tax_json = json["tax_json"];
    grand_total = json["grand_total"] as double;
    total_qty = json["total_qty"] as double;
    voucherId = json["voucher_id"];
    is_deleted = json["is_deleted"];
    created_by = json["created_by"];
    created_at = json["created_at"];
    customer_terminal = json["customer_terminal"];
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
    data["tax_json"] = this.tax_json;
    data["grand_total"] = this.grand_total;
    data["total_qty"] = this.total_qty;
    data["voucher_id"] = this.voucherId;
    data["is_deleted"] = this.is_deleted;
    data["created_by"] = this.created_by;
    data["created_at"] = this.created_at;

    data["customer_terminal"] = this.customer_terminal;

    return data;
  }
}
