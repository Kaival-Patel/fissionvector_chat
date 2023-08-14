// To parse this JSON data, do
//
//     final userDm = userDmFromJson(jsonString);

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

UserDm userDmFromJson(String str) => UserDm.fromJson(json.decode(str));

String userDmToJson(UserDm data) => json.encode(data.toJson());

class UserDm {
  final int uid;
  bool isOnline;
  Timestamp? lastOnline;
  final String name;
  final String subject;
  final String profile;

  UserDm({
    this.uid = 0,
    this.isOnline = false,
    this.lastOnline,
    this.name = "",
    this.profile = "",
    this.subject = "",
  });

  factory UserDm.fromJson(Map<String, dynamic> json) => UserDm(
        uid: json["uid"] ?? 0,
        isOnline: json["is_online"] ?? false,
        lastOnline: json["last_online"] ?? Timestamp.now(),
        name: json["name"] ?? "",
        subject: json["subject"] ?? "",
        profile: json["profile"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "is_online": isOnline,
        "last_online": lastOnline ?? Timestamp.now(),
        "name": name,
        "profile": profile,
        "subject": subject,
      };
}
