class Modifier {
  int modifierId;
  String uuid;
  String name;
  int isDefault;
  int status;
  String updatedAt;
  int updatedBy;
  String deletedAt;
  int deletedBy;

  Modifier(
      {this.modifierId,
      this.uuid,
      this.name,
      this.isDefault,
      this.status,
      this.updatedAt,
      this.updatedBy,
      this.deletedAt,
      this.deletedBy});

  Modifier.fromJson(Map<String, dynamic> json) {
    modifierId = json['modifier_id'];
    uuid = json['uuid'];
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
    data['modifier_id'] = this.modifierId;
    data['uuid'] = this.uuid;
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
