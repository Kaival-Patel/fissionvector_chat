import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:fissionvector_chat/firebase/chat_query.dart';
import 'package:fissionvector_chat/models/agora_model.dart';
import 'package:fissionvector_chat/models/chat.dart';
import 'package:fissionvector_chat/models/chat_enums.dart';
import 'package:fissionvector_chat/models/conversion_model.dart';
import 'package:fissionvector_chat/models/user.dart';
import 'package:fissionvector_chat/repository/repository.dart';
import 'package:fissionvector_chat/utils/functions/helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/functions/strings_constants.dart';

class ChatController extends GetxController {
  TextEditingController messageCTRL = TextEditingController();
  String chatId;
  UserDm userDm;
  StreamSubscription? chatSubscription;
  StreamSubscription? chatModelSubscription;
  RxList<ConversationModel> chatMessages = <ConversationModel>[].obs;
  Rx<ChatModel> chatModel = ChatModel.fromJson({}).obs;
  late RtcEngine engine;
  Rx<AgoraResDm> agoraSettings = AgoraResDm().obs;
  RxBool isInCall = false.obs;
  Rxn<ConversationModel> callConversationModel = Rxn<ConversationModel>();
  RxBool isJoinedChannel = false.obs;
  RxBool isSpeakerEnabled = false.obs;
  RxBool isMicEnabled = false.obs;

  ChatController({
    required this.chatId,
    required this.userDm,
  });

  @override
  void onInit() {

    initAgoraRTC();
    super.onInit();
  }

