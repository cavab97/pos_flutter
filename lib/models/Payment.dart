class Payments {
  int paymentId;
  String uuid;
  String name;
  String slug;
  int status;
  int isParent;
  String updatedAt;
  int updatedBy;

  Payments(
      {this.paymentId,
      this.uuid,
      this.name,
      this.slug,
      this.status,
      this.isParent,
      this.updatedAt,
      this.updatedBy});

  Payments.fromJson(Map<String, dynamic> json) {
    paymentId = json['payment_id'];
    uuid = json['uuid'];
    name = json['name'];
    slug = json['slug'];
    status = json['status'];
    isParent = json['is_parent'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['payment_id'] = this.paymentId;
    data['uuid'] = this.uuid;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['status'] = this.status;
    data['is_parent'] = this.isParent;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}