class User {
  int id;
  String appId;
  String uuid;
  String name;
  String email;
  int role;
  String username;
  String countryCode;
  String mobile;
  String profile;
  String commisionPercent;
  int userPin;
  String apiToken;
  int status;
  int isAdmin;
  String deviceId;
  String deviceToken;
  String authKey;
  String lastLogin;
  String createdAt;
  String updatedAt;
  String deletedAt;
  int createdBy;
  int updatedBy;
  String deviceType;
  String deletedBy;
  String terminalId;

  User(
      {this.id,
      this.appId,
      this.uuid,
      this.name,
      this.email,
      this.role,
      this.username,
      this.countryCode,
      this.mobile,
      this.profile,
      this.commisionPercent,
      this.userPin,
      this.apiToken,
      this.status,
      this.isAdmin,
      this.deviceId,
      this.deviceToken,
      this.deviceType,
      this.authKey,
      this.lastLogin,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.createdBy,
      this.updatedBy,
      this.deletedBy,
      this.terminalId});

  User.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      appId = json['app_id'];
      uuid = json['uuid'];
      name = json['name'];
      email = json['email'];
      role = json['role'];
      username = json['username'];
      countryCode = json['country_code'];
      mobile = json['mobile'];
      profile = json['profile'];
      commisionPercent = json['commision_percent'];
      userPin = json['user_pin'];
      apiToken = json['api_token'];
      status = json['status'];
      isAdmin = json['is_admin'];
      deviceId = json['device_id'];
      deviceToken = json['device_token'];
      authKey = json['auth_key'];
      lastLogin = json['last_login'];
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
      deletedAt = json['deleted_at'];
      createdBy = json['created_by'];
      updatedBy = json['updated_by'];
      deletedBy = json['deleted_by'];
    } catch (e) {
      id = 0;
      appId = '';
      uuid = '';
      name = '';
      email = '';
      role = 0;
      username = '';
      countryCode = '';
      mobile = '';
      profile = '';
      commisionPercent = '';
      userPin = 0;
      apiToken = '';
      status = 0;
      isAdmin = 0;
      deviceId = '';
      deviceToken = '';
      authKey = '';
      lastLogin = '';
      createdAt = '';
      updatedAt = '';
      deletedAt = '';
      createdBy = 0;
      updatedBy = 0;
      deletedBy = '';
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['app_id'] = this.appId;
    data['uuid'] = this.uuid;
    data['name'] = this.name;
    data['email'] = this.email;
    data['role'] = this.role;
    data['username'] = this.username;
    data['country_code'] = this.countryCode;
    data['mobile'] = this.mobile;
    data['profile'] = this.profile;
    data['commision_percent'] = this.commisionPercent;
    data['user_pin'] = this.userPin;
    data['api_token'] = this.apiToken;
    data['status'] = this.status;
    data['is_admin'] = this.isAdmin;
    data['device_id'] = this.deviceId;
    data['device_token'] = this.deviceToken;
    data['auth_key'] = this.authKey;
    data['last_login'] = this.lastLogin;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['created_by'] = this.createdBy;
    data['updated_by'] = this.updatedBy;
    data['deleted_by'] = this.deletedBy;
    return data;
  }
}
