class Branch {
  int branchId;
  String uuid;
  String name;
  String address;
  String contactNo;
  String email;
  String contactPerson;
  String openFrom;
  String closedOn;
  int tax;
  String branchBanner;
  String latitude;
  String longitude;
  int status;
  String orderPrefix;
  String invoiceStart;
  String updatedAt;
  int updatedBy;
  String deletedAt;
  int deletedBy;
  String base64;
  double serviceCharge;
  Branch(
      {this.branchId,
      this.uuid,
      this.name,
      this.address,
      this.contactNo,
      this.email,
      this.contactPerson,
      this.openFrom,
      this.closedOn,
      this.tax,
      this.branchBanner,
      this.latitude,
      this.longitude,
      this.status,
      this.orderPrefix,
      this.invoiceStart,
      this.updatedAt,
      this.updatedBy,
      this.deletedAt,
      this.deletedBy,
      this.base64,
      this.serviceCharge});

  Branch.fromJson(Map<String, dynamic> json) {
    branchId = json['branch_id'];
    uuid = json['uuid'];
    name = json['name'];
    address = json['address'];
    contactNo = json['contact_no'];
    email = json['email'];
    contactPerson = json['contact_person'];
    openFrom = json['open_from'];
    closedOn = json['closed_on'];
    tax = json['tax'];
    branchBanner = json['branch_banner'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    status = json['status'];
    orderPrefix = json['order_prefix'];
    invoiceStart = json['invoice_start'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    deletedAt = json['deleted_at'];
    deletedBy = json['deleted_by'];
    base64 = json['base64'];
    serviceCharge = json["service_charge"] is int
        ? (json['service_charge'] as int).toDouble()
        : json['service_charge'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['branch_id'] = this.branchId;
    data['uuid'] = this.uuid;
    data['name'] = this.name;
    data['address'] = this.address;
    data['contact_no'] = this.contactNo;
    data['email'] = this.email;
    data['contact_person'] = this.contactPerson;
    data['open_from'] = this.openFrom;
    data['closed_on'] = this.closedOn;
    data['tax'] = this.tax;
    data['branch_banner'] = this.branchBanner;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['status'] = this.status;
    data['order_prefix'] = this.orderPrefix;
    data['invoice_start'] = this.invoiceStart;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    data['deleted_at'] = this.deletedAt;
    data['deleted_by'] = this.deletedBy;
    data['base64'] = this.base64;
    data["service_charge"] = this.serviceCharge;
    return data;
  }
}
