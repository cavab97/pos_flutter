class Pricetype {
  int ptId;
  String uuid;
  String name;
  int status;
  String updatedAt;
  int updatedBy;
  Null deletedAt;
  Null deletedBy;

  Pricetype(
      {this.ptId,
      this.uuid,
      this.name,
      this.status,
      this.updatedAt,
      this.updatedBy,
      this.deletedAt,
      this.deletedBy});

  Pricetype.fromJson(Map<String, dynamic> json) {
    ptId = json['pt_id'];
    uuid = json['uuid'];
    name = json['name'];
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    deletedAt = json['deleted_at'];
    deletedBy = json['deleted_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pt_id'] = this.ptId;
    data['uuid'] = this.uuid;
    data['name'] = this.name;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    data['deleted_at'] = this.deletedAt;
    data['deleted_by'] = this.deletedBy;
    return data;
  }
}
