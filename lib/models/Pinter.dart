class Printer {
  int printerId;
  String uuid;
  int branchId;
  String printerName;
  String printerIp;
  int printerIsCashier;
  int status;
  String updatedAt;
  int updatedBy;
  Null deletedAt;
  Null deletedBy;

  Printer(
      {this.printerId,
      this.uuid,
      this.branchId,
      this.printerName,
      this.printerIp,
      this.printerIsCashier,
      this.status,
      this.updatedAt,
      this.updatedBy,
      this.deletedAt,
      this.deletedBy});

  Printer.fromJson(Map<String, dynamic> json) {
    printerId = json['printer_id'];
    uuid = json['uuid'];
    branchId = json['branch_id'];
    printerName = json['printer_name'];
    printerIp = json['printer_ip'];
    printerIsCashier = json['printer_is_cashier'];
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    deletedAt = json['deleted_at'];
    deletedBy = json['deleted_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['printer_id'] = this.printerId;
    data['uuid'] = this.uuid;
    data['branch_id'] = this.branchId;
    data['printer_name'] = this.printerName;
    data['printer_ip'] = this.printerIp;
    data['printer_is_cashier'] = this.printerIsCashier;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    data['deleted_at'] = this.deletedAt;
    data['deleted_by'] = this.deletedBy;
    return data;
  }
}
