import 'package:deep_pick/deep_pick.dart';

class TerminalLog {
  int id;
  String uuid;
  int terminal_id;
  int isSync;
  int branch_id;
  String module_name;
  String description;
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
    this.isSync,
    this.branch_id,
    this.module_name,
    this.description,
    this.activity_date,
    this.activity_time,
    this.table_name,
    this.entity_id,
    this.status,
    this.updated_at,
    this.updated_by,
  });

  TerminalLog.fromJson(Map<String, dynamic> json) {
    id = pick(json, "id").asIntOrNull();
    uuid = pick(json, "uuid").asStringOrNull();
    terminal_id = pick(json, "terminal_id").asIntOrNull();
    isSync = pick(json, "is_sync").asIntOrNull();
    branch_id = pick(json, "branch_id").asIntOrNull();
    module_name = pick(json, "module_name").asStringOrNull();
    description = pick(json, "description").asStringOrNull();
    activity_date = pick(json, "activity_date").asStringOrNull();
    activity_time = pick(json, "activity_time").asStringOrNull();
    table_name = pick(json, "table_name").asStringOrNull();
    entity_id = pick(json, "entity_id").asIntOrNull();
    status = pick(json, "status").asIntOrNull();
    updated_at = pick(json, "updated_at").asStringOrNull();
    updated_by = pick(json, "updated_by").asIntOrNull();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["uuid"] = this.uuid;
    data["terminal_id"] = this.terminal_id;
    data["is_sync"] = this.isSync;
    data["branch_id"] = this.branch_id;
    data["module_name"] = this.module_name;
    data["description"] = this.description;
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
