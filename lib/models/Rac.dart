class Rac {
  int racId;
  String uuid;
  int branchId;
  String name;
  String slug;
  int status;
  String updatedAt;
  int updatedBy;

  Rac(
      {this.racId,
      this.uuid,
      this.branchId,
      this.name,
      this.slug,
      this.status,
      this.updatedAt,
      this.updatedBy});

  Rac.fromJson(Map<String, dynamic> json) {
    racId = json['rac_id'];
    uuid = json['uuid'];
    branchId = json['branch_id'];
    name = json['name'];
    slug = json['slug'];
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rac_id'] = this.racId;
    data['uuid'] = this.uuid;
    data['branch_id'] = this.branchId;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}