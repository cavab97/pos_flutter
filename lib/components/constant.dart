/*Store all constant values here*/

class Constant {

  static final String NO_PREF_FOUND = "pref_not_found";
  static final String TERMINAL_KEY = "TerminalKey";
  static final String LOIGN_USER = "Login_user";
  static final String LAGUAGE_CODE = 'languageCode';
  static final String LastSync_Table = "LastSync_Table";

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
 static final String  SelectTableScreen  = "/TableSelection";

/*==============================================================================
                                  Error messages
  =================================================================================*/
  static final String VALID_TERMINAL_KEY = "Please enter terminal key";
}
