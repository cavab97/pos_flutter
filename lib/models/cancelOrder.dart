class CancelOrder {
  int id;
  int invoiceId;
  String localID;
  String reason;
  int status;
  int createdBy;
  int updatedBy;
  String createdAt;
  String updatedAt;
  int sync;
  int serverId;
  int terminalId;
  String invoiceUniqueId;
  int invoiceTerminalId;

  CancelOrder(
      {this.id,
      this.invoiceId,
      this.localID,
      this.reason,
      this.status,
      this.createdBy,
      this.updatedBy,
      this.createdAt,
      this.updatedAt,
      this.sync,
      this.serverId,
      this.terminalId,
      this.invoiceUniqueId,
      this.invoiceTerminalId});

  CancelOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    invoiceId = json['invoice_id'];
    localID = json['localID'];
    reason = json['reason'];
    status = json['status'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    sync = json['sync'];
    serverId = json['serverId'];
    terminalId = json['terminal_id'];
    invoiceUniqueId = json['invoice_unique_id'];
    invoiceTerminalId = json['invoice_terminal_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['invoice_id'] = this.invoiceId;
    data['localID'] = this.localID;
    data['reason'] = this.reason;
    data['status'] = this.status;
    data['created_by'] = this.createdBy;
    data['updated_by'] = this.updatedBy;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['sync'] = this.sync;
    data['serverId'] = this.serverId;
    data['terminal_id'] = this.terminalId;
    data['invoice_unique_id'] = this.invoiceUniqueId;
    data['invoice_terminal_id'] = this.invoiceTerminalId;
    return data;
  }
}
