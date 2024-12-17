class UserModel {
  String? name;
  String? fName;
  String? lName;
  String? email;
  String? phone;
  int? isActive;
  String? temporaryToken;
  String? referralCode;
  String? city;
  String? state;
  int? walletBalance;
  String? friendReferral;
  String? cmFirebaseToken;
  String? updatedAt;
  String? createdAt;
  int? id;
  int? planStatus;
  dynamic? planId;
  dynamic? planExpireDate;

  UserModel(
      {this.name,
        this.fName,
        this.lName,
        this.email,
        this.phone,
        this.isActive,
        this.temporaryToken,
        this.referralCode,
        this.city,
        this.state,
        this.walletBalance,
        this.friendReferral,
        this.cmFirebaseToken,
        this.updatedAt,
        this.createdAt,
        this.planStatus,
        this.planId,
        this.planExpireDate,
        this.id});

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    fName = json['f_name'];
    lName = json['l_name'];
    email = json['email'];
    phone = json['phone'];
    isActive = json['is_active'];
    temporaryToken = json['temporary_token'];
    referralCode = json['referral_code'];
    city = json['city'];
    state = json['state'];
    walletBalance = json['wallet_balance'];
    friendReferral = json['friend_referral'];
    cmFirebaseToken = json['cm_firebase_token'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    planStatus = json['plan_status'];
    planId = json['plan_id'];
    planExpireDate = json['plan_expire_date'];

    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['email'] = email;
    data['phone'] = phone;
    data['is_active'] = isActive;
    data['temporary_token'] = temporaryToken;
    data['referral_code'] = referralCode;
    data['city'] = city;
    data['state'] = state;
    data['wallet_balance'] = walletBalance;
    data['friend_referral'] = friendReferral;
    data['cm_firebase_token'] = cmFirebaseToken;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    data['id'] = id;
    data['plan_status'] = planStatus;
    data['plan_id'] = planId;
    data['plan_expire_date'] = planExpireDate;
    return data;
  }
}
