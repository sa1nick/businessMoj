class PurchasePlanHistoryModel {
  bool? status;
  String? message;
  List<PurchasePlanData>? historyLists;

  PurchasePlanHistoryModel({this.status, this.message, this.historyLists});

  PurchasePlanHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['lists'] != null) {
      historyLists = <PurchasePlanData>[];
      json['lists'].forEach((v) {
        historyLists!.add(PurchasePlanData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (historyLists != null) {
      data['lists'] = historyLists!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PurchasePlanData {
  int? id;
  int? planId;
  int? userId;
  String? amount;
  String? transactionId;
  String? endDate;
  int? userLimit;
  String? planType;
  String? createdAt;
  String? updatedAt;
  Plan? plan;

  PurchasePlanData(
      {this.id,
        this.planId,
        this.userId,
        this.amount,
        this.transactionId,
        this.endDate,
        this.userLimit,
        this.planType,
        this.createdAt,
        this.updatedAt,
        this.plan});

  PurchasePlanData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    planId = json['plan_id'];
    userId = json['user_id'];
    amount = json['amount'];
    transactionId = json['transaction_id'];
    endDate = json['end_date'];
    userLimit = json['user_limit'];
    planType = json['plan_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    plan = json['plan'] != null ? Plan.fromJson(json['plan']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['plan_id'] = planId;
    data['user_id'] = userId;
    data['amount'] = amount;
    data['transaction_id'] = transactionId;
    data['end_date'] = endDate;
    data['user_limit'] = userLimit;
    data['plan_type'] = planType;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (plan != null) {
      data['plan'] = plan!.toJson();
    }
    return data;
  }
}

class Plan {
  int? id;
  String? title;
  String? description;
  String? subscriptionType;
  int? time;
  String? type;
  String? price;
  int? status;
  int? userLimit;
  dynamic? image;
  String? createdAt;
  String? updatedAt;

  Plan(
      {this.id,
        this.title,
        this.description,
        this.subscriptionType,
        this.time,
        this.type,
        this.price,
        this.status,
        this.userLimit,
        this.image,
        this.createdAt,
        this.updatedAt});

  Plan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    subscriptionType = json['subscription_type'];
    time = json['time'];
    type = json['type'];
    price = json['price'];
    status = json['status'];
    userLimit = json['user_limit'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['subscription_type'] = subscriptionType;
    data['time'] = time;
    data['type'] = type;
    data['price'] = price;
    data['status'] = status;
    data['user_limit'] = userLimit;
    data['image'] = image;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
