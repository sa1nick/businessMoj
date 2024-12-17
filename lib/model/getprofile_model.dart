// To parse this JSON data, do
//
//     final getProfileModel = getProfileModelFromJson(jsonString);

import 'dart:convert';

GetProfileModel getProfileModelFromJson(String str) => GetProfileModel.fromJson(json.decode(str));

String getProfileModelToJson(GetProfileModel data) => json.encode(data.toJson());

class GetProfileModel {
  int? id;
  dynamic name;
  String? fName;
  String? lName;
  String? phone;
  String? image;
  String? email;
  dynamic emailVerifiedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic streetAddress;
  dynamic age;
  dynamic gender;
  dynamic country;
  String? city;
  String? state;
  dynamic zipcode;
  dynamic houseNo;
  dynamic apartmentNo;
  dynamic cmFirebaseToken;
  int? isActive;
  dynamic paymentCardLastFour;
  dynamic paymentCardBrand;
  dynamic paymentCardFawryToken;
  dynamic loginMedium;
  dynamic socialId;
  int? isPhoneVerified;
  String? temporaryToken;
  int? isEmailVerified;
  int? walletBalance;
  dynamic loyaltyPoint;
  int? loginHitCount;
  int? isTempBlocked;
  dynamic tempBlockTime;
  String? referralCode;
  String? friendReferral;
  int? planStatus;
  dynamic planId;
  dynamic planExpireDate;
  int? dailyBonusAmount;
  dynamic referralBonus;
  int? repurchaseWallet;
  int? withdrawalWallet;
  int? isFrenchise;
  int? fundWallet;
  String? certificate;

  GetProfileModel({
    this.id,
    this.name,
    this.fName,
    this.lName,
    this.phone,
    this.image,
    this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.streetAddress,
    this.age,
    this.gender,
    this.country,
    this.city,
    this.state,
    this.zipcode,
    this.houseNo,
    this.apartmentNo,
    this.cmFirebaseToken,
    this.isActive,
    this.paymentCardLastFour,
    this.paymentCardBrand,
    this.paymentCardFawryToken,
    this.loginMedium,
    this.socialId,
    this.isPhoneVerified,
    this.temporaryToken,
    this.isEmailVerified,
    this.walletBalance,
    this.loyaltyPoint,
    this.loginHitCount,
    this.isTempBlocked,
    this.tempBlockTime,
    this.referralCode,
    this.friendReferral,
    this.planStatus,
    this.planId,
    this.planExpireDate,
    this.dailyBonusAmount,
    this.referralBonus,
    this.repurchaseWallet,
    this.withdrawalWallet,
    this.isFrenchise,
    this.fundWallet,
    this.certificate,
  });

  factory GetProfileModel.fromJson(Map<String, dynamic> json) => GetProfileModel(
    id: json["id"],
    name: json["name"],
    fName: json["f_name"],
    lName: json["l_name"],
    phone: json["phone"],
    image: json["image"],
    email: json["email"],
    emailVerifiedAt: json["email_verified_at"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    streetAddress: json["street_address"],
    age: json["age"],
    gender: json["gender"],
    country: json["country"],
    city: json["city"],
    state: json["state"],
    zipcode: json["zipcode"],
    houseNo: json["house_no"],
    apartmentNo: json["apartment_no"],
    cmFirebaseToken: json["cm_firebase_token"],
    isActive: json["is_active"],
    paymentCardLastFour: json["payment_card_last_four"],
    paymentCardBrand: json["payment_card_brand"],
    paymentCardFawryToken: json["payment_card_fawry_token"],
    loginMedium: json["login_medium"],
    socialId: json["social_id"],
    isPhoneVerified: json["is_phone_verified"],
    temporaryToken: json["temporary_token"],
    isEmailVerified: json["is_email_verified"],
    walletBalance: json["wallet_balance"],
    loyaltyPoint: json["loyalty_point"],
    loginHitCount: json["login_hit_count"],
    isTempBlocked: json["is_temp_blocked"],
    tempBlockTime: json["temp_block_time"],
    referralCode: json["referral_code"],
    friendReferral: json["friend_referral"],
    planStatus: json["plan_status"],
    planId: json["plan_id"],
    planExpireDate: json["plan_expire_date"],
    dailyBonusAmount: json["daily_bonus_amount"],
    referralBonus: json["referral_bonus"],
    repurchaseWallet: json["repurchase_wallet"],
    withdrawalWallet: json["withdrawal_wallet"],
    isFrenchise: json["is_frenchise"],
    fundWallet: json["fund_wallet"],
    certificate: json["certificate"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "f_name": fName,
    "l_name": lName,
    "phone": phone,
    "image": image,
    "email": email,
    "email_verified_at": emailVerifiedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "street_address": streetAddress,
    "age": age,
    "gender": gender,
    "country": country,
    "city": city,
    "state": state,
    "zipcode": zipcode,
    "house_no": houseNo,
    "apartment_no": apartmentNo,
    "cm_firebase_token": cmFirebaseToken,
    "is_active": isActive,
    "payment_card_last_four": paymentCardLastFour,
    "payment_card_brand": paymentCardBrand,
    "payment_card_fawry_token": paymentCardFawryToken,
    "login_medium": loginMedium,
    "social_id": socialId,
    "is_phone_verified": isPhoneVerified,
    "temporary_token": temporaryToken,
    "is_email_verified": isEmailVerified,
    "wallet_balance": walletBalance,
    "loyalty_point": loyaltyPoint,
    "login_hit_count": loginHitCount,
    "is_temp_blocked": isTempBlocked,
    "temp_block_time": tempBlockTime,
    "referral_code": referralCode,
    "friend_referral": friendReferral,
    "plan_status": planStatus,
    "plan_id": planId,
    "plan_expire_date": planExpireDate,
    "daily_bonus_amount": dailyBonusAmount,
    "referral_bonus": referralBonus,
    "repurchase_wallet": repurchaseWallet,
    "withdrawal_wallet": withdrawalWallet,
    "is_frenchise": isFrenchise,
    "fund_wallet": fundWallet,
    "certificate": certificate,
  };
}
