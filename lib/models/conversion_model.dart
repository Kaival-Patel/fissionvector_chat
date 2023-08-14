// To parse this JSON data, do
//
//     final conversationModel = conversationModelFromJson(jsonString);

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fissionvector_chat/models/chat_enums.dart';
import 'dart:convert';

import 'package:fissionvector_chat/repository/repository.dart';

ConversationModel conversationModelFromJson(String str) =>
    ConversationModel.fromJson(json.decode(str));

String conversationModelToJson(ConversationModel data) =>
    json.encode(data.toJson());

class ConversationModel {
  ConversationModel({
    required this.createdAt,
    required this.updatedAt,
    required this.msg,
    required this.type,
    required this.chatId,
    required this.fromId,
    required this.toId,
    required this.status,
    this.docRef,
    this.linkedLeft,
    this.linkedRight,
  });

  Timestamp createdAt;
  Timestamp updatedAt;
  String msg;
  int fromId;
  int toId;
  String chatId;
  MessageType type;
  int status;

  DocumentReference? docRef;
  DocumentReference? linkedLeft, linkedRight;

  bool get isSentByMe => fromId == authRepo.userDm().uid;

  String get docId => docRef?.id ?? "";

  factory ConversationModel.fromJson(Map<String, dynamic> json,
          {DocumentReference? docRef}) =>
      ConversationModel(
        docRef: docRef,
        fromId: json["from_id"] ?? 0,
        toId: json["to_id"] ?? 0,
        chatId: json["chat_id"] ?? "",
        linkedLeft: json["linked_left"],
        linkedRight: json["linked_right"],
        createdAt: json["created_at"] is Timestamp
            ? json["created_at"]
            : Timestamp(0, 0),
        updatedAt: json["updated_at"] is Timestamp
            ? json["updated_at"]
            : Timestamp(0, 0),
        msg: json["msg"] ?? "",
        type: (int.tryParse(json["type"].toString()) ?? 0).toMessageType,
        status: json["status"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "created_at": createdAt,
        "updated_at": updatedAt,
        "msg": msg,
        "type": type.toInt,
        "status": status,
        "chat_id": chatId,
        "from_id": fromId,
        "to_id": toId,
        "linked_left": linkedLeft,
        "linked_right": linkedRight,
      };
}
