class Reservation {
  int id;
  String resNo;
  String customerID;
  String customerName;
  String customerPhone;
  String resFrom;
  String resTo;
  int createdBy;
  int terminalID;
  int updatedBy;
  int deletedBy;
  String createdAt;
  String updatedAt;
  String deletedAt;

  Reservation({
    this.id,
    this.resNo,
    this.customerID,
    this.customerName,
    this.customerPhone,
    this.resFrom,
    this.resTo,
    this.terminalID,
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
    this.customerID = json['customer_id'];
    this.customerName = json['customer_name'];
    this.customerPhone = json['customer_phone'];
    this.resFrom = json['res_from'];
    this.resTo = json['res_to'];
    this.terminalID = json['terminal_id'];
    this.createdBy = json['created_by'];
    this.updatedBy = json['updated_by'];
    this.deletedBy = json['deleted_by'];
    this.createdAt = json['createdAt'];
    this.updatedAt = json['updatedAt'];
    this.deletedAt = json['deletedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['res_no'] = this.resNo;
    data['customer_id'] = this.customerID;
    data['customer_name'] = this.customerName;
    data['customer_phone'] = this.customerPhone;
    data['res_from'] = this.resFrom;
    data['res_to'] = this.resTo;
    data['terminal_id'] = this.terminalID;
    data['created_by'] = this.createdBy;
    data['updated_by'] = this.updatedBy;
    data['deleted_by'] = this.deletedBy;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['deletedAt'] = this.deletedAt;
    return data;
  }
}
