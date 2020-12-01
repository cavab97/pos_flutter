class OrderPayment {
  int op_id;
  String uuid;
  int order_id;
  int order_app_id;
  int branch_id;
  int terminal_id;
  int app_id;
  int op_method_id;
  double op_amount;
  String op_method_response;
  int op_status;
  String op_datetime;
  int op_by;
  String updated_at;
  int updated_by;
  int is_split;
  String remark;
  String last_digits;
  String approval_code;
  String reference_number;
  double op_amount_change;
  int isCash;

  OrderPayment(
      {this.op_id,
      this.uuid,
      this.order_id,
      this.order_app_id,
      this.branch_id,
      this.terminal_id,
      this.app_id,
      this.op_method_id,
      this.op_amount,
      this.op_method_response,
      this.op_status,
      this.op_datetime,
      this.op_by,
      this.updated_at,
      this.updated_by,
      this.is_split,
      this.remark,
      this.last_digits,
      this.approval_code,
      this.reference_number,
      this.op_amount_change,
      this.isCash});

  OrderPayment.fromJson(Map<String, dynamic> json) {
    op_id = json["op_id"];
    uuid = json["uuid"];
    order_id = json["order_id"];
    order_app_id = json["order_app_id"];
    branch_id = json["branch_id"];
    terminal_id = json["terminal_id"];
    app_id = json["app_id"];
    op_method_id = json["op_method_id"];
    op_amount = json["op_amount"] is int
        ? (json['op_amount'] as int).toDouble()
        : json['op_amount'];
    op_method_response = json["op_method_response"];
    op_status = json["op_status"];
    op_datetime = json["op_datetime"];
    op_by = json["op_by"];
    updated_at = json["updated_at"];
    updated_by = json["updated_by"];
    is_split = json["is_split"];
    remark = json["remark"];
    last_digits = json["last_digits"];
    approval_code = json["approval_code"];
    reference_number = json["reference_number"];
    op_amount_change = json["op_amount_change"] is int
        ? (json['op_amount_change'] as int).toDouble()
        : json['op_amount_change'];
    isCash = json["is_cash"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["op_id"] = this.op_id;
    data["uuid"] = this.uuid;
    data["order_id"] = this.order_id;
    data["order_app_id"] = this.order_app_id;
    data["branch_id"] = this.branch_id;
    data["terminal_id"] = this.terminal_id;
    data["app_id"] = this.app_id;
    data["op_method_id"] = this.op_method_id;
    data["op_amount"] = this.op_amount;
    data["op_method_response"] = this.op_method_response;
    data["op_status"] = this.op_status;
    data["op_datetime"] = this.op_datetime;
    data["op_by"] = this.op_by;
    data["updated_at"] = this.updated_at;
    data["updated_by"] = this.updated_by;
    data["is_split"] = this.is_split;
    data["remark"] = this.remark;
    data["last_digits"] = this.last_digits;
    data["approval_code"] = this.approval_code;
    data["reference_number"] = this.reference_number;
    data["op_amount_change"] = this.op_amount_change;
    data["is_cash"] = this.isCash;
    return data;
  }
}
