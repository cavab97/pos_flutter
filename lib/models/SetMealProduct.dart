class SetMealProduct {
  int setmealProductId;
  int setmealId;
  int productId;
  int quantity;
  int status;
  String createdAt;
  String updatedAt;

  SetMealProduct(
      {this.setmealProductId,
      this.setmealId,
      this.productId,
      this.quantity,
      this.status,
      this.createdAt,
      this.updatedAt});

  SetMealProduct.fromJson(Map<String, dynamic> json) {
    setmealProductId = json['setmeal_product_id'];
    setmealId = json['setmeal_id'];
    productId = json['product_id'];
    quantity = json['quantity'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['setmeal_product_id'] = this.setmealProductId;
    data['setmeal_id'] = this.setmealId;
    data['product_id'] = this.productId;
    data['quantity'] = this.quantity;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
