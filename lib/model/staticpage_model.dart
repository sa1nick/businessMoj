// To parse this JSON data, do
//
//     final staticPageModel = staticPageModelFromJson(jsonString);

import 'dart:convert';

StaticPageModel staticPageModelFromJson(String str) => StaticPageModel.fromJson(json.decode(str));

String staticPageModelToJson(StaticPageModel data) => json.encode(data.toJson());

class StaticPageModel {
  String? brandSetting;
  String? digitalProductSetting;
  int? systemDefaultCurrency;
  bool? digitalPayment;
  bool? cashOnDelivery;
  String? sellerRegistration;
  String? posActive;
  String? companyPhone;
  String? companyEmail;
  String? companyLogo;
  dynamic deliveryCountryRestriction;
  dynamic deliveryZipCodeAreaRestriction;
  BaseUrls? baseUrls;
  StaticUrls? staticUrls;
  String? aboutUs;
  String? privacyPolicy;
  List<Faq>? faq;
  String? termsConditions;
  Policy? refundPolicy;
  Policy? returnPolicy;
  Policy? cancellationPolicy;
  List<CurrencyList>? currencyList;
  String? currencySymbolPosition;
  String? businessMode;
  bool? maintenanceMode;
  List<Language>? language;
  List<Color>? colors;
  List<String>? unit;
  String? shippingMethod;
  bool? emailVerification;
  bool? phoneVerification;
  String? countryCode;
  List<SocialLogin>? socialLogin;
  String? currencyModel;
  String? forgotPasswordVerification;
  Announcement? announcement;
  dynamic pixelAnalytics;
  String? softwareVersion;
  int? decimalPointSettings;
  String? inhouseSelectedShippingType;
  int? billingInputByCustomer;
  int? minimumOrderLimit;
  int? walletStatus;
  int? loyaltyPointStatus;
  int? loyaltyPointExchangeRate;
  int? loyaltyPointMinimumPoint;
  Map<String, bool>? paymentMethods;

  StaticPageModel({
    this.brandSetting,
    this.digitalProductSetting,
    this.systemDefaultCurrency,
    this.digitalPayment,
    this.cashOnDelivery,
    this.sellerRegistration,
    this.posActive,
    this.companyPhone,
    this.companyEmail,
    this.companyLogo,
    this.deliveryCountryRestriction,
    this.deliveryZipCodeAreaRestriction,
    this.baseUrls,
    this.staticUrls,
    this.aboutUs,
    this.privacyPolicy,
    this.faq,
    this.termsConditions,
    this.refundPolicy,
    this.returnPolicy,
    this.cancellationPolicy,
    this.currencyList,
    this.currencySymbolPosition,
    this.businessMode,
    this.maintenanceMode,
    this.language,
    this.colors,
    this.unit,
    this.shippingMethod,
    this.emailVerification,
    this.phoneVerification,
    this.countryCode,
    this.socialLogin,
    this.currencyModel,
    this.forgotPasswordVerification,
    this.announcement,
    this.pixelAnalytics,
    this.softwareVersion,
    this.decimalPointSettings,
    this.inhouseSelectedShippingType,
    this.billingInputByCustomer,
    this.minimumOrderLimit,
    this.walletStatus,
    this.loyaltyPointStatus,
    this.loyaltyPointExchangeRate,
    this.loyaltyPointMinimumPoint,
    this.paymentMethods,
  });

