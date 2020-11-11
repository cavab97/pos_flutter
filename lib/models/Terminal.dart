class Terminal {
  int terminalId;
  String uuid;
  String terminalDeviceToken;
  String terminalDeviceId;
  int branchId;
  String terminalName;
  String terminalKey;
  int terminalType;
  int terminalIsMother;
  String terminalVerifiedAt;
  int status;
  String updatedAt;
  int updatedBy;
  String deletedAt;
  int deletedBy;

  Terminal(
      {this.terminalId,
      this.uuid,
      this.terminalDeviceId,
      this.terminalDeviceToken,
      this.terminalVerifiedAt,
      this.branchId,
      this.terminalName,
      this.terminalKey,
      this.terminalType,
      this.terminalIsMother,
      this.status,
      this.updatedAt,
      this.updatedBy,
      this.deletedAt,
      this.deletedBy});

  Terminal.fromJson(Map<String, dynamic> json) {
    terminalId = json['terminal_id'];
    uuid = json['uuid'];
    terminalDeviceId = json['terminal_device_id'];
    terminalDeviceToken = json["terminal_device_token"];
    branchId = json['branch_id'];
    terminalName = json['terminal_name'];
    terminalKey = json['terminal_key'];
    terminalType = json['terminal_type'];
    terminalIsMother = json['terminal_is_mother'];
    terminalVerifiedAt = json['terminal_verified_at'];
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    deletedAt = json['deleted_at'];
    deletedBy = json['deleted_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['terminal_id'] = this.terminalId;
    data['uuid'] = this.uuid;
    data['terminal_device_id'] = this.terminalDeviceId;
    data['terminal_device_token'] = this.terminalDeviceToken;
    data['branch_id'] = this.branchId;
    data['terminal_name'] = this.terminalName;
    data['terminal_key'] = this.terminalKey;
    data['terminal_type'] = this.terminalType;
    data['terminal_is_mother'] = this.terminalIsMother;
    data['status'] = this.status;
    data['terminal_verified_at'] = this.terminalVerifiedAt;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    data['deleted_at'] = this.deletedAt;
    data['deleted_by'] = this.deletedBy;
    return data;
  }
}
