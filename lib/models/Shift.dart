import 'package:deep_pick/deep_pick.dart';

class Shift {
  int shiftId;
  String uuid;
  int terminalId;
  int appId;
  int serverId;
  int userId;
  int branchId;
  double startAmount;
  double endAmount;
  int status;
  String updatedAt;
  int updatedBy;
  String createdAt;

  Shift(
      {this.shiftId,
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
      this.createdAt});

  Shift.fromJson(Map<String, dynamic> json) {
    shiftId = pick(json, 'shift_id').asIntOrNull();
    uuid = pick(json, 'uuid').asStringOrNull();
    terminalId = pick(json, 'terminal_id').asIntOrNull();
    appId = pick(json, 'app_id').asIntOrNull() ?? 0;
    userId = pick(json, 'user_id').asIntOrNull();
    branchId = pick(json, 'branch_id').asIntOrNull();
    startAmount = pick(json, 'start_amount').asDoubleOrNull();
    endAmount = pick(json, 'end_amount').asDoubleOrNull();
    status = pick(json, 'status').asIntOrNull();
    updatedAt = pick(json, 'updated_at').asStringOrNull();
    updatedBy = pick(json, 'updated_by').asIntOrNull();
    createdAt = pick(json, 'created_at').asStringOrNull();
    serverId = pick(json, 'server_id').asIntOrNull();
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
