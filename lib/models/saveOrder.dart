class SaveOrder {
  int id;
  int cartId;
  String orderName;
  int numberofPax;
  int isTableOrder;
  String createdAt;

  SaveOrder({
    this.id,
    this.cartId,
    this.orderName,
    this.numberofPax,
    this.isTableOrder,
    this.createdAt,
  });

  SaveOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cartId = json['cart_id'];
    orderName = json['order_Name'];
    numberofPax = json['number_of_pax'];
    isTableOrder = json['is_table_order'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data["id"] = this.id;
    data["cart_id"] = this.cartId;
    data["order_Name"] = this.orderName;
    data["number_of_pax"] = this.numberofPax;
    data["is_table_order"] = this.isTableOrder;
    data["created_at"] = this.createdAt;
    return data;
  }
}
