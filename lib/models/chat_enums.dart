enum MessageType { message, audioCall, videoCall }

extension MessageTypeExtensions on MessageType {
  int get toInt {
    switch (this) {
      case MessageType.message:
        return 1;
      case MessageType.audioCall:
        return 2;
      case MessageType.videoCall:
        return 3;
    }
  }
}
extension IntegerExtensions on int {
  MessageType get toMessageType {
    switch (this) {
      case 1:
        return MessageType.message;
      case 2:
        return MessageType.audioCall;
      case 3:
        return MessageType.videoCall;
    }
    return MessageType.message;
  }
}
extension DateExtensions on DateTime {
  bool isSameAvoidTime(DateTime t) {
    return DateTime(t.year, t.month, t.day) == DateTime(year, month, day);
  }
}