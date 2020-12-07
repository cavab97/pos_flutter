/*Store all constant values here*/

class Constant {
  static final String NO_PREF_FOUND = "pref_not_found";
  static final String TERMINAL_KEY = "TerminalKey";
  static final String BRANCH_ID = "branchId";
  static final String LOIGN_USER = "Login_user";
  static final String IS_USER_LOGIN = "isUserLogin";
  static final String LAGUAGE_CODE = 'languageCode';
  static final String LastSync_Table = "LastSync_Table";
  static final String IS_SHIFT_OPEN = "IS_SHIFT_OPENE";
  static final String SERVER_DATE_TIME = "ServertDateTime";
  static final String ORDER_SERVER_DATE_TIME = "orderServerTime";
  static final String SERVER_TIME_ZONE = "ServertTimeZone";
  static final String TABLE_DATA = "table_id";
  static final String CUSTOMER_DATA = "customerData";
  static final String CUSTOMER_DATA_SPLIT = "customerDataSplit";
  static final String IS_CHECKIN = "Checkin";
  static final String IS_CHECKOUT = "Checkout";
  static final String SHIFT_ID = "Shift_Id";
  static final String DASH_SHIFT = "dashShift";
  static final String IS_LOGIN = "IsLogin";
  static final String MANAGER = "manager";
  static final String SYNC_TIMER = "syncTimer";
  static final String CURRENCY = "Currency";
  static final String OFFSET = "image_offset";
  // static final String USER_ROLE = "Roledata";
  static final String USER_PERMISSION = "user_permission";
  static final String IS_AUTO_SYNC = "is_Ayto_Sync";

  /*==============================================================================
                              Manage Permission  status
  =================================================================================*/

  static final String VIEW_ORDER = "view_order";
  static final String ADD_ORDER = "add_order";
  static final String EDIT_ORDER = "edit_order";
  static final String DELETE_ORDER = "delete_order";

  static final String VIEW_ITEM = "view_item";
  static final String ADD_ITEM = "add_item";
  static final String EDIT_ITEM = "edit_item";
  static final String DELETE_ITEM = "delete_item";
  static final String DISCOUNT_ITEM = "discount_item";

  static final String VIEW_REPORT = "view_report";
  static final String ADD_REPORT = "add_report";
  static final String EDIT_REPORT = "edit_report";
  static final String DELETE_REPORT = "delete_report";
  static final String OPEN_DRAWER = "view_open_drawer";
  static final String PRINT_RECIEPT = "view_printing";
  static final String VIEW_SYNC = "view_sync";
  /*==============================================================================
                              Manage API status
  =================================================================================*/
  static final int STATUS200 = 200; //For success response
  static final int STATUS422 = 422; //Validation or not exists data
  static final int STATUS500 = 500; //Ooops something wrong
  static final int STATUS5401 = 401; //Authentication failed

/*==============================================================================
                           Screen name for navigation
  =================================================================================*/
  static final String LoginScreen = "/Login";
  static final String PINScreen = "/PINPage";
  static final String DashboardScreen = "/Dashboard";
  static final String TransactionScreen = "/TansactionsPage";
  static final String TerminalScreen = "/TerminalKeyPage";
  static final String SelectTableScreen = "/TableSelection";
  static final String SettingsScreen = "/Settings";
  static final String WebOrderPages = "/WebOrders";
  static final String ShiftOrders = "/ShiftReport";
  static final String WineStorage = "/WineStorage";
  static final String OutOfStock = "/OutOfStock";

  /************************Just for identify on navigation*********************************/
  static final String dashboard = "dashboard";
  static final String splitbill = "splitbill";

/*==============================================================================
                                  Error messages
  =================================================================================*/
  static final String VALID_TERMINAL_KEY = "Please enter terminal key";
}
