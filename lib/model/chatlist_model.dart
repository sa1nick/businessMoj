import 'package:ut_messenger/model/usermodel.dart';

class MyChatListModel {
  bool? status;
  String? message;
  List<ChatListData>? data;

  MyChatListModel({this.status, this.message, this.data});

  MyChatListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <ChatListData>[];
      json['data'].forEach((v) {
        data!.add(new ChatListData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ChatListData {
  int? id;
  String? title;
  dynamic orderId;
  dynamic clubId;
  int? type;
  String? image;
  String? description;
  int? chatAccessGroup;
  int? status;
  String? createdAt;
  int? createdBy;
  String? updatedAt;
  int? updatedBy;
  String? imageUrl;
  String? unreadCount;
  String? lastUnreadDate;
  bool? isSelected ;
  List<Chatroom>? chatroom;

  ChatListData(
      {this.id,
        this.title,
        this.orderId,
        this.clubId,
        this.type,
        this.image,
        this.description,
        this.chatAccessGroup,
        this.status,
        this.createdAt,
        this.createdBy,
        this.updatedAt,
        this.updatedBy,
        this.imageUrl,
        this.lastUnreadDate,
        this.chatroom,this.unreadCount,this.isSelected});

  ChatListData.fromJson(Map<String, dynamic> json) {

    id = json['id'];
    title = json['title'];
    orderId = json['order_id'];
    clubId = json['club_id'];
    unreadCount = json['unread_count'].toString();
    lastUnreadDate = json['last_unread'] != null && json['last_unread'] !=''?  json['last_unread'].toString() : DateTime.now().copyWith(day: 01,month: 1,year: 2023).toString();
    type = json['type'];
    image = json['image'];
    description = json['description'];
    chatAccessGroup = json['chat_access_group'];
    status = json['status'];
    createdAt = json['created_at'];
    createdBy = json['created_by'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    imageUrl = json['image_url'];
    isSelected = false ;
    if (json['chatroom'] != null) {
      chatroom = <Chatroom>[];
      json['chatroom'].forEach((v) {
        chatroom!.add(new Chatroom.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['order_id'] = orderId;
    data['club_id'] = clubId;
    data['type'] = type;
    data['image'] = image;
    data['description'] = description;
    data['chat_access_group'] = chatAccessGroup;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['created_by'] = createdBy;
    data['updated_at'] = updatedAt;
    data['updated_by'] = updatedBy;
    data['image_url'] = imageUrl;
    data['unread_count'] = unreadCount;
    if (chatroom != null) {
      data['chatroom'] = chatroom!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Chatroom {
  int? id;
  int? roomId;
  int? userId;
  int? isAdmin;
  int? status;
  String? createdAt;
  int? createdBy;
  String? updatedAt;
  UserData? user;

  Chatroom(
      {this.id,
        this.roomId,
        this.userId,
        this.isAdmin,
        this.status,
        this.createdAt,
        this.createdBy,
        this.updatedAt,
        this.user});

  Chatroom.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    roomId = json['room_id'];
    userId = json['user_id'];
    isAdmin = json['is_admin'];
    status = json['status'];
    createdAt = json['created_at'];
    createdBy = json['created_by'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ?  UserData.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['room_id'] = roomId;
    data['user_id'] = userId;
    data['is_admin'] = isAdmin;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['created_by'] = createdBy;
    data['updated_at'] = updatedAt;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}


