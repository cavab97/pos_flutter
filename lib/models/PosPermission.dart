class PosPermission {
  int posPermissionId;
  String posPermissionName;
  String posPermissionUpdatedAt;
  int posPermissionUpdatedBy;

  PosPermission(
      {this.posPermissionId,
      this.posPermissionName,
      this.posPermissionUpdatedAt,
      this.posPermissionUpdatedBy});

  PosPermission.fromJson(Map<String, dynamic> json) {
    posPermissionId = json['pos_permission_id'];
    posPermissionName = json['pos_permission_name'];
    posPermissionUpdatedAt = json['pos_permission_updated_at'];
    posPermissionUpdatedBy = json['pos_permission_updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pos_permission_id'] = this.posPermissionId;
    data['pos_permission_name'] = this.posPermissionName;
    data['pos_permission_updated_at'] = this.posPermissionUpdatedAt;
    data['pos_permission_updated_by'] = this.posPermissionUpdatedBy;
    return data;
  }
}