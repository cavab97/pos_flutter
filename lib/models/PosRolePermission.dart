class PosRolePermission {
  int posRpId;
  String posRpUuid;
  int posRpRoleId;
  int posRpPermissionId;
  int posRpPermissionStatus;
  String posRpUpdatedAt;
  int posRpUpdatedBy;

  PosRolePermission(
      {this.posRpId,
      this.posRpUuid,
      this.posRpRoleId,
      this.posRpPermissionId,
      this.posRpPermissionStatus,
      this.posRpUpdatedAt,
      this.posRpUpdatedBy});

  PosRolePermission.fromJson(Map<String, dynamic> json) {
    posRpId = json['pos_rp_id'];
    posRpUuid = json['pos_rp_uuid'];
    posRpRoleId = json['pos_rp_role_id'];
    posRpPermissionId = json['pos_rp_permission_id'];
    posRpPermissionStatus = json['pos_rp_permission_status'];
    posRpUpdatedAt = json['pos_rp_updated_at'];
    posRpUpdatedBy = json['pos_rp_updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pos_rp_id'] = this.posRpId;
    data['pos_rp_uuid'] = this.posRpUuid;
    data['pos_rp_role_id'] = this.posRpRoleId;
    data['pos_rp_permission_id'] = this.posRpPermissionId;
    data['pos_rp_permission_status'] = this.posRpPermissionStatus;
    data['pos_rp_updated_at'] = this.posRpUpdatedAt;
    data['pos_rp_updated_by'] = this.posRpUpdatedBy;
    return data;
  }
}
