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
  static final String IS_CHECKIN = "Checkin";
  static final String IS_CHECKOUT = "Checkout";
  static final String SHIFT_ID = "Shift_Id";
  static final String DASH_SHIFT = "dashShift";
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
/*==============================================================================
                                  Error messages
  =================================================================================*/
  static final String VALID_TERMINAL_KEY = "Please enter terminal key";
}
