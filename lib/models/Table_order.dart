class Table_order {
  int table_id;
  String is_merge_table;
  String merged_table_id;
  int number_of_pax;
  String table_seat;
  int save_order_id;
  String merged_pax;
  int table_locked_by;
  int is_order_merged;

  Table_order(
      {this.table_id,
      this.is_merge_table,
      this.merged_table_id,
      this.number_of_pax,
      this.table_seat,
      this.save_order_id,
      this.merged_pax,
      this.table_locked_by,
      this.is_order_merged});

  Table_order.fromJson(Map<String, dynamic> json) {
    table_id = json["table_id"];
    is_merge_table = json["is_merge_table"];
    merged_table_id = json["merged_table_id"];
    number_of_pax = json["number_of_pax"];
    table_seat = json["table_seat"];
    save_order_id = json["save_order_id"];
    merged_pax = json["merged_pax"];
    table_locked_by = json["table_locked_by"];
    is_order_merged = json["is_order_merge"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['table_id'] = this.table_id;
    data['is_merge_table'] = this.is_merge_table;
    data['merged_table_id'] = this.merged_table_id;
    data['number_of_pax'] = this.number_of_pax;
    data['table_seat'] = this.table_seat;
    data['save_order_id'] = this.save_order_id;
    data['merged_pax'] = this.merged_pax;
    data["table_locked_by"] = this.table_locked_by;
    data["is_order_merged"] = this.is_order_merged;
    return data;
  }
}
