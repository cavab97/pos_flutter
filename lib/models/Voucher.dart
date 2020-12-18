class Voucher {
  int voucherId;
  String uuid;
  String voucherName;
  String voucherBanner;
  String voucherCode;
  int voucherDiscountType;
  double voucherDiscount;
  double minimumAmount;
  double maximumAmount;
  int usesTotal;
  int usesCustomer;
  String voucherApplicableFrom;
  String voucherApplicableTo;
  String voucherCategories;
  String voucherProducts;
  int status;
  String updatedAt;
  int updatedBy;
  String deletedAt;
  int deletedBy;
  int totalUsed;

  Voucher(
      {this.voucherId,
      this.uuid,
      this.voucherName,
      this.voucherBanner,
      this.voucherCode,
      this.voucherDiscountType,
      this.voucherDiscount,
      this.minimumAmount,
      this.maximumAmount,
      this.usesTotal,
      this.usesCustomer,
      this.voucherApplicableFrom,
      this.voucherApplicableTo,
      this.voucherCategories,
      this.voucherProducts,
      this.status,
      this.updatedAt,
      this.updatedBy,
      this.deletedAt,
      this.deletedBy,
      this.totalUsed});

  Voucher.fromJson(Map<String, dynamic> json) {
    voucherId = json['voucher_id'];
    uuid = json['uuid'];
    voucherName = json['voucher_name'];
    voucherBanner = json['voucher_banner'];
    voucherCode = json['voucher_code'];
    voucherDiscountType = json['voucher_discount_type'];
    voucherDiscount = json['voucher_discount'] is int
        ? (json['voucher_discount'] as int).toDouble()
        : json['voucher_discount'];
    minimumAmount = json['minimum_amount'] is int
        ? (json['minimum_amount'] as int).toDouble()
        : json['minimum_amount'];
    maximumAmount = json['maximum_amount'] is int
        ? (json['maximum_amount'] as int).toDouble()
        : json['maximum_amount'];
    usesTotal = json['uses_total'];
    usesCustomer = json['uses_customer'];
    voucherApplicableFrom = json['voucher_applicable_from'];
    voucherApplicableTo = json['voucher_applicable_to'];
    voucherCategories = json['voucher_categories'];
    voucherProducts = json['voucher_products'];
    status = json['status'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    deletedAt = json['deleted_at'];
    deletedBy = json['deleted_by'];
    totalUsed = json["total_used"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['voucher_id'] = this.voucherId;
    data['uuid'] = this.uuid;
    data['voucher_name'] = this.voucherName;
    data['voucher_banner'] = this.voucherBanner;
    data['voucher_code'] = this.voucherCode;
    data['voucher_discount_type'] = this.voucherDiscountType;
    data['voucher_discount'] = this.voucherDiscount;
    data['minimum_amount'] = this.minimumAmount;
    data['maximum_amount'] = this.maximumAmount;
    data['uses_total'] = this.usesTotal;
    data['uses_customer'] = this.usesCustomer;
    data['voucher_applicable_from'] = this.voucherApplicableFrom;
    data['voucher_applicable_to'] = this.voucherApplicableTo;
    data['voucher_categories'] = this.voucherCategories;
    data['voucher_products'] = this.voucherProducts;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    data['deleted_at'] = this.deletedAt;
    data['deleted_by'] = this.deletedBy;
    data["total_used"] = this.totalUsed;
    return data;
  }
}
