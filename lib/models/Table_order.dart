import 'package:deep_pick/deep_pick.dart';

class Table_order {
  int table_id;
  String is_merge_table;
  int merged_table_id;
  int number_of_pax;
  String table_seat;
  int save_order_id;
  String merged_pax;
  int table_locked_by;
  int is_order_merged;
  double service_charge;
  String assignTime;

  Table_order(
      {this.table_id,
      this.is_merge_table,
      this.merged_table_id,
      this.number_of_pax,
      this.table_seat,
      this.save_order_id,
      this.merged_pax,
      this.table_locked_by,
      this.is_order_merged,
      this.service_charge,
      this.assignTime});

  Table_order.fromJson(Map<String, dynamic> json) {
    table_id = pick(json, "table_id").asIntOrNull();
    is_merge_table = pick(json, "is_merge_table").asStringOrNull();
    merged_table_id = pick(json, "merged_table_id").asIntOrNull();
    number_of_pax = pick(json, "number_of_pax").asIntOrNull();
    table_seat = pick(json, "table_seat").asStringOrNull();
    save_order_id = pick(json, "save_order_id").asIntOrNull();
    merged_pax = pick(json, "merged_pax").asStringOrNull();
    table_locked_by = pick(json, "table_locked_by").asIntOrNull();
    is_order_merged = pick(json, "is_order_merge").asIntOrNull();
    service_charge = pick(json, "service_charge").asDoubleOrNull();
    assignTime = pick(json, "assing_time").asStringOrNull();
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
    data["service_charge"] = this.service_charge;
    data["assing_time"] = this.assignTime;
    return data;
  }
}
