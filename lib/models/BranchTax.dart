class BranchTax {
  int id;
  int taxId;
  int branchId;
  String rate;
  int status;
  String updatedAt;
  int updatedBy;
  String code;
  BranchTax(
      {this.id,
      this.taxId,
      this.branchId,
      this.rate,
      this.status,
      this.updatedAt,
      this.updatedBy,
      this.code});

  BranchTax.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    taxId = json['tax_id'];
    branchId = json['branch_id'];
    rate = json['rate'].toString();
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['tax_id'] = this.taxId;
    data['branch_id'] = this.branchId;
    data['rate'] = this.rate;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    data['code'] = this.code;
    return data;
  }
}
