class SetMeal {
  int setmealId;
  String uuid;
  String name;
  int price;
  int status;
  String createdAt;
  int createdBy;
  String updatedAt;
  int updatedBy;

  SetMeal(
      {this.setmealId,
      this.uuid,
      this.name,
      this.price,
      this.status,
      this.createdAt,
      this.createdBy,
      this.updatedAt,
      this.updatedBy});

  SetMeal.fromJson(Map<String, dynamic> json) {
    setmealId = json['setmeal_id'];
    uuid = json['uuid'];
    name = json['name'];
    price = json['price'];
    status = json['status'];
    createdAt = json['created_at'];
    createdBy = json['created_by'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['setmeal_id'] = this.setmealId;
    data['uuid'] = this.uuid;
    data['name'] = this.name;
    data['price'] = this.price;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['created_by'] = this.createdBy;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}