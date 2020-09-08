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
  String updatedAt;
  int updatedBy;
  Null deletedAt;
  Null deletedBy;
  String base64;

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
      this.updatedAt,
      this.updatedBy,
      this.deletedAt,
      this.deletedBy,
      this.base64});

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
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    deletedAt = json['deleted_at'];
    deletedBy = json['deleted_by'];
    base64 = json['base64'];
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
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    data['deleted_at'] = this.deletedAt;
    data['deleted_by'] = this.deletedBy;
    data['base64'] = this.base64;
    return data;
  }
}
