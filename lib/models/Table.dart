class Tables {
  int tableId;
  String uuid;
  int branchId;
  String tableName;
  int tableType;
  String tableQr;
  int tableCapacity;
  int status;
  Null updatedAt;
  int updatedBy;
  Null deletedAt;
  Null deletedBy;

  Tables(
      {this.tableId,
      this.uuid,
      this.branchId,
      this.tableName,
      this.tableType,
      this.tableQr,
      this.tableCapacity,
      this.status,
      this.updatedAt,
      this.updatedBy,
      this.deletedAt,
      this.deletedBy});

  Tables.fromJson(Map<String, dynamic> json) {
    tableId = json['table_id'];
    uuid = json['uuid'];
    branchId = json['branch_id'];
    tableName = json['table_name'];
    tableType = json['table_type'];
    tableQr = json['table_qr'];
    tableCapacity = json['table_capacity'];
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    deletedAt = json['deleted_at'];
    deletedBy = json['deleted_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['table_id'] = this.tableId;
    data['uuid'] = this.uuid;
    data['branch_id'] = this.branchId;
    data['table_name'] = this.tableName;
    data['table_type'] = this.tableType;
    data['table_qr'] = this.tableQr;
    data['table_capacity'] = this.tableCapacity;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    data['deleted_at'] = this.deletedAt;
    data['deleted_by'] = this.deletedBy;
    return data;
  }
}
