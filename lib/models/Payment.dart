class Payments {
  int paymentId;
  String uuid;
  String name;
  int status;
  String updatedAt;
  int updatedBy;

  Payments(
      {this.paymentId,
      this.uuid,
      this.name,
      this.status,
      this.updatedAt,
      this.updatedBy});

  Payments.fromJson(Map<String, dynamic> json) {
    paymentId = json['payment_id'];
    uuid = json['uuid'];
    name = json['name'];
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['payment_id'] = this.paymentId;
    data['uuid'] = this.uuid;
    data['name'] = this.name;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}