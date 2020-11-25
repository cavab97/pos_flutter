class CancelOrder {
  int id;
  int orderId;
  int order_app_id;
  String localID;
  String reason;
  int status;
  int createdBy;
  int updatedBy;
  String createdAt;
  String updatedAt;
  int serverId;
  int terminalId;

  CancelOrder({
    this.id,
    this.orderId,
    this.order_app_id,
    this.localID,
    this.reason,
    this.status,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.serverId,
    this.terminalId,
  });

  CancelOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    order_app_id = json["order_app_id"];
    orderId = json['order_id'];
    localID = json['localID'];
    reason = json['reason'];
    status = json['status'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    serverId = json['server_id'];
    terminalId = json['terminal_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data["order_app_id"] = this.order_app_id;
    data['order_id'] = this.orderId;
    data['localID'] = this.localID;
    data['reason'] = this.reason;
    data['status'] = this.status;
    data['created_by'] = this.createdBy;
    data['updated_by'] = this.updatedBy;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['server_id'] = this.serverId;
    data['terminal_id'] = this.terminalId;
    return data;
  }
}
