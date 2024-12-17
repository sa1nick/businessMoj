class MyContactModel {
  int? id;
  String? name;
  String? image;
  String? phone;
  bool? isSelected;

  MyContactModel({this.id, this.name, this.image, this.phone});

  MyContactModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    phone = json['phone'];
    isSelected= false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['phone'] = phone;
    return data;
  }
}
