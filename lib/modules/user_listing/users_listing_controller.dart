import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fissionvector_chat/firebase/chat_query.dart';
import 'package:fissionvector_chat/firebase/user_query.dart';
import 'package:fissionvector_chat/models/chat.dart';
import 'package:fissionvector_chat/models/user.dart';
import 'package:fissionvector_chat/repository/repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class UsersListingController extends GetxController {
  late StreamSubscription streamSubscription;
  late StreamSubscription chatSubscription;
  RxBool isOnline = false.obs;
  RxList<ChatModel> chats = <ChatModel>[].obs;

  @override
  void onInit() {
    streamAvailability();
    streamChats();
    super.onInit();
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    chatSubscription.cancel();
    super.dispose();
  }

  void streamAvailability() {
    streamSubscription =
        UserQuery().streamUserInfo(uid: authRepo.userDm().uid).listen((event) {
      if (event.exists && event.data() != null) {
        authRepo.userDm(UserDm.fromJson(event.data()!));
        isOnline(authRepo.userDm().isOnline);
      }
    });
  }

  void streamChats() {
    chatSubscription =
        ChatQuery().getChatList(userId: authRepo.userDm().uid).listen((event) {
          debugPrint(event.docs.length.toString());
      if (event.docs.isNotEmpty) {
        chats.clear();
        for (final doc in event.docs) {
          final chat = ChatModel.fromJson(doc.data());
          chat.docRef = doc.reference;
          chats.add(chat);
        }
      }
    });
  }

  void updateAvailability() async {
    authRepo.userDm().isOnline = !isOnline();
    authRepo.userDm().lastOnline = Timestamp.now();
    await UserQuery().updateUserInfo(userDm: authRepo.userDm());
  }
}
