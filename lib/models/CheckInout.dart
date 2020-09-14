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
    id = json["id"];
    localID = json["localID"];
    userId = json["user_id"];
    branchId = json["branch_id"];
    status = json["status"];
    timeInOut = json["timeinout"];
    createdAt = json["create"];
    terminalId = json["terminalid"];
    sync = json["sync"];
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