  factory StaticPageModel.fromJson(Map<String, dynamic> json) => StaticPageModel(
    brandSetting: json["brand_setting"],
    digitalProductSetting: json["digital_product_setting"],
    systemDefaultCurrency: json["system_default_currency"],
    digitalPayment: json["digital_payment"],
    cashOnDelivery: json["cash_on_delivery"],
    sellerRegistration: json["seller_registration"],
    posActive: json["pos_active"],
    companyPhone: json["company_phone"].toString(),
    companyEmail: json["company_email"],
    companyLogo: json["company_logo"],
    deliveryCountryRestriction: json["delivery_country_restriction"],
    deliveryZipCodeAreaRestriction: json["delivery_zip_code_area_restriction"],
    baseUrls: json["base_urls"] == null ? null : BaseUrls.fromJson(json["base_urls"]),
    staticUrls: json["static_urls"] == null ? null : StaticUrls.fromJson(json["static_urls"]),
    aboutUs: json["about_us"],
    privacyPolicy: json["privacy_policy"],
    faq: json["faq"] == null ? [] : List<Faq>.from(json["faq"]!.map((x) => Faq.fromJson(x))),
    termsConditions: json["terms_&_conditions"],
    refundPolicy: json["refund_policy"] == null ? null : Policy.fromJson(json["refund_policy"]),
    returnPolicy: json["return_policy"] == null ? null : Policy.fromJson(json["return_policy"]),
    cancellationPolicy: json["cancellation_policy"] == null ? null : Policy.fromJson(json["cancellation_policy"]),
    currencyList: json["currency_list"] == null ? [] : List<CurrencyList>.from(json["currency_list"]!.map((x) => CurrencyList.fromJson(x))),
    currencySymbolPosition: json["currency_symbol_position"],
    businessMode: json["business_mode"],
    maintenanceMode: json["maintenance_mode"],
    language: json["language"] == null ? [] : List<Language>.from(json["language"]!.map((x) => Language.fromJson(x))),
    colors: json["colors"] == null ? [] : List<Color>.from(json["colors"]!.map((x) => Color.fromJson(x))),
    unit: json["unit"] == null ? [] : List<String>.from(json["unit"]!.map((x) => x)),
    shippingMethod: json["shipping_method"],
    emailVerification: json["email_verification"],
    phoneVerification: json["phone_verification"],
    countryCode: json["country_code"],
    socialLogin: json["social_login"] == null ? [] : List<SocialLogin>.from(json["social_login"]!.map((x) => SocialLogin.fromJson(x))),
    currencyModel: json["currency_model"],
    forgotPasswordVerification: json["forgot_password_verification"],
    announcement: json["announcement"] == null ? null : Announcement.fromJson(json["announcement"]),
    pixelAnalytics: json["pixel_analytics"],
    softwareVersion: json["software_version"],
    decimalPointSettings: json["decimal_point_settings"],
    inhouseSelectedShippingType: json["inhouse_selected_shipping_type"],
    billingInputByCustomer: json["billing_input_by_customer"],
    minimumOrderLimit: json["minimum_order_limit"],
    walletStatus: json["wallet_status"],
    loyaltyPointStatus: json["loyalty_point_status"],
    loyaltyPointExchangeRate: json["loyalty_point_exchange_rate"],
    loyaltyPointMinimumPoint: json["loyalty_point_minimum_point"],
    paymentMethods: Map.from(json["payment_methods"]!).map((k, v) => MapEntry<String, bool>(k, v)),
  );

  Map<String, dynamic> toJson() => {
    "brand_setting": brandSetting,
    "digital_product_setting": digitalProductSetting,
    "system_default_currency": systemDefaultCurrency,
    "digital_payment": digitalPayment,
    "cash_on_delivery": cashOnDelivery,
    "seller_registration": sellerRegistration,
    "pos_active": posActive,
    "company_phone": companyPhone,
    "company_email": companyEmail,
    "company_logo": companyLogo,
    "delivery_country_restriction": deliveryCountryRestriction,
    "delivery_zip_code_area_restriction": deliveryZipCodeAreaRestriction,
    "base_urls": baseUrls?.toJson(),
    "static_urls": staticUrls?.toJson(),
    "about_us": aboutUs,
    "privacy_policy": privacyPolicy,
    "faq": faq == null ? [] : List<dynamic>.from(faq!.map((x) => x.toJson())),
    "terms_&_conditions": termsConditions,
    "refund_policy": refundPolicy?.toJson(),
    "return_policy": returnPolicy?.toJson(),
    "cancellation_policy": cancellationPolicy?.toJson(),
    "currency_list": currencyList == null ? [] : List<dynamic>.from(currencyList!.map((x) => x.toJson())),
    "currency_symbol_position": currencySymbolPosition,
    "business_mode": businessMode,
    "maintenance_mode": maintenanceMode,
    "language": language == null ? [] : List<dynamic>.from(language!.map((x) => x.toJson())),
    "colors": colors == null ? [] : List<dynamic>.from(colors!.map((x) => x.toJson())),
    "unit": unit == null ? [] : List<dynamic>.from(unit!.map((x) => x)),
    "shipping_method": shippingMethod,
    "email_verification": emailVerification,
    "phone_verification": phoneVerification,
    "country_code": countryCode,
    "social_login": socialLogin == null ? [] : List<dynamic>.from(socialLogin!.map((x) => x.toJson())),
    "currency_model": currencyModel,
    "forgot_password_verification": forgotPasswordVerification,
    "announcement": announcement?.toJson(),
    "pixel_analytics": pixelAnalytics,
    "software_version": softwareVersion,
    "decimal_point_settings": decimalPointSettings,
    "inhouse_selected_shipping_type": inhouseSelectedShippingType,
    "billing_input_by_customer": billingInputByCustomer,
    "minimum_order_limit": minimumOrderLimit,
    "wallet_status": walletStatus,
    "loyalty_point_status": loyaltyPointStatus,
    "loyalty_point_exchange_rate": loyaltyPointExchangeRate,
    "loyalty_point_minimum_point": loyaltyPointMinimumPoint,
    "payment_methods": Map.from(paymentMethods!).map((k, v) => MapEntry<String, dynamic>(k, v)),
  };
}

class Announcement {
  dynamic status;
  dynamic color;
  dynamic textColor;
  dynamic announcement;

