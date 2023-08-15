import 'package:dio/dio.dart';
import 'package:fissionvector_chat/models/agora_model.dart';
import 'package:fissionvector_chat/utils/functions/strings_constants.dart';
import 'package:flutter/cupertino.dart';

Future<AgoraResDm> getAgoraTempToken({
  required String channelId,
  required int uid,
}) async {
  try {
    debugPrint('RTC TOKEN -> Requesting token');
    final response = await Dio()
        .get('https://agora-rtc.supersyntax.dev/token', queryParameters: {
      'appId': StringConstants.agoraAppId,
      'appCertificate': StringConstants.agoraCertificate,
      'channelName': channelId,
      'uid': uid,
    });
    debugPrint('Response -> ${response.data}');
    debugPrint('Response URL -> ${response.requestOptions.path}');
    if (response.statusCode.toString().startsWith('2')) {
      return AgoraResDm.fromJson(response.data);
    }
    return AgoraResDm();
  } catch (err) {
    debugPrint('Error while generating temp token:$err');
    return AgoraResDm();
  }
}