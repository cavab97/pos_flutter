class SetMealBranch {
  int setmealBranchId;
  String uuid;
  int setmealId;
  int branchId;
  int status;
  String updatedAt;
  int updatedBy;

  SetMealBranch(
      {this.setmealBranchId,
      this.uuid,
      this.setmealId,
      this.branchId,
      this.status,
      this.updatedAt,
      this.updatedBy});

  SetMealBranch.fromJson(Map<String, dynamic> json) {
    setmealBranchId = json['setmeal_branch_id'];
    uuid = json['uuid'];
    setmealId = json['setmeal_id'];
    branchId = json['branch_id'];
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['setmeal_branch_id'] = this.setmealBranchId;
    data['uuid'] = this.uuid;
    data['setmeal_id'] = this.setmealId;
    data['branch_id'] = this.branchId;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}