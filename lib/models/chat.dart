import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fissionvector_chat/models/chat_enums.dart';
import 'package:fissionvector_chat/repository/repository.dart';
import 'package:get/get.dart';

import 'dart:convert';

ChatModel chatModelFromJson(String str) => ChatModel.fromJson(json.decode(str));

String chatModelToJson(ChatModel data) => json.encode(data.toJson());

class ChatModel {
  ChatModel({
    required this.createdAt,
    required this.updatedAt,
    required this.lastMsg,
    required this.lastMsgType,
    required this.users,
    required this.createdBy,
    required this.updatedBy,
    this.unreadCount = 0,
    this.deletedChatUsers = const [],
    this.blockedChatUsers = const [],
    this.docRef,
  });

  Timestamp createdAt;
  Timestamp updatedAt;
  int unreadCount;
  String lastMsg;
  List<int> users;
  List<int> deletedChatUsers;
  List<int> blockedChatUsers;
  int createdBy;
  int updatedBy;
  DocumentReference? docRef;
  MessageType lastMsgType;

  String get docId => docRef?.id ?? "";

  bool get isDeletedByMe => deletedChatUsers.contains(authRepo.userDm().uid);

  bool get isBlockedByMe => blockedChatUsers.contains(authRepo.userDm().uid);

  int? get senderUid =>
      users.firstWhereOrNull((element) => element != authRepo.userDm().uid);

  factory ChatModel.fromJson(Map<String, dynamic> json,
          {DocumentReference? docRef}) =>
      ChatModel(
        docRef: docRef,
        unreadCount: json["unread_count"] ?? 0,
        createdAt: json["created_at"] is Timestamp
            ? json["created_at"]
            : Timestamp(0, 0),
        updatedAt: json["updated_at"] is Timestamp
            ? json["updated_at"]
            : Timestamp(0, 0),
        lastMsg: json["last_msg"] ?? "",
        lastMsgType:
            (int.tryParse(json["last_msg_type"].toString()) ?? 0).toMessageType,
        users: List<int>.from((json["users"] ?? []).map((x) => x)),
        blockedChatUsers:
            List<int>.from((json["blocked_chat_users"] ?? []).map((x) => x)),
        deletedChatUsers:
            List<int>.from((json["deleted_chat_users"] ?? []).map((x) => x)),
        createdBy: json["created_by"] ?? 0,
        updatedBy: json["updated_by"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "created_at": createdAt,
        "updated_at": updatedAt,
        "last_msg": lastMsg,
        "last_msg_type": lastMsgType.toInt,
        "users": List<dynamic>.from(users.map((x) => x)),
        "blocked_chat_users":
            List<dynamic>.from(blockedChatUsers.map((x) => x)),
        "deleted_chat_users":
            List<dynamic>.from(deletedChatUsers.map((x) => x)),
        "created_by": createdBy,
        "updated_by": updatedBy,
        "unread_count": unreadCount
      };

  Map<String, dynamic> toBlockJson() => {
        "updated_at": updatedAt,
        "blocked_chat_users":
            List<dynamic>.from(blockedChatUsers.map((x) => x)),
      };

  Map<String, dynamic> toDeleteStatus() => {
        "updated_at": updatedAt,
        "deleted_chat_users":
            List<dynamic>.from(deletedChatUsers.map((x) => x)),
      };
}
