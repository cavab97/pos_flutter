class Attendace {
  String status;
  String message;
  List<AttendanceList> attendanceList;
  String date;
  Null branchId;
  String terminal;
  String inout;

  Attendace(
      {this.status,
      this.message,
      this.attendanceList,
      this.date,
      this.branchId,
      this.terminal,
      this.inout});

  Attendace.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['attendanceList'] != null) {
      attendanceList = new List<AttendanceList>();
      json['attendanceList'].forEach((v) {
        attendanceList.add(new AttendanceList.fromJson(v));
      });
    }
    date = json['date'];
    branchId = json['branch_id'];
    terminal = json['terminal'];
    inout = json['inout'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.attendanceList != null) {
      data['attendanceList'] =
          this.attendanceList.map((v) => v.toJson()).toList();
    }
    data['date'] = this.date;
    data['branch_id'] = this.branchId;
    data['terminal'] = this.terminal;
    data['inout'] = this.inout;
    return data;
  }
}

class AttendanceList {
  String employeeId;
  String branchId;
  String terminalId;
  String inOut;
  String inOutDatetime;
  String id;
  String bname;
  String uname;
  String tname;

  AttendanceList(
      {this.employeeId,
      this.branchId,
      this.terminalId,
      this.inOut,
      this.inOutDatetime,
      this.id,
      this.bname,
      this.uname,
      this.tname});

  AttendanceList.fromJson(Map<String, dynamic> json) {
    employeeId = json['employee_id'];
    branchId = json['branch_id'];
    terminalId = json['terminal_id'];
    inOut = json['in_out'];
    inOutDatetime = json['in_out_datetime'];
    id = json['id'];
    bname = json['bname'];
    uname = json['uname'];
    tname = json['tname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['employee_id'] = this.employeeId;
    data['branch_id'] = this.branchId;
    data['terminal_id'] = this.terminalId;
    data['in_out'] = this.inOut;
    data['in_out_datetime'] = this.inOutDatetime;
    data['id'] = this.id;
    data['bname'] = this.bname;
    data['uname'] = this.uname;
    data['tname'] = this.tname;
    return data;
  }
}