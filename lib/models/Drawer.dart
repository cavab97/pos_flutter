class Drawerdata {
  int id;
  int shiftId;
  double amount;
  int isAmountIn;
  String reason;
  int status;
  int createdBy;
  int updatedBy;
  String createdAt;
  String updatedAt;
  int serverId;
  String localID;
  int terminalid;

  Drawerdata(
      {this.id,
      this.shiftId,
      this.amount,
      this.isAmountIn,
      this.reason,
      this.status,
      this.createdBy,
      this.updatedBy,
      this.createdAt,
      this.updatedAt,
      this.serverId,
      this.localID,
      this.terminalid});

  Drawerdata.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shiftId = json['shift_id'];
    amount = json['amount'] is int
        ? (json['amount'] as int).toDouble()
        : json['amount'];
    isAmountIn = json['is_amount_in'];
    reason = json['reason'];
    status = json['status'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    serverId = json['serverId'];
    localID = json['localID'];
    terminalid = json['terminalid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['shift_id'] = this.shiftId;
    data['amount'] = this.amount;
    data['is_amount_in'] = this.isAmountIn;
    data['reason'] = this.reason;
    data['status'] = this.status;
    data['created_by'] = this.createdBy;
    data['updated_by'] = this.updatedBy;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['serverId'] = this.serverId;
    data['localID'] = this.localID;
    data['terminalid'] = this.terminalid;
    return data;
  }
}
