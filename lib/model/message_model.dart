class SmSHistoryModel {
  String? type;
  int? roomId;
  String? loggedUser;
  String? chatUser;
  List<Messages>? messages;

  SmSHistoryModel(
      {this.type, this.roomId, this.loggedUser, this.chatUser, this.messages});

  SmSHistoryModel.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    roomId = json['room_id'] !=null && json['room_id'] != '' ? int.parse(json['room_id'].toString()) : null;
    loggedUser = json['logged_user'].toString();
    chatUser = json['chat_user'].toString();
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add( Messages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['room_id'] = this.roomId;
    data['logged_user'] = this.loggedUser;
    data['chat_user'] = this.chatUser;
    if (this.messages != null) {
      data['messages'] = this.messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class   Messages {
  int? id;
  String? message;
  int? type;
  int? createdBy;
  String? createdAt;
  String? senderName;



  Messages({this.id, this.message, this.type, this.createdBy, this.createdAt,this.senderName});

  Messages.fromJson(Map<String, dynamic> json) {


    id = json['id'];
    senderName = json['sender_name'];

    message = json['message'];
    type = json['type'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['message'] = this.message;
    data['type'] = this.type;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    return data;
  }
}
