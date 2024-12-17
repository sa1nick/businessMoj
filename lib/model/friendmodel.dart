// To parse this JSON data, do
//
//     final friendModel = friendModelFromJson(jsonString);

import 'dart:convert';

FriendModel friendModelFromJson(String str) => FriendModel.fromJson(json.decode(str));

String friendModelToJson(FriendModel data) => json.encode(data.toJson());

class FriendModel {
  bool? status;
  String? message;
  List<Friendlist>? data;

  FriendModel({
    this.status,
    this.message,
    this.data,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) => FriendModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<Friendlist>.from(json["data"]!.map((x) => Friendlist.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Friendlist {
  int? requestId;
  int? userId;
  int? friendId;
  int? status;
  DateTime? friendAt;
  FriendData? friendData;

  Friendlist({
    this.requestId,
    this.userId,
    this.friendId,
    this.status,
    this.friendAt,
    this.friendData,
  });

  factory Friendlist.fromJson(Map<String, dynamic> json) => Friendlist(
    requestId: json["request_id"],
    userId: json["user_id"],
    friendId: json["friend_id"],
    status: json["status"],
    friendAt: json["friend_at"] == null ? null : DateTime.parse(json["friend_at"]),
    friendData: json["friend_data"] == null ? null : FriendData.fromJson(json["friend_data"]),
  );

  Map<String, dynamic> toJson() => {
    "request_id": requestId,
    "user_id": userId,
    "friend_id": friendId,
    "status": status,
    "friend_at": friendAt?.toIso8601String(),
    "friend_data": friendData?.toJson(),
  };
}

class FriendData {
  int? id;
  String? name;
  String? phone;
  String? email;
  String? image;
  String? referralCode;
  int? count;

  FriendData({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.image,
    this.referralCode,
    this.count,
  });

  factory FriendData.fromJson(Map<String, dynamic> json) => FriendData(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
    email: json["email"],
    image: json["image"],
    referralCode: json["referral_code"],
    count: json["count"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "email": email,
    "image": image,
    "referral_code": referralCode,
    "count": count,
  };
}
