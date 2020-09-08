class Role {
  int roleId;
  String uuid;
  String roleName;
  int roleStatus;
  String roleUpdatedAt;
  int roleUpdatedBy;

  Role(
      {this.roleId,
      this.uuid,
      this.roleName,
      this.roleStatus,
      this.roleUpdatedAt,
      this.roleUpdatedBy});

  Role.fromJson(Map<String, dynamic> json) {
    roleId = json['role_id'];
    uuid = json['uuid'];
    roleName = json['role_name'];
    roleStatus = json['role_status'];
    roleUpdatedAt = json['role_updated_at'];
    roleUpdatedBy = json['role_updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['role_id'] = this.roleId;
    data['uuid'] = this.uuid;
    data['role_name'] = this.roleName;
    data['role_status'] = this.roleStatus;
    data['role_updated_at'] = this.roleUpdatedAt;
    data['role_updated_by'] = this.roleUpdatedBy;
    return data;
  }
}
