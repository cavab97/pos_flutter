class Orders {
  int order_id;
  String uuid;
  int branch_id;
  int terminal_id;
  int app_id;
  int table_no;
  int table_id;
  String invoice_no;
  int customer_id;
  int tax_percent;
  double tax_amount;
  int voucher_id;
  double voucher_amount;
  double sub_total;
  double sub_total_after_discount;
  double grand_total;
  int order_source;
  int order_status;
  int order_item_count;
  String order_date;
  int order_by;
  String updated_at;
  int updated_by;

  Orders({
    this.order_id,
    this.uuid,
    this.branch_id,
    this.terminal_id,
    this.app_id,
    this.table_no,
    this.table_id,
    this.invoice_no,
    this.customer_id,
    this.tax_percent,
    this.tax_amount,
    this.voucher_id,
    this.voucher_amount,
    this.sub_total,
    this.sub_total_after_discount,
    this.grand_total,
    this.order_source,
    this.order_status,
    this.order_item_count,
    this.order_date,
    this.order_by,
    this.updated_at,
    this.updated_by,
  });

  Orders.fromJson(Map<String, dynamic> json) {
    order_id = json["order_id"];
    uuid = json["uuid"];
    branch_id = json["branch_id"];
    terminal_id = json["terminal_id"];
    app_id = json["app_id"];
    table_no = json["table_no"];
    table_id = json["table_id"];
    invoice_no = json["invoice_no"];
    customer_id = json["customer_id"];
    tax_percent = json["tax_percent"];
    tax_amount = json["tax_amount"];
    voucher_id = json["voucher_id"];
    voucher_amount = json["voucher_amount"];
    sub_total = json["sub_total"];
    sub_total_after_discount = json["sub_total_after_discount"];
    grand_total = json["grand_total"];
    order_source = json["order_source"];
    order_status = json["order_status"];
    order_item_count = json["order_item_count"];
    order_date = json["order_date"];
    order_by = json["order_by"];
    updated_at = json["updated_at"];
    updated_by = json["updated_by"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["order_id"] = this.order_id;
    data["uuid"] = this.uuid;
    data["branch_id"] = this.branch_id;
    data["terminal_id"] = this.terminal_id;
    data["app_id"] = this.app_id;
    data["table_no"] = this.table_no;
    data["table_id"] = this.table_id;
    data["invoice_no"] = this.invoice_no;
    data["customer_id"] = this.customer_id;
    data["tax_percent"] = this.tax_percent;
    data["tax_amount"] = this.tax_amount;
    data["voucher_id"] = this.voucher_id;
    data["voucher_amount"] = this.voucher_amount;
    data["sub_total"] = this.sub_total;
    data["sub_total_after_discount"] = this.sub_total_after_discount;
    data["grand_total"] = this.grand_total;
    data["order_source"] = this.order_source;
    data["order_status"] = this.order_status;
    data["order_item_count"] = this.order_item_count;
    data["order_date"] = this.order_date;
    data["order_by"] = this.order_by;
    data["updated_at"] = this.updated_at;
    data["updated_by"] = this.updated_by;
    return data;
  }
}