  @override
  void dispose() {
    chatModelSubscription?.cancel();
    chatSubscription?.cancel();
    engine.leaveChannel(
      options: const LeaveChannelOptions(
        stopAllEffect: true,
        stopMicrophoneRecording: true,
        stopAudioMixing: true,
      ),
    );
    engine.release(sync: true);
    debugPrint('Releasing engine');
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
        final conversationModel = ConversationModel.fromJson(chat.data());
        conversationModel.docRef = chat.reference;
        chatMessages.add(conversationModel);
      }
      if (chatMessages.isNotEmpty &&
          chatMessages.first.isCall &&
          (!chatMessages.first.isFinished)) {
        debugPrint(chatMessages.first.toJson().toString());
        callConversationModel(chatMessages.first);
        isInCall(true);
        handleCallAccordingToStatus();
      } else {
        callConversationModel.value = null;
        leaveChannelAndDestroy();
        isInCall(false);
      }
      clearReadUnread();
    });
  }

  clearReadUnread() async {
    ChatQuery().clearUnread(chatId: chatId);
  }

  void makeAudioCall() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
    ].request();
    if (statuses.values.where((element) => !element.isGranted).isNotEmpty) {
      Fluttertoast.showToast(msg: 'Permissions required to make call');
      return;
    }
    await ChatQuery().sendCall(
      message: '${authRepo.userDm().name} requested for audio call',
      chatId: chatId,
      fromId: authRepo.userDm().uid,
      toId: userDm.uid,
      callType: MessageType.audioCall,
    );
  }

  void makeVideoCall() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.camera,
    ].request();
    if (statuses.values.where((element) => !element.isGranted).isNotEmpty) {
      Fluttertoast.showToast(msg: 'Permissions required to make call');
      return;
    }
    await ChatQuery().sendCall(
      message: '${authRepo.userDm().name} requested for video call',
      chatId: chatId,
      fromId: authRepo.userDm().uid,
      toId: userDm.uid,
      callType: MessageType.videoCall,
    );
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

  void initAgoraRTC() async {
    try {
      agoraSettings().channelId = chatId;
      final agoraAPICall = await getAgoraTempToken(
        channelId: chatId,
        uid: authRepo.userDm().uid,
      );
      if (agoraAPICall.isSuccess) {
        agoraSettings(
          agoraAPICall,
        );
      } else {
        Fluttertoast.showToast(msg: 'Oops, something is not right');
      }
      engine = createAgoraRtcEngine();
      engine.initialize(const RtcEngineContext(
        appId: StringConstants.agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));
      await engine.disableVideo();
      await engine.disableAudio();
      _addAgoraEventHandlers();

    } catch (e) {
      debugPrint("Error initing engine : $e");
    }
    streamChatModel();
  }

  void _addAgoraEventHandlers() {
    /// API CALL INCASE OF TUTOR ONLY
    engine.registerEventHandler(RtcEngineEventHandler(
      onError: (err, msg) {
        debugPrint('Message: $msg');
      },
      onLeaveChannel: (connection, stats) {
        Fluttertoast.showToast(msg: 'Left Call');
        if (connection.localUid == authRepo.userDm().uid) {
          isJoinedChannel(false);
        }
      },
      onConnectionStateChanged: (connection, state, reason) {
        if (state == ConnectionStateType.connectionStateConnected) {
          isJoinedChannel(true);
        } else {
          isJoinedChannel(false);
        }
      },
      onJoinChannelSuccess: (connection, elapsed) {
        Fluttertoast.showToast(msg: 'Joined Call');
        if (connection.localUid == authRepo.userDm().uid) {
          isJoinedChannel(true);
        }
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        if (remoteUid == authRepo.userDm().uid) {
          isJoinedChannel(true);
        }
      },
    ));
  }

  void joinChannel({required bool isVideoCall}) async {
    try {
      if (!isJoinedChannel()) {
        engine = createAgoraRtcEngine();
        await engine.initialize(const RtcEngineContext(
          appId: StringConstants.agoraAppId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ));
        await engine.enableAudio();
        if (isVideoCall) {
          engine.enableVideo();
        }
        _addAgoraEventHandlers();
        await engine.joinChannel(
          token: agoraSettings().token,
          uid: authRepo.userDm().uid,
          channelId: chatId,
          options: ChannelMediaOptions(
            token: agoraSettings().token,
            publishMicrophoneTrack: true,
            channelProfile: ChannelProfileType.channelProfileCommunication1v1,
          ),
        );
        isJoinedChannel(true);
        isMicEnabled(true);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error : $e');
      if (e is AgoraRtcException && e.code == -17) {
        engine.leaveChannel();
        Fluttertoast.showToast(msg: 'Try again');
      }
    }
  }

  void updateCall({required CallConnectionType callConnectionType}) async {
    if (callConversationModel() != null) {
      callConversationModel()!.connectionType = callConnectionType;
      await ChatQuery()
          .updateMessage(conversationModel: callConversationModel()!);
      handleCallAccordingToStatus();
    }
  }

  void toggleSpeaker() {
    isSpeakerEnabled(!isSpeakerEnabled());
    engine.setEnableSpeakerphone(isSpeakerEnabled());
  }

  void toggleMic() {
    isMicEnabled(!isMicEnabled());
    engine.muteLocalAudioStream(isMicEnabled());
  }

  void switchCamera() {
    engine.switchCamera();
  }

  void leaveChannelAndDestroy() async {
    await engine.muteLocalVideoStream(true);
    await engine.muteLocalAudioStream(true);
    await engine.disableAudio();
    await engine.disableVideo();
    engine.leaveChannel(
      options: const LeaveChannelOptions(
        stopAllEffect: true,
        stopMicrophoneRecording: true,
        stopAudioMixing: true,
      ),
    );
    engine.release(sync: true);
  }

  void handleCallAccordingToStatus() async {
    if (callConversationModel() != null) {
      debugPrint('IN CALL');
      switch (callConversationModel()!.connectionType) {
        case CallConnectionType.incoming:
          joinChannel(
              isVideoCall:
                  callConversationModel()!.type == MessageType.videoCall);
          break;
        case CallConnectionType.connected:
          Fluttertoast.showToast(msg: 'Call Connected');
          joinChannel(
              isVideoCall:
                  callConversationModel()!.type == MessageType.videoCall);
          break;
        case CallConnectionType.outgoing:
          joinChannel(
              isVideoCall:
                  callConversationModel()!.type == MessageType.videoCall);
          break;
        case CallConnectionType.finished:
          debugPrint('Finished Channel 2');
          callConversationModel.value = null;
          isInCall(false);
          isSpeakerEnabled(false);
          leaveChannelAndDestroy();
          break;
      }
    } else {
      isInCall.value = false;
      if (isJoinedChannel()) {
        debugPrint('Finished Channel');
        leaveChannelAndDestroy();
      }
    }
  }
}
