class ShiftInvoice {
  int id;
  int shift_id;
  int shift_app_id;
  int app_id;
  int invoice_id;
  int status;
  int created_by;
  int updated_by;
  String created_at;
  String updated_at;
  int serverId;
  int terminal_id;

  ShiftInvoice({
    this.id,
    this.shift_id,
    this.shift_app_id,
    this.app_id,
    this.invoice_id,
    this.status,
    this.created_by,
    this.updated_by,
    this.created_at,
    this.updated_at,
    this.serverId,
    this.terminal_id,
  });

  ShiftInvoice.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    shift_id = json["shift_id"];
    shift_app_id = json["shift_app_id"];
    app_id = json["app_id"];
    invoice_id = json["invoice_id"];
    status = json["status"];
    created_by = json["created_by"];
    updated_by = json["updated_by"];
    created_at = json["created_at"];
    updated_at = json["updated_at"];
    serverId = json["server_id"];
    terminal_id = json["terminal_id"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["shift_id"] = this.shift_id;
    data["shift_app_id"] = this.shift_app_id;
    data["app_id"] = this.app_id;
    data["invoice_id"] = this.invoice_id;
    data["status"] = this.status;
    data["created_by"] = this.created_by;
    data["updated_by"] = this.updated_by;
    data["created_at"] = this.created_at;
    data["updated_at"] = this.updated_at;
    data["server_id"] = this.serverId;
    data["terminal_id"] = this.terminal_id;
    return data;
  }
}
