import 'package:deep_pick/deep_pick.dart';

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
    posPermissionId = pick(json, 'pos_permission_id').asIntOrNull();
    posPermissionName = pick(json, 'pos_permission_name').asStringOrNull();
    posPermissionUpdatedAt =
        pick(json, 'pos_permission_updated_at').asStringOrNull();
    posPermissionUpdatedBy =
        pick(json, 'pos_permission_updated_by').asIntOrNull();
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
