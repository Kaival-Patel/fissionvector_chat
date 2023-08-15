import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:fissionvector_chat/firebase/user_query.dart';
import 'package:fissionvector_chat/models/chat.dart';
import 'package:fissionvector_chat/models/chat_enums.dart';
import 'package:fissionvector_chat/models/conversion_model.dart';
import 'package:fissionvector_chat/models/user.dart';
import 'package:fissionvector_chat/repository/repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppCall extends StatelessWidget {
  final ConversationModel chatModel;
  final RtcEngine engine;
  final void Function(CallConnectionType) onCallUpdated;
  final void Function()? onCameraSwitch;
  final void Function()? onSpeakerToggle;
  final void Function()? onMicToggle;
  final bool isMicEnabled;
  final bool isSpeakerEnabled;

  const AppCall({
    Key? key,
    required this.chatModel,
    required this.onCallUpdated,
    required this.engine,
    this.onSpeakerToggle,
    this.onMicToggle,
    this.isMicEnabled = true,
    this.onCameraSwitch,
    this.isSpeakerEnabled = false,
  }) : super(
          key: key,
        );

  String get connectionStatus {
    switch (chatModel.connectionType) {
      case CallConnectionType.incoming:
        return chatModel.isSentByMe
            ? "Outgoing $callType call"
            : "Incoming $callType call";
      case CallConnectionType.connected:
        return "Connected $callType call";
      case CallConnectionType.outgoing:
        return chatModel.isSentByMe
            ? "Outgoing $callType call"
            : "Incoming $callType call";
      case CallConnectionType.finished:
        return "Call Finished, please wait";
    }
  }

  bool get isIncoming => !chatModel.isSentByMe;

  String get callType =>
      chatModel.type == MessageType.audioCall ? 'audio' : 'video';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber[50],
      height: double.infinity,
      width: double.infinity,
      child: Stack(
        children: [
          if (chatModel.type == MessageType.videoCall) ...[
            if (chatModel.connectionType == CallConnectionType.connected) ...[
              AgoraVideoView(
                  controller: VideoViewController.remote(
                      rtcEngine: engine,
                      canvas: VideoCanvas(
                        uid: chatModel.isSentByMe
                            ? chatModel.toId
                            : chatModel.fromId,
                      ),
                      connection: RtcConnection(
                        channelId: chatModel.chatId,
                      ))),
            ] else ...[
              AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              )
            ],
            if (chatModel.connectionType == CallConnectionType.connected) ...[
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 100,
                      width: 50,
                      child: AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ]
          ],
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (chatModel.isCallConnected &&
                    chatModel.type == MessageType.videoCall) ...[
                  const SizedBox.shrink(),
                ] else ...[
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
                              AvatarGlow(
                                endRadius: 100,
                                glowColor: Colors.amber.shade500,
                                child: CircleAvatar(
                                  backgroundColor: Colors.amber,
                                  radius: 50,
                                  backgroundImage: NetworkImage(userDm.profile),
                                ),
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
                  const SizedBox(
                    height: 10,
                  ),
                ],
                Text(
                  connectionStatus,
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(
                  height: 50,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isIncoming ||
                        chatModel.connectionType ==
                            CallConnectionType.connected) ...[
                      if (chatModel.type == MessageType.videoCall) ...[
                        RawMaterialButton(
                            shape: const CircleBorder(),
                            onPressed: onCameraSwitch,
                            padding: const EdgeInsets.all(10),
                            fillColor: Colors.white,
                            child: const Icon(
                              Icons.switch_camera,
                              color: Colors.black,
                            )),
                      ] else ...[
                        RawMaterialButton(
                            shape: const CircleBorder(),
                            onPressed: onSpeakerToggle,
                            padding: const EdgeInsets.all(10),
                            fillColor: isSpeakerEnabled
                                ? Colors.white
                                : Colors.grey[700],
                            child: Icon(
                              Icons.volume_up,
                              color: isSpeakerEnabled
                                  ? Colors.black
                                  : Colors.white,
                            )),
                      ],
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
                        fillColor:
                            isMicEnabled ? Colors.white : Colors.grey[700],
                        child: Icon(
                          isMicEnabled ? Icons.mic : Icons.mic_off,
                          color: isMicEnabled ? Colors.black : Colors.white,
                        ),
                      ),
                    ] else if (isIncoming) ...[
                      RawMaterialButton(
                          shape: const CircleBorder(),
                          onPressed: () =>
                              onCallUpdated(CallConnectionType.connected),
                          padding: const EdgeInsets.all(20),
                          fillColor: Colors.green[700],
                          child: const Icon(
                            Icons.call,
                            color: Colors.white,
                            size: 40,
                          )),
                      const SizedBox(
                        width: 40,
                      ),
                      RawMaterialButton(
                          shape: const CircleBorder(),
                          onPressed: () =>
                              onCallUpdated(CallConnectionType.finished),
                          padding: const EdgeInsets.all(20),
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
                          fillColor: isSpeakerEnabled
                              ? Colors.white
                              : Colors.grey[300],
                          child: Icon(
                            Icons.volume_up,
                            color:
                                isSpeakerEnabled ? Colors.black : Colors.white,
                          )),
                      RawMaterialButton(
                          shape: const CircleBorder(),
                          onPressed: null,
                          padding: const EdgeInsets.all(20),
                          fillColor: Colors.red[300],
                          child: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                          )),
                      RawMaterialButton(
                        shape: const CircleBorder(),
                        onPressed: null,
                        padding: const EdgeInsets.all(10),
                        fillColor:
                            isMicEnabled ? Colors.white : Colors.grey[300],
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
        ],
      ),
    );
  }
}
