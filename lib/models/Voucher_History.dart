class VoucherHistory {
  int voucher_history_id;
  String uuid;
  int voucher_id;
  int order_id;
  int app_order_id;
  int user_id;
  double amount;
  String created_at;

  VoucherHistory({
    this.voucher_history_id,
    this.uuid,
    this.app_order_id,
    this.voucher_id,
    this.order_id,
    this.user_id,
    this.amount,
    this.created_at,
  });

  VoucherHistory.fromJson(Map<String, dynamic> json) {
    voucher_history_id = json["voucher_history_id"];
    uuid = json["uuid"];
    app_order_id = json["app_order_id"];
    voucher_id = json["voucher_id"];
    order_id = json["order_id"];
    user_id = json["user_id"];
    amount = json["amount"];
    created_at = json["created_at"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['voucher_history_id'] = this.voucher_history_id;
    data['uuid'] = this.uuid;
    data["app_order_id"] = this.app_order_id;
    data['voucher_id'] = this.voucher_id;
    data['order_id'] = this.order_id;
    data['user_id'] = this.user_id;
    data['amount'] = this.amount;
    data['created_at'] = this.created_at;
    return data;
  }
}
