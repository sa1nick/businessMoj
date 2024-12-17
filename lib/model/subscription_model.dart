class SubscriptionModel {
  bool? status;
  String? message;
  List<SubscriptionPlan>? planLists;

  SubscriptionModel({this.status, this.message, this.planLists});

  SubscriptionModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['lists'] != null) {
      planLists = <SubscriptionPlan>[];
      json['lists'].forEach((v) {
        planLists!.add(SubscriptionPlan.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (planLists != null) {
      data['lists'] = planLists!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubscriptionPlan {
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

  SubscriptionPlan(
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

  SubscriptionPlan.fromJson(Map<String, dynamic> json) {
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
