import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

User userFromJson(String str) {
  final jsonData = json.decode(str);
  return User.fromJson(jsonData);
}

String userToJson(User data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class User {
  var finishedRequests;
  String userId;
  String phone;
  String name;
  String dataNascimento;

  User({
    this.finishedRequests,
    this.userId,
    this.phone,
    this.name,
    this.dataNascimento,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        finishedRequests: json["finishedRequests"],
        userId: json["userId"],
        phone: json["phone"],
        name: json["name"],
        dataNascimento: json["dataNascimento"],
      );

  Map<String, dynamic> toJson() => {
        "finishedRequests": finishedRequests,
        "userId": userId,
        "phone": phone,
        "name": name,
        "dataNascimento": dataNascimento,
      };

  factory User.fromDocument(DocumentSnapshot doc) {
    return User.fromJson(doc.data);
  }
}
