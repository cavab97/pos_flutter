class TerminalLog {
  int id;
  String uuid;
  int terminal_id;
  int branch_id;
  String module_name;
  String discription;
  String activity_date;
  String activity_time;
  String table_name;
  int entity_id;
  int status;
  String updated_at;
  int updated_by;

  TerminalLog({
    this.id,
    this.uuid,
    this.terminal_id,
    this.branch_id,
    this.module_name,
    this.discription,
    this.activity_date,
    this.activity_time,
    this.table_name,
    this.entity_id,
    this.status,
    this.updated_at,
    this.updated_by,
  });

  TerminalLog.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    uuid = json["uuid"];
    terminal_id = json["terminal_id"];
    branch_id = json["branch_id"];
    module_name = json["module_name"];
    discription = json["discription"];
    activity_date = json["activity_date"];
    activity_time = json["activity_time"];
    table_name = json["table_name"];
    entity_id = json["table_name"];
    status = json["status"];
    updated_at = json["updated_at"];
    updated_by = json["updated_by"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["uuid"] = this.uuid;
    data["terminal_id"] = this.terminal_id;
    data["branch_id"] = this.branch_id;
    data["module_name"] = this.module_name;
    data["discription"] = this.discription;
    data["activity_date"] = this.activity_date;
    data["activity_time"] = this.activity_time;
    data["table_name"] = this.table_name;
    data["entity_id"] = this.entity_id;
    data["status"] = this.status;
    data["updated_at"] = this.updated_at;
    data["updated_by"] = this.updated_by;
    return data;
  }
}
