class Shift {
  int shiftId;
  String uuid;
  int terminalId;
  int appId;
  int serverId;
  int userId;
  int branchId;
  int startAmount;
  int endAmount;
  int status;
  String updatedAt;
  int updatedBy;
  String createdAt;

  Shift(
      {
      this.shiftId,
      this.uuid,
      this.terminalId,
      this.appId,
      this.userId,
      this.branchId,
      this.startAmount,
      this.endAmount,
      this.status,
      this.serverId,
      this.updatedAt,
      this.updatedBy,
      this.createdAt
      });

  Shift.fromJson(Map<String, dynamic> json) {
    shiftId = json['shift_id'];
    uuid = json['uuid'];
    terminalId = json['terminal_id'];
    appId = json['app_id'] != null ? json['app_id'] : 0;
    userId = json['user_id'];
    branchId = json['branch_id'];
    startAmount = json['start_amount'];
    endAmount = json['end_amount'];
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    createdAt = json['created_at'];
    serverId = json['server_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['shift_id'] = this.shiftId;
    data['uuid'] = this.uuid;
    data['terminal_id'] = this.terminalId;
    data['app_id'] = this.appId;
    data['user_id'] = this.userId;
    data['branch_id'] = this.branchId;
    data['start_amount'] = this.startAmount;
    data['end_amount'] = this.endAmount;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    data['created_at'] = this.createdAt;
    data["server_id"] = this.serverId;

    return data;
  }
}
