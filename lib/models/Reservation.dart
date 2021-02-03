class Reservation {
  int id;
  String resNo;
  int tableID;
  String customerID;
  String customerName;
  String customerPhone;
  String resFrom;
  String resTo;
  int createdBy;
  int terminalID;
  int pax;
  bool isArr;
  String remark;
  int updatedBy;
  int deletedBy;
  String createdAt;
  String updatedAt;
  String deletedAt;

  Reservation({
    this.id,
    this.resNo,
    this.tableID,
    this.customerID,
    this.customerName,
    this.customerPhone,
    this.resFrom,
    this.resTo,
    this.terminalID,
    this.pax,
    this.remark,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  Reservation.fromJson(Map<String, dynamic> json) {
    this.id = json['id'];
    this.resNo = json['res_no'];
    this.tableID = json['table_id'];
    this.customerID = json['customer_id'];
    this.customerName = json['customer_name'];
    this.customerPhone = json['customer_phone'];
    this.resFrom = json['res_from'];
    this.resTo = json['res_to'];
    this.terminalID = json['terminal_id'];
    this.remark = json['remark'];
    this.pax = json['pax'];
    this.isArr = json['is_arr'] == 1 ? true : false;
    this.createdBy = json['created_by'];
    this.updatedBy = json['updated_by'];
    this.deletedBy = json['deleted_by'];
    this.createdAt = json['created_at'];
    this.updatedAt = json['updated_at'];
    this.deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['res_no'] = this.resNo;
    data['table_id'] = this.tableID;
    data['customer_id'] = this.customerID;
    data['customer_name'] = this.customerName;
    data['customer_phone'] = this.customerPhone;
    data['res_from'] = this.resFrom;
    data['res_to'] = this.resTo;
    data['terminal_id'] = this.terminalID;
    data['pax'] = this.pax;
    data['is_arr'] = (this.isArr != null && this.isArr) ? 1 : 0;
    data['remark'] = this.remark;
    data['created_by'] = this.createdBy;
    data['updated_by'] = this.updatedBy;
    data['deleted_by'] = this.deletedBy;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}
