class Attributes {
  int attributeId;
  String uuid;
  int caId;
  String name;
  int isDefault;
  int status;
  String updatedAt;
  int updatedBy;
  String deletedAt;
  int deletedBy;

  Attributes(
      {this.attributeId,
      this.uuid,
      this.caId,
      this.name,
      this.isDefault,
      this.status,
      this.updatedAt,
      this.updatedBy,
      this.deletedAt,
      this.deletedBy});

  Attributes.fromJson(Map<String, dynamic> json) {
    attributeId = json['attribute_id'];
    uuid = json['uuid'];
    caId = json['ca_id'];
    name = json['name'];
    isDefault = json['is_default'];
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    deletedAt = json['deleted_at'];
    deletedBy = json['deleted_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['attribute_id'] = this.attributeId;
    data['uuid'] = this.uuid;
    data['ca_id'] = this.caId;
    data['name'] = this.name;
    data['is_default'] = this.isDefault;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    data['deleted_at'] = this.deletedAt;
    data['deleted_by'] = this.deletedBy;
    return data;
  }
}