  Announcement({
    this.status,
    this.color,
    this.textColor,
    this.announcement,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
    status: json["status"],
    color: json["color"],
    textColor: json["text_color"],
    announcement: json["announcement"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "color": color,
    "text_color": textColor,
    "announcement": announcement,
  };
}

class BaseUrls {
  String? productImageUrl;
  String? productThumbnailUrl;
  String? digitalProductUrl;
  String? brandImageUrl;
  String? customerImageUrl;
  String? bannerImageUrl;
  String? categoryImageUrl;
  String? reviewImageUrl;
  String? sellerImageUrl;
  String? shopImageUrl;
  String? notificationImageUrl;
  String? deliveryManImageUrl;

  BaseUrls({
    this.productImageUrl,
    this.productThumbnailUrl,
    this.digitalProductUrl,
    this.brandImageUrl,
    this.customerImageUrl,
    this.bannerImageUrl,
    this.categoryImageUrl,
    this.reviewImageUrl,
    this.sellerImageUrl,
    this.shopImageUrl,
    this.notificationImageUrl,
    this.deliveryManImageUrl,
  });

  factory BaseUrls.fromJson(Map<String, dynamic> json) => BaseUrls(
    productImageUrl: json["product_image_url"],
    productThumbnailUrl: json["product_thumbnail_url"],
    digitalProductUrl: json["digital_product_url"],
    brandImageUrl: json["brand_image_url"],
    customerImageUrl: json["customer_image_url"],
    bannerImageUrl: json["banner_image_url"],
    categoryImageUrl: json["category_image_url"],
    reviewImageUrl: json["review_image_url"],
    sellerImageUrl: json["seller_image_url"],
    shopImageUrl: json["shop_image_url"],
    notificationImageUrl: json["notification_image_url"],
    deliveryManImageUrl: json["delivery_man_image_url"],
  );

  Map<String, dynamic> toJson() => {
    "product_image_url": productImageUrl,
    "product_thumbnail_url": productThumbnailUrl,
    "digital_product_url": digitalProductUrl,
    "brand_image_url": brandImageUrl,
    "customer_image_url": customerImageUrl,
    "banner_image_url": bannerImageUrl,
    "category_image_url": categoryImageUrl,
    "review_image_url": reviewImageUrl,
    "seller_image_url": sellerImageUrl,
    "shop_image_url": shopImageUrl,
    "notification_image_url": notificationImageUrl,
    "delivery_man_image_url": deliveryManImageUrl,
  };
}

class Policy {
  int? status;
  String? content;

  Policy({
    this.status,
    this.content,
  });

  factory Policy.fromJson(Map<String, dynamic> json) => Policy(
    status: json["status"],
    content: json["content"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "content": content,
  };
}

class Color {
  int? id;
  String? name;
  String? code;
  DateTime? createdAt;
  DateTime? updatedAt;

  Color({
    this.id,
    this.name,
    this.code,
    this.createdAt,
    this.updatedAt,
  });

  factory Color.fromJson(Map<String, dynamic> json) => Color(
    id: json["id"],
    name: json["name"],
    code: json["code"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class CurrencyList {
  int? id;
  String? name;
  String? symbol;
  String? code;
  double? exchangeRate;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  CurrencyList({
    this.id,
    this.name,
    this.symbol,
    this.code,
    this.exchangeRate,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory CurrencyList.fromJson(Map<String, dynamic> json) => CurrencyList(
    id: json["id"],
    name: json["name"],
    symbol: json["symbol"],
    code: json["code"],
    exchangeRate: json["exchange_rate"]?.toDouble(),
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "symbol": symbol,
    "code": code,
    "exchange_rate": exchangeRate,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class Faq {
  int? id;
  String? question;
  String? answer;
  int? ranking;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  Faq({
    this.id,
    this.question,
    this.answer,
    this.ranking,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Faq.fromJson(Map<String, dynamic> json) => Faq(
    id: json["id"],
    question: json["question"],
    answer: json["answer"],
    ranking: json["ranking"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "question": question,
    "answer": answer,
    "ranking": ranking,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class Language {
  String? code;
  String? name;

  Language({
    this.code,
    this.name,
  });

  factory Language.fromJson(Map<String, dynamic> json) => Language(
    code: json["code"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "name": name,
  };
}

class SocialLogin {
  String? loginMedium;
  bool? status;

  SocialLogin({
    this.loginMedium,
    this.status,
  });

  factory SocialLogin.fromJson(Map<String, dynamic> json) => SocialLogin(
    loginMedium: json["login_medium"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "login_medium": loginMedium,
    "status": status,
  };
}

class StaticUrls {
  String? contactUs;
  String? brands;
  String? categories;
  String? customerAccount;

  StaticUrls({
    this.contactUs,
    this.brands,
    this.categories,
    this.customerAccount,
  });

  factory StaticUrls.fromJson(Map<String, dynamic> json) => StaticUrls(
    contactUs: json["contact_us"],
    brands: json["brands"],
    categories: json["categories"],
    customerAccount: json["customer_account"],
  );

  Map<String, dynamic> toJson() => {
    "contact_us": contactUs,
    "brands": brands,
    "categories": categories,
    "customer_account": customerAccount,
  };
}
