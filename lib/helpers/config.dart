import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/app/environment_config.dart';

class Configrations {
  //static String base_URL = "http://mcnpos.dailybills.in/public/api/v1/en/";
  static String base_URL =
      "http://staging.mcnpos.com.my/api/v1/en/"; //Config.SERVER_URL
  static String terminalKey = "verifyTerminalkey";
  static String login = "login";
  static String config = "configs";
  static String synch_table = "synch-table";
  static String appdata1 = "branch-user-role-datatable";
  static String appdata2_1 = "product-category-datatable";
  static String appdata2_2 = "product-variant-datatable";
  static String appdata2_3 = "printer-price-type-datatable";
  static String appdata3 = "customer-terminal-payment-datatable";
  static String appdata4_1 = "order-datatable";
  static String appdata4_2 = "shift-datatable";
  static String product_image = "productimage";
  static String order_sync = "create-order-data";
  static String web_orders = "web-order-table-data";
  static String cancle_order = "create-cancel-order-data";
  static String update_inventory_table = "update-product-inventory-data";
  static String products = "Products";
  static String categories = "Categories";
  static String printers = "printer";
  static String printersForCart = "printer_cart";
  static String search_product = "Search_product";
  static String search_setmeal = "Search_setmeal";
  static String customers = "Customers";
  static String add_customer = "Add_Customer";
  static String customer_redeem = "customer_redeem";
  static String get_addresses = "get_addresses";
  static String add_saveOrder = "Add_SaveOrder";
  static String add_cart = "Add_cart";
  static String tables = "Tables";
  static String add_table_order = "Add_Table_Order";
  static String add_shift = "Add_shift";
  static String drawer_data = "drawer_data";
  static String add_drawer = "add_drawer";
  static String shift_datails = "Shift_datails";
  static String shift_app_id = "shift_app_id";
  static String shift_Invoice_app_id = "shift_Invoice_app_id";
  static String product_attributes = "Product_attributes";
  static String product_Modifeirs = "Product_modifires";
  static String cart_Details = "Cart_Details";
  static String cart_Sub_Details = "Cart_Sub_Details";
  static String cart_items = "Cart_Items";
  static String checkIn_Out = "checkIn_Out";
  static String get_Cart_id = "get_Cart_id";
  static String table_Details = "table_Details";
  static String table_orders = "table_orders";
  static String merge_table_order = "merge_table_order";
  static String change_table = "change_table";
  static String cart_data = "cart_data";
  static String payment_Methods = "payment_Methods";
  static String get_order = "get_order";
  static String getLastids = "getLastOrderids";
  static String place_order = "place_order";
  static String delete_cart_item = "delete_cart_item";
  static String clearCart = "clear_cart";
  static String product_modifire = "product_modifire";
  static String order_details = "order_details";
  static String order_payment_details = "order_payment_details";
  static String update_cart = "update_cart";
  static String update_cart_items = "update_cart_items";
  static String branch_detail = "branch_detail";
  static String order_payment_method = "order_payment_method";
  static String orders_list = "order_List";
  static String send_to_kitchen = "send_to_kitchen";
  static String set_meals = "set_meals";
  static String branch_tax = "branch_tax";
  static String terminal_data = "terminal_data";
  static String set_meals_products = "set_meals_products";
  static String check_voucher = "check_voucher";
  static String add_voucher = "add_voucher";
  static String store_inv_data = "store_inv_data";
  static String update_order_status = "update_order_status";
  static String last_wine_int_log_id = "last_wine_int_log_id";
  static String remove_cart = "remove_cart";
  static String check_item_into_store = "check_item_into_store";
  static String cart_list = "cart_list";
  static String setmealData = "setmeal_Data";
  static String productData = "product_Data";
  static String rac_data = "rac_data";
  static String box_list = "box_list";
  static ipAddress() async {
    return await Preferences.getStringValuesSF(Constant.SERVER_IP);
  }

  static String country_state_city_datatable = "country-state-city-datatable";
  static String create_customer_data = "create-customer-data";
  static String rac_box_liquor_inventor_datatable =
      "rac-box-liquor-inventory-datatable";
  static String update_customer_liquor_inventory_data =
      "update-customer-liquor-inventory-data";
  static String createShiftdata = "create-shift-detail-data";
  static String order_data = "order_data";
  static String product_details = "product_details";
  static String lastcustomer_id = "last_customer";
  static String add_foc_product = "add_foc_product";
  static String get_modifires = "get_modifires";
  static String get_user_permission = "get_user_permission";
  static String cancel_order = "cancel_order";
}
