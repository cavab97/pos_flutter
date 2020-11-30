class ColorTable {
  int id;
  String uuid;
  double timeMinute;
  String colorCode;
  int status;
  String updatedAt;
  int updatedBy;

  ColorTable(
      {this.id,
      this.uuid,
      this.timeMinute,
      this.colorCode,
      this.status,
      this.updatedAt,
      this.updatedBy});

  ColorTable.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    timeMinute = json['time_minute'] is String
        ? double.parse(json['time_minute'])
        : json['time_minute'];
    colorCode = json['color_code'];
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uuid'] = this.uuid;
    data['time_minute'] = this.timeMinute;
    data['color_code'] = this.colorCode;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}
