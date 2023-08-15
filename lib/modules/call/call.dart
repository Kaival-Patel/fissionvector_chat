import 'package:fissionvector_chat/firebase/user_query.dart';
import 'package:fissionvector_chat/models/chat_enums.dart';
import 'package:fissionvector_chat/models/conversion_model.dart';
import 'package:fissionvector_chat/models/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppCall extends StatelessWidget {
  final ConversationModel chatModel;
  final void Function(CallConnectionType) onCallUpdated;
  final void Function()? onSpeakerToggle;
  final void Function()? onMicToggle;
  final bool isMicEnabled;
  final bool isSpeakerEnabled;

  const AppCall({
    Key? key,
    required this.chatModel,
    required this.onCallUpdated,
    this.onSpeakerToggle,
    this.onMicToggle,
    this.isMicEnabled = true,
    this.isSpeakerEnabled = false,
  }) : super(
          key: key,
        );

  String get connectionStatus {
    switch (chatModel.connectionType) {
      case CallConnectionType.incoming:
        return chatModel.isSentByMe ? "Outgoing call" : "Incoming call";
      case CallConnectionType.connected:
        return "Connected call";
      case CallConnectionType.outgoing:
        return chatModel.isSentByMe ? "Outgoing call" : "Incoming call";
      case CallConnectionType.finished:
        return "Call Finished, please wait";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber[100],
      height: double.infinity,
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<UserDm>(
                future: UserQuery().getUserInfoFromUid(
                    uid: chatModel.isSentByMe
                        ? chatModel.fromId
                        : chatModel.toId),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      !snapshot.hasError &&
                      snapshot.data != null) {
                    final userDm = snapshot.data!;
                    return Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.amber,
                          radius: 50,
                          backgroundImage: NetworkImage(userDm.profile),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Text(
                          userDm.name,
                          style: context.textTheme.titleLarge,
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),
            Text(
              connectionStatus,
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (chatModel.connectionType == CallConnectionType.outgoing ||
                    chatModel.connectionType ==
                        CallConnectionType.connected) ...[
                  RawMaterialButton(
                      shape: const CircleBorder(),
                      onPressed: onSpeakerToggle,
                      padding: const EdgeInsets.all(10),
                      fillColor:
                          isSpeakerEnabled ? Colors.white : Colors.grey[700],
                      child: Icon(
                        Icons.volume_up,
                        color: isSpeakerEnabled ? Colors.black : Colors.white,
                      )),
                  RawMaterialButton(
                      shape: const CircleBorder(),
                      onPressed: () =>
                          onCallUpdated(CallConnectionType.finished),
                      padding: const EdgeInsets.all(30),
                      fillColor: Colors.red[700],
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                      )),
                  RawMaterialButton(
                    shape: const CircleBorder(),
                    onPressed: onMicToggle,
                    padding: const EdgeInsets.all(10),
                    fillColor: isMicEnabled ? Colors.white : Colors.grey[700],
                    child: Icon(
                      isMicEnabled ? Icons.mic : Icons.mic_off,
                      color: isMicEnabled ? Colors.black : Colors.white,
                    ),
                  ),
                ] else if (chatModel.connectionType ==
                    CallConnectionType.incoming) ...[
                  RawMaterialButton(
                      shape: const CircleBorder(),
                      onPressed: () =>
                          onCallUpdated(CallConnectionType.connected),
                      padding: const EdgeInsets.all(30),
                      fillColor: Colors.green[700],
                      child: const Icon(
                        Icons.call,
                        color: Colors.white,
                        size: 40,
                      )),
                  const SizedBox(
                    width: 30,
                  ),
                  RawMaterialButton(
                      shape: const CircleBorder(),
                      onPressed: () =>
                          onCallUpdated(CallConnectionType.finished),
                      padding: const EdgeInsets.all(30),
                      fillColor: Colors.red[700],
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 40,
                      )),
                ] else ...[
                  RawMaterialButton(
                      shape: const CircleBorder(),
                      onPressed: null,
                      padding: const EdgeInsets.all(10),
                      fillColor:
                          isSpeakerEnabled ? Colors.white : Colors.grey[300],
                      child: Icon(
                        Icons.volume_up,
                        color: isSpeakerEnabled ? Colors.black : Colors.white,
                      )),
                  RawMaterialButton(
                      shape: const CircleBorder(),
                      onPressed: null,
                      padding: const EdgeInsets.all(30),
                      fillColor: Colors.red[300],
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                      )),
                  RawMaterialButton(
                    shape: const CircleBorder(),
                    onPressed: null,
                    padding: const EdgeInsets.all(10),
                    fillColor: isMicEnabled ? Colors.white : Colors.grey[300],
                    child: Icon(
                      isMicEnabled ? Icons.mic : Icons.mic_off,
                      color: isMicEnabled ? Colors.black : Colors.white,
                    ),
                  ),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}
