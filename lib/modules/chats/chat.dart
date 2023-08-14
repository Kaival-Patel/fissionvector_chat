import 'package:fissionvector_chat/models/chat_enums.dart';
import 'package:fissionvector_chat/models/conversion_model.dart';
import 'package:fissionvector_chat/models/user.dart';
import 'package:fissionvector_chat/modules/chats/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatelessWidget {
  final UserDm userDm;
  final String chatDocId;

  ChatScreen({required this.userDm, required this.chatDocId, Key? key})
      : super(key: key) {
    c = Get.put(ChatController(chatId: chatDocId, userDm: userDm));
  }

  late ChatController c;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userDm.name),
            Text(
              userDm.subject.capitalizeFirst ?? '',
              style: context.textTheme.bodySmall,
            )
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.phone)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.video_call)),
        ],
      ),
      backgroundColor: context.theme.cardColor,
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                  shrinkWrap: true,
                  reverse: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: c.chatMessages.length,
                  itemBuilder: (context, index) {
                    if (index == c.chatMessages.length - 1) {
                      return Column(
                        crossAxisAlignment: c.chatMessages[index].isSentByMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (DateTime.now().isSameAvoidTime(
                              c.chatMessages[index].createdAt.toDate())) ...[
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(5)),
                                child: Text(
                                  "Today",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: context.theme.disabledColor),
                                ),
                              ),
                            ),
                          ] else ...[
                            Center(
                              child: Text(
                                DateFormat("dd/MM/yyyy").format(
                                    c.chatMessages[index].createdAt.toDate()),
                                style: TextStyle(
                                    color: context.theme.disabledColor),
                              ),
                            ),
                          ],
                          ChatWidget(roomModel: c.chatMessages[index]),
                        ],
                      );
                    } else if (index + 1 < c.chatMessages.length - 1 &&
                        !c.chatMessages[index].createdAt
                            .toDate()
                            .isSameAvoidTime(
                                c.chatMessages[index + 1].createdAt.toDate())) {
                      return Column(
                        crossAxisAlignment: c.chatMessages[index].isSentByMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              DateFormat("dd/MM/yyyy 'at' hh:mm a").format(
                                  c.chatMessages[index].createdAt.toDate()),
                              style:
                                  TextStyle(color: context.theme.disabledColor),
                            ),
                          ),
                          ChatWidget(roomModel: c.chatMessages[index]),
                        ],
                      );
                    }
                    return ChatWidget(roomModel: c.chatMessages[index]);
                  }),
            ),
          ),
          SafeArea(
            bottom: true,
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: c.messageCTRL,
                      decoration: InputDecoration(
                          hintText: 'Start a chat',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.amber),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.amber),
                          )),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: c.sendMessage,
                    borderRadius: BorderRadius.circular(5),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.send, size: 35),
                    ),
                  )
                ],
              ),
            ).paddingOnly(bottom: 10),
          )
        ],
      ),
    );
  }
}

class ChatWidget extends StatelessWidget {
  final ConversationModel roomModel;

  const ChatWidget({super.key, required this.roomModel});

  @override
  Widget build(BuildContext context) {
    if (roomModel.isSentByMe) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(maxWidth: context.width * 0.8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
                color: Colors.grey[800]!,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(5),
                )),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    roomModel.msg,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  DateFormat("hh:mm a").format(roomModel.createdAt.toDate()),
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7), fontSize: 10),
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: context.width * 0.8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(5),
                )),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    roomModel.msg,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                Text(
                  DateFormat("hh:mm a").format(roomModel.createdAt.toDate()),
                  style: TextStyle(color: Colors.grey[800], fontSize: 12),
                )
              ],
            ),
          ),
        ),
      );
    }
  }
}
