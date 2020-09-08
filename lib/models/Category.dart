class Category {
  int categoryId;
  String uuid;
  String name;
  String slug;
  String categoryIcon;
  int parentId;
  int isForWeb;
  int status;
  String updatedAt;
  int updatedBy;
  String deletedAt;
  int deletedBy;

  Category(
      {this.categoryId,
      this.uuid,
      this.name,
      this.slug,
      this.categoryIcon,
      this.parentId,
      this.isForWeb,
      this.status,
      this.updatedAt,
      this.updatedBy,
      this.deletedAt,
      this.deletedBy});

  Category.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
    uuid = json['uuid'];
    name = json['name'];
    slug = json['slug'];
    categoryIcon = json['category_icon'];
    parentId = json['parent_id'];
    isForWeb = json['is_for_web'];
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    deletedAt = json['deleted_at'];
    deletedBy = json['deleted_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_id'] = this.categoryId;
    data['uuid'] = this.uuid;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['category_icon'] = this.categoryIcon;
    data['parent_id'] = this.parentId;
    data['is_for_web'] = this.isForWeb;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    data['deleted_at'] = this.deletedAt;
    data['deleted_by'] = this.deletedBy;
    return data;
  }
}
