import 'dart:convert';
import 'package:fissionvector_chat/utils/functions/strings_constants.dart';

AgoraResDm agoraResDmFromJson(String str) =>
    AgoraResDm.fromJson(json.decode(str));

String agoraResDmToJson(AgoraResDm data) => json.encode(data.toJson());

class AgoraResDm {
  String token;
  String appId;
  String channelId;
  String message;
  int success;

  AgoraResDm({
    this.token = StringConstants.agoraToken,
    this.appId = StringConstants.agoraAppId,
    this.channelId = "",
    this.message = "",
    this.success = 0,
  });

  bool get isSuccess => success == 1;

  factory AgoraResDm.fromJson(Map<String, dynamic> json) => AgoraResDm(
    success: json["s"] ?? 0,
    message: json["message"] ?? "",
    token: json["r"] ?? StringConstants.agoraToken,
  );

  Map<String, dynamic> toJson() => {
    "token": token,
  };
}
