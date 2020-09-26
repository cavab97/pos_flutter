class Tax {
  int taxId;
  String uuid;
  String code;
  String description;
  String rate;
  int status;
  int isFixed;
  String updatedAt;
  int updatedBy;

  Tax(
      {this.taxId,
      this.uuid,
      this.code,
      this.description,
      this.rate,
      this.status,
      this.isFixed,
      this.updatedAt,
      this.updatedBy});

  Tax.fromJson(Map<String, dynamic> json) {
    taxId = json['tax_id'];
    uuid = json['uuid'];
    code = json['code'];
    description = json['description'];
    rate = json['rate'];
    status = json['status'];
    isFixed = json['is_fixed'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tax_id'] = this.taxId;
    data['uuid'] = this.uuid;
    data['code'] = this.code;
    data['description'] = this.description;
    data['rate'] = this.rate;
    data['status'] = this.status;
    data['is_fixed'] = this.isFixed;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}
