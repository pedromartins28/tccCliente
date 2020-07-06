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
  double rating;
  String phone;
  String name;

  User({
    this.finishedRequests,
    this.userId,
    this.rating,
    this.phone,
    this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        finishedRequests: json["finishedRequests"],
        userId: json["userId"],
        rating: json["rating"],
        phone: json["phone"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "finishedRequests": finishedRequests,
        "userId": userId,
        "rating": rating,
        "phone": phone,
        "name": name,
      };

  factory User.fromDocument(DocumentSnapshot doc) {
    return User.fromJson(doc.data);
  }
}
