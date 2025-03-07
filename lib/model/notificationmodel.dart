// To parse this JSON data, do
//
//     final notificationModel = notificationModelFromJson(jsonString);

import 'dart:convert';

List<NotificationModel> notificationModelFromJson(String str) => List<NotificationModel>.from(json.decode(str).map((x) => NotificationModel.fromJson(x)));

String notificationModelToJson(List<NotificationModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NotificationModel {
  int? id;
  String? title;
  String? description;
  int? notificationCount;
  String? image;
  String? audio;
  String? video;
  String? pdf;
  String? type;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  NotificationModel({
    this.id,
    this.title,
    this.description,
    this.notificationCount,
    this.image,
    this.audio,
    this.video,
    this.pdf,
    this.type,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    notificationCount: json["notification_count"],
    image: json["image"],
    audio: json["audio"],
    video: json["video"],
    pdf: json["pdf"],
    type: json["type"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "notification_count": notificationCount,
    "image": image,
    "audio": audio,
    "video": video,
    "pdf": pdf,
    "type": type,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
