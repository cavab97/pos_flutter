class SetMealBranch {
  int setmealAttId;
  String uuid;
  int setmealId;
  int caId;
  int attributeId;
  double price;
  int status;
  String updatedAt;
  int updatedBy;

  SetMealBranch(
      {this.setmealAttId,
      this.uuid,
      this.setmealId,
      this.caId,
      this.attributeId,
      this.price,
      this.status,
      this.updatedAt,
      this.updatedBy});

  SetMealBranch.fromJson(Map<String, dynamic> json) {
    setmealAttId = json['setmeal_att_id'];
    uuid = json['uuid'];
    setmealId = json['setmeal_id'];
    caId = json['ca_id'];
    attributeId = json['attribute_id'];
    price = json['price'];
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['setmeal_att_id'] = this.setmealAttId;
    data['uuid'] = this.uuid;
    data['setmeal_id'] = this.setmealId;
    data['ca_id'] = this.caId;
    data['attribute_id'] = this.attributeId;
    data['price'] = this.attributeId;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}
