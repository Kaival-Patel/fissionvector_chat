import 'dart:async';

import 'package:fissionvector_chat/firebase/chat_query.dart';
import 'package:fissionvector_chat/models/chat.dart';
import 'package:fissionvector_chat/models/conversion_model.dart';
import 'package:fissionvector_chat/models/user.dart';
import 'package:fissionvector_chat/repository/repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  TextEditingController messageCTRL = TextEditingController();
  String chatId;
  UserDm userDm;
  StreamSubscription? chatSubscription;
  StreamSubscription? chatModelSubscription;
  RxList<ConversationModel> chatMessages = <ConversationModel>[].obs;
  Rx<ChatModel> chatModel = ChatModel.fromJson({}).obs;

  ChatController({
    required this.chatId,
    required this.userDm,
  });

  @override
  void onInit() {
    streamChatModel();
    super.onInit();
  }

  @override
  void dispose() {
    chatModelSubscription?.cancel();
    chatSubscription?.cancel();
    super.dispose();
  }

  void streamChatModel() async {
    chatModelSubscription =
        ChatQuery().getChatModelStream(chatId: chatId).listen((event) {
      chatModel.value = ChatModel.fromJson(event.data()!);
      chatModel().docRef = event.reference;
      if (!chatModel().isBlockedByMe) {
        streamMessages();
      } else {
        chatSubscription?.cancel();
        chatSubscription = null;
        chatMessages.clear();
      }
    });
  }

  void streamMessages() async {
    chatSubscription ??=
        ChatQuery().getChatStreamById(chatId: chatId).listen((event) {
      chatMessages.clear();
      for (final chat in event.docs) {
        chatMessages.add(ConversationModel.fromJson(chat.data()));
      }
      clearReadUnread();
    });
  }

  clearReadUnread() async {
    ChatQuery().clearUnread(chatId: chatId);
  }

  void sendMessage() async {
    if (messageCTRL.text.isNotEmpty) {
      ChatQuery().sendTextMessage(
        message: messageCTRL.text,
        chatId: chatId,
        fromId: authRepo.userDm().uid,
        toId: userDm.uid,
      );
      messageCTRL.clear();
    }
  }
}
