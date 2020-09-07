class TemimalKey {
  int status;
  bool show;
  String message;
  int terminalId;
  String terminalKey;
  String deviceid;

  TemimalKey({this.status, this.show, this.message, this.terminalId});

  TemimalKey.fromJson(Map<String, dynamic> json) {
    try {
      status = json['status'];
      show = json['show'];
      message = json['message'];
      terminalId = json['terminal_id'];
    } catch (e) {
      status = 0;
      show = false;
      message = "error";
      terminalId = 0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['show'] = this.show;
    data['message'] = this.message;
    data['terminal_id'] = this.terminalId;
    return data;
  }
}
