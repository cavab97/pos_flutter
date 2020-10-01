class UserPosPermission {
  int upPosId;
  String upPosUuid;
  int userId;
  int status;
  int posPermissionId;
  String updatedAt;
  int updatedBy;

  UserPosPermission(
      {this.upPosId,
      this.upPosUuid,
      this.userId,
      this.status,
      this.posPermissionId,
      this.updatedAt,
      this.updatedBy});

  UserPosPermission.fromJson(Map<String, dynamic> json) {
    upPosId = json['up_pos_id'];
    upPosUuid = json['up_pos_uuid'];
    userId = json['user_id'];
    status = json['status'];
    posPermissionId = json['pos_permission_id'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['up_pos_id'] = this.upPosId;
    data['up_pos_uuid'] = this.upPosUuid;
    data['user_id'] = this.userId;
    data['status'] = this.status;
    data['pos_permission_id'] = this.posPermissionId;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}
