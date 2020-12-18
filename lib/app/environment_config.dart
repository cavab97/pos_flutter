class Config {
  static const WHERE_AM_I = "WHERE_AM_I";
  //backend
  static const SERVER_URL = "SERVER_URL";
  static const SERVER_ACCESS_TOKEN = "SERVER_ACCESS_TOKEN";

  static Map<String, dynamic> localConstants = {
    WHERE_AM_I: "local",
    //backend
    SERVER_URL: "http://localhost/pos/api/v1/en/",
    //SERVER_ACCESS_TOKEN: "lkriekxqo1w04rsxugfvijwcya3lth59"
  };

  static Map<String, dynamic> developmentConstants = {
    WHERE_AM_I: "development",
    //backend
    SERVER_URL: "https://development.mcnpos.com.my/api/v1/en/",
    //SERVER_ACCESS_TOKEN: "lkriekxqo1w04rsxugfvijwcya3lth59"
  };

  static Map<String, dynamic> stagingConstants = {
    WHERE_AM_I: "staging",
    //backend
    SERVER_URL: "https://staging.mcnpos.com.my/api/v1/en/",
    //SERVER_ACCESS_TOKEN: "lkriekxqo1w04rsxugfvijwcya3lth59"
  };

  static Map<String, dynamic> productionConstants = {
    WHERE_AM_I: "production",
    //backend
    SERVER_URL: "https://mcnpos.com.my/api/v1/en/",
    //SERVER_ACCESS_TOKEN: "lkriekxqo1w04rsxugfvijwcya3lth59"
  };
}
