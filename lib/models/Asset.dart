class Assets {
  int assetId;
  String uuid;
  int assetType;
  int assetTypeId;
  String assetPath;
  int status;
  String updatedAt;
  int updatedBy;
  String base64;

  Assets(
      {this.assetId,
      this.uuid,
      this.assetType,
      this.assetTypeId,
      this.assetPath,
      this.status,
      this.updatedAt,
      this.updatedBy,
      this.base64});

  Assets.fromJson(Map<String, dynamic> json) {
    assetId = json['asset_id'];
    uuid = json['uuid'];
    assetType = json['asset_type'];
    assetTypeId = json['asset_type_id'];
    assetPath = json['asset_path'];
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    base64 = json['base64'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['asset_id'] = this.assetId;
    data['uuid'] = this.uuid;
    data['asset_type'] = this.assetType;
    data['asset_type_id'] = this.assetTypeId;
    data['asset_path'] = this.assetPath;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    data['base64'] = this.base64;
    return data;
  }
}
