import 'package:fissionvector_chat/models/chat_enums.dart';
import 'package:fissionvector_chat/models/conversion_model.dart';
import 'package:fissionvector_chat/models/user.dart';
import 'package:fissionvector_chat/modules/call/call.dart';
import 'package:fissionvector_chat/modules/chats/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final UserDm userDm;
  final String chatDocId;

  ChatScreen({required this.userDm, required this.chatDocId, Key? key})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatController c;

  @override
  void initState() {
    c = Get.put(
        ChatController(chatId: widget.chatDocId, userDm: widget.userDm));
    super.initState();
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.userDm.name),
            Text(
              widget.userDm.subject.capitalizeFirst ?? '',
              style: context.textTheme.bodySmall,
            )
          ],
        ),
        actions: [
          IconButton(onPressed: c.makeAudioCall, icon: const Icon(Icons.phone)),
          IconButton(
              onPressed: c.makeVideoCall, icon: const Icon(Icons.video_call)),
        ],
      ),
      backgroundColor: context.theme.cardColor,
      body: Obx(
        () => c.isInCall() && c.callConversationModel() != null
            ? AppCall(
                chatModel: c.callConversationModel()!,
                engine: c.engine,
                onSpeakerToggle: c.toggleSpeaker,
                onMicToggle: c.toggleMic,
                isMicEnabled: c.isMicEnabled(),
                onCameraSwitch: c.switchCamera,
                isSpeakerEnabled: c.isSpeakerEnabled(),
                onCallUpdated: (CallConnectionType callConnectionType) {
                  c.updateCall(callConnectionType: callConnectionType);
                })
            : Column(
                children: [
                  Expanded(
                    child: Obx(
                      () => ListView.builder(
                          shrinkWrap: true,
                          reverse: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: c.chatMessages.length,
                          itemBuilder: (context, index) {
                            String? timeHeader;
                            if (index == c.chatMessages.length - 1) {
                              if (DateTime.now().isSameAvoidTime(
                                  c.chatMessages[index].createdAt.toDate())) {
                                timeHeader = "Today";
                              } else {
                                timeHeader = DateFormat("dd/MM/yyyy").format(
                                    c.chatMessages[index].createdAt.toDate());
                              }
                            } else if (index + 1 < c.chatMessages.length - 1 &&
                                !c.chatMessages[index].createdAt
                                    .toDate()
                                    .isSameAvoidTime(c
                                        .chatMessages[index + 1].createdAt
                                        .toDate())) {
                              timeHeader = DateFormat("dd/MM/yyyy 'at' hh:mm a")
                                  .format(
                                      c.chatMessages[index].createdAt.toDate());
                            }
                            return ChatWidget(
                              roomModel: c.chatMessages[index],
                              timeHeaderText: timeHeader,
                            );
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
                                    borderSide:
                                        const BorderSide(color: Colors.amber),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: Colors.amber),
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
      ),
    );
  }
}

class ChatWidget extends StatelessWidget {
  final ConversationModel roomModel;
  final String? timeHeaderText;

  const ChatWidget({super.key, this.timeHeaderText, required this.roomModel});

  @override
  Widget build(BuildContext context) {
    if (roomModel.isCall) {
      return Center(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.indigo[100],
              borderRadius: BorderRadius.circular(5)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Text(roomModel.msg),
        ),
      );
    }
    return Column(
      crossAxisAlignment: roomModel.isSentByMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (timeHeaderText != null) ...{
          Center(
            child: Text(
              DateFormat(timeHeaderText).format(roomModel.createdAt.toDate()),
              style: TextStyle(color: context.theme.disabledColor),
            ),
          ),
        },
        if (roomModel.isSentByMe) ...{
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              constraints: BoxConstraints(maxWidth: context.width * 0.8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                      DateFormat("hh:mm a")
                          .format(roomModel.createdAt.toDate()),
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 10),
                    )
                  ],
                ),
              ),
            ),
          )
        } else ...{
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(maxWidth: context.width * 0.8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                      DateFormat("hh:mm a")
                          .format(roomModel.createdAt.toDate()),
                      style: TextStyle(color: Colors.grey[800], fontSize: 12),
                    )
                  ],
                ),
              ),
            ),
          )
        }
      ],
    );
  }
}
