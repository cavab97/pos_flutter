class Customer {
  int customerId;
  String uuid;
  int appId;
  int terminalId;
  String firstName;
  String lastName;
  String name;
  String username;
  String email;
  int role;
  int serverId;
  int phonecode;
  String mobile;
  String password;
  String address;
  int countryId;
  int stateId;
  int cityId;
  String zipcode;
  String apiToken;
  String profile;
  String lastLogin;
  int status;
  String createdAt;
  String updatedAt;
  String deletedAt;
  int createdBy;
  int updatedBy;
  int deletedBy;

  Customer(
      {this.customerId,
      this.uuid,
      this.appId,
      this.terminalId,
      this.firstName,
      this.lastName,
      this.name,
      this.username,
      this.email,
      this.role,
      this.phonecode,
      this.mobile,
      this.password,
      this.address,
      this.serverId,
      this.countryId,
      this.stateId,
      this.cityId,
      this.zipcode,
      this.apiToken,
      this.profile,
      this.lastLogin,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.createdBy,
      this.updatedBy,
      this.deletedBy});

  Customer.fromJson(Map<String, dynamic> json) {
    customerId = json['customer_id'];
    uuid = json['uuid'];
    appId = json['app_id'] != "" ? json['app_id'] : 0;
    terminalId = json['terminal_id'] != "" ? json['terminal_id'] : 0;
    firstName = json['first_name'];
    lastName = json['last_name'];
    name = json['name'];
    username = json['username'];
    email = json['email'];
    role = json['role'] != "" ? json['role'] : 0;
    phonecode = json['phonecode'] != "" ? json['role'] : 0;
    mobile = json['mobile'];
    password = json['password'];
    address = json['address'];
    countryId = json['country_id'] != "" ? json['country_id'] : 0;
    stateId = json['state_id'] != "" ? json['state_id'] : 0;
    cityId = json['city_id'] != "" ? json['city_id'] : 0;
    serverId = json["server_id"];
    zipcode = json['zipcode'];
    apiToken = json['api_token'];
    profile = json['profile'];
    lastLogin = json['last_login'];
    status = json['status'] != "" ? json['status'] : 0;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    createdBy = json['created_by'] != "" ? json['created_by'] : 0;
    updatedBy = json['updated_by'] != "" ? json['updated_by'] : 0;
    deletedBy = json['deleted_by'] != "" ? json['deleted_by'] : 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['customer_id'] = this.customerId;
    data['uuid'] = this.uuid;
    data['app_id'] = this.appId;
    data['terminal_id'] = this.terminalId;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['name'] = this.name;
    data['username'] = this.username;
    data['email'] = this.email;
    data['role'] = this.role;
    data['phonecode'] = this.phonecode;
    data['mobile'] = this.mobile;
    data['password'] = this.password;
    data['address'] = this.address;
    data['country_id'] = this.countryId;
    data['state_id'] = this.stateId;
    data['city_id'] = this.cityId;
    data["server_id"] = this.serverId;
    data['zipcode'] = this.zipcode;
    data['api_token'] = this.apiToken;
    data['profile'] = this.profile;
    data['last_login'] = this.lastLogin;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['created_by'] = this.createdBy;
    data['updated_by'] = this.updatedBy;
    data['deleted_by'] = this.deletedBy;
    return data;
  }
}
