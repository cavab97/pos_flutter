class States {
  int stateId;
  String name;
  String slug;
  int countryId;
  String createdAt;
  String updatedAt;
  String deletedAt;

  States(
      {this.stateId,
      this.name,
      this.slug,
      this.countryId,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  States.fromJson(Map<String, dynamic> json) {
    stateId = json['state_id'];
    name = json['name'];
    slug = json['slug'];
    countryId = json['country_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['state_id'] = this.stateId;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['country_id'] = this.countryId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}