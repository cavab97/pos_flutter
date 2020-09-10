class CategoryAttribute {
  int caId;
  String uuid;
  String name;
  String slug;
  int status;
  String updatedAt;
  int updatedBy;

  CategoryAttribute(
      {this.caId,
      this.uuid,
      this.name,
      this.slug,
      this.status,
      this.updatedAt,
      this.updatedBy});

  CategoryAttribute.fromJson(Map<String, dynamic> json) {
    caId = json['ca_id'];
    uuid = json['uuid'];
    name = json['name'];
    slug = json['slug'];
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ca_id'] = this.caId;
    data['uuid'] = this.uuid;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}
