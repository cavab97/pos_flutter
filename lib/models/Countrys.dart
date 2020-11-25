class Countrys {
  int countryId;
  String sortname;
  String name;
  String slug;
  int phoneCode;
  String createdAt;
  String updatedAt;
  String deletedAt;

  Countrys(
      {this.countryId,
      this.sortname,
      this.name,
      this.slug,
      this.phoneCode,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  Countrys.fromJson(Map<String, dynamic> json) {
    countryId = json['country_id'];
    sortname = json['sortname'];
    name = json['name'];
    slug = json['slug'];
    phoneCode = json['phoneCode'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['country_id'] = this.countryId;
    data['sortname'] = this.sortname;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['phoneCode'] = this.phoneCode;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}