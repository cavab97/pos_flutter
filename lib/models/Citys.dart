class Citys {
  int cityId;
  String name;
  String slug;
  int stateId;
  String createdAt;
  String updatedAt;
  String deletedAt;

  Citys(
      {this.cityId,
      this.name,
      this.slug,
      this.stateId,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  Citys.fromJson(Map<String, dynamic> json) {
    cityId = json['city_id'];
    name = json['name'];
    slug = json['slug'];
    stateId = json['state_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['city_id'] = this.cityId;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['state_id'] = this.stateId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}
