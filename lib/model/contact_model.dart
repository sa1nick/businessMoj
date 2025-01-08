class MyContactModel {
  int? id;
  String? name;
  String? image;
  String? phone;
  String? roomId;
  bool? isSelected;
  bool? isBlocked;

  MyContactModel({this.id, this.name, this.image, this.phone});

  MyContactModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    phone = json['phone'];
    roomId = json['room_id'];
    isBlocked = json['is_blocked'];
    isSelected= false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['phone'] = phone;
    data['room_id'] = roomId;
    return data;
  }
}
