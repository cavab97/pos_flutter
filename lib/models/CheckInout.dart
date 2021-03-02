import 'package:deep_pick/deep_pick.dart';

class CheckinOut {
  int id;
  String localID;
  int userId;
  int branchId;
  String status;
  String timeInOut;
  String createdAt;
  int terminalId;
  int sync;

  CheckinOut(
      {this.id,
      this.localID,
      this.userId,
      this.branchId,
      this.status,
      this.timeInOut,
      this.createdAt,
      this.terminalId,
      this.sync});

  CheckinOut.fromJson(Map<String, dynamic> json) {
    try {
      id = pick(json, "id").asIntOrNull();
      localID = pick(json, "localID").asStringOrNull();
      userId = pick(json, "user_id").asIntOrNull();
      branchId = pick(json, "branch_id").asIntOrNull();
      status = pick(json, "status").asStringOrNull();
      timeInOut = pick(json, "timeinout").asStringOrNull();
      createdAt = pick(json, "create").asStringOrNull();
      terminalId = pick(json, "terminalid").asIntOrNull();
      sync = pick(json, "sync").asIntOrNull();
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["localID"] = this.localID;
    data["user_id"] = this.userId;
    data["branch_id"] = this.branchId;
    data["status"] = this.status;
    data["timeinout"] = this.timeInOut;
    data["created_at"] = this.createdAt;
    data["terminalid"] = this.terminalId;
    return data;
  }
}
