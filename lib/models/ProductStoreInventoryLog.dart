class ProductStoreInventoryLog {
  int il_id;
  String uuid;
  int inventory_id;
  int branch_id;
  int product_id;
  int employe_id;
  int il_type;
  double qty;
  double qty_before_change;
  double qty_after_change;
  String updated_at;
  int updated_by;

  ProductStoreInventoryLog({
    this.il_id,
    this.uuid,
    this.inventory_id,
    this.branch_id,
    this.product_id,
    this.employe_id,
    this.il_type,
    this.qty,
    this.qty_before_change,
    this.qty_after_change,
    this.updated_at,
    this.updated_by,
  });

  ProductStoreInventoryLog.fromJson(Map<String, dynamic> json) {
    il_id = json["il_id"];
    uuid = json["uuid"];
    inventory_id = json["inventory_id"];
    branch_id = json["branch_id"];
    product_id = json["product_id"];
    employe_id = json["employe_id"];
    il_type = json["il_type"];
    qty = json["qty"];
    qty_before_change = json["qty_before_change"];
    qty_after_change = json["qty_after_change"];
    updated_at = json["updated_at"];
    updated_by = json["updated_by"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["il_id"] = this.il_id;
    data["uuid"] = this.uuid;
    data["inventory_id"] = this.inventory_id;
    data["branch_id"] = this.branch_id;
    data["product_id"] = this.product_id;
    data["employe_id"] = this.employe_id;
    data["il_type"] = this.il_type;
    data["qty"] = this.qty;
    data["qty_before_change"] = this.qty_before_change;
    data["qty_after_change"] = this.qty_after_change;
    data["updated_at"] = this.updated_at;
    data["updated_by"] = this.updated_by;
    return data;
  }
}
