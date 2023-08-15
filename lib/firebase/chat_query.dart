import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fissionvector_chat/models/chat.dart';
import 'package:fissionvector_chat/models/chat_enums.dart';
import 'package:fissionvector_chat/models/conversion_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChatQuery {
  final CollectionReference<Map<String, dynamic>> chatColRef =
      FirebaseFirestore.instance.collection('chat');
  final conversation = 'conversations';

  Future<DocumentReference?> sendTextMessage({
    required String message,
    required String chatId,
    required fromId,
    required toId,
  }) async {
    ConversationModel conversationModel = ConversationModel(
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      msg: message,
      type: MessageType.message,
      chatId: chatId,
      fromId: fromId,
      toId: toId,
      status: 1,
      connectionType: CallConnectionType.connected,
    );
    return sendMessage(conversationModel: conversationModel);
  }

  Future<DocumentReference?> sendCall({
    required String message,
    required String chatId,
    required fromId,
    required MessageType callType,
    required toId,
  }) async {
    ConversationModel conversationModel = ConversationModel(
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      msg: message,
      type: callType,
      chatId: chatId,
      fromId: fromId,
      toId: toId,
      connectionType: CallConnectionType.outgoing,
      status: CallConnectionType.outgoing.toInt,
    );
    return sendMessage(conversationModel: conversationModel);
  }

  Future<void> respondCall({
    required String message,
    required String chatId,
    required fromId,
    required String docId,
    required MessageType callType,
    required CallConnectionType callConnectionType,
    required toId,
  }) async {
    ConversationModel conversationModel = ConversationModel(
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      msg: message,
      type: callType,
      chatId: chatId,
      fromId: fromId,
      toId: toId,
      connectionType: callConnectionType,
      status: callConnectionType.toInt,
    );
    return updateMessage(conversationModel: conversationModel);
  }

  Future<DocumentReference?> sendMessage(
      {required ConversationModel conversationModel}) async {
    try {
      try {
        await chatColRef.doc(conversationModel.chatId).update({
          "updated_at": Timestamp.now(),
          "last_msg": conversationModel.msg,
          "updated_by": conversationModel.fromId,
          "unread_count": FieldValue.increment(1)
        });
      } catch (e) {
        ChatModel chatModel = ChatModel(
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
          lastMsg: conversationModel.msg,
          lastMsgType: conversationModel.type,
          users: [conversationModel.fromId, conversationModel.toId],
          createdBy: conversationModel.fromId,
          updatedBy: conversationModel.fromId,
        );
        await chatColRef.doc(conversationModel.chatId).set(chatModel.toJson());
      }
      final snap = await chatColRef
          .doc(conversationModel.chatId)
          .collection(conversation)
          .add(conversationModel.toJson());

      return (await snap.get()).reference;
    } catch (e, t) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<void> updateMessage(
      {required ConversationModel conversationModel}) async {
    try {
      await chatColRef.doc(conversationModel.chatId).update({
        "updated_at": Timestamp.now(),
        "last_msg": conversationModel.msg,
        "updated_by": conversationModel.fromId,
        "unread_count": FieldValue.increment(1)
      });
      debugPrint('DOC ID -> ${conversationModel.docId}');
      await chatColRef
          .doc(conversationModel.chatId)
          .collection(conversation)
          .doc(conversationModel.docId)
          .update(conversationModel.toJson());
      debugPrint(conversationModel.toJson().toString());
    } catch (e) {
      Fluttertoast.showToast(msg: 'Something went wrong');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChatStreamById(
      {required String chatId}) {
    return chatColRef
        .doc(chatId.toString())
        .collection(conversation)
        .orderBy("created_at", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChatList(
      {required int userId}) {
    return chatColRef.where("users", arrayContains: userId).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getChatModelStream(
      {required String chatId}) {
    return chatColRef.doc(chatId.toString()).snapshots();
  }

  void clearUnread({required String chatId}) async {
    await chatColRef.doc(chatId).update({
      "unread_count": 0,
    });
  }

// Future<void> generateChats() async {
//   for (int i = 2; i < 7; i++) {
//     ChatModel chatModel = ChatModel(
//       createdAt: Timestamp.now(),
//       updatedAt: Timestamp.now(),
//       lastMsg: '',
//       lastMsgType: MessageType.message,
//       users: [1, i],
//       createdBy: 1,
//       updatedBy: 1,
//     );
//     final id = await chatColRef.add(chatModel.toJson());
//     final snap = await chatColRef.doc(id.id).collection(conversation).add(
//         ConversationModel(
//             createdAt: Timestamp.now(),
//             updatedAt: Timestamp.now(),
//             msg: '',
//             type: MessageType.message,
//             chatId: id.id,
//             fromId: 1,
//             toId: i,
//             status: 1)
//             .toJson());
//   }
// }
}
