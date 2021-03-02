import 'package:deep_pick/deep_pick.dart';

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
  String deletedAt;
  int deletedBy;

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
    printerId = pick(json, 'printer_id').asIntOrNull();
    uuid = pick(json, 'uuid').asStringOrNull();
    branchId = pick(json, 'branch_id').asIntOrNull();
    printerName = pick(json, 'printer_name').asStringOrNull();
    printerIp = pick(json, 'printer_ip').asStringOrNull();
    printerIsCashier = pick(json, 'printer_is_cashier').asIntOrNull();
    status = pick(json, 'status').asIntOrNull();
    updatedAt = pick(json, 'updated_at').asStringOrNull();
    updatedBy = pick(json, 'updated_by').asIntOrNull();
    deletedAt = pick(json, 'deleted_at').asStringOrNull();
    deletedBy = pick(json, 'deleted_by').asIntOrNull();
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
