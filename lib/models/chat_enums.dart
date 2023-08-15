enum MessageType { message, audioCall, videoCall }

enum CallConnectionType { incoming, connected, outgoing, finished }

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

extension CallConnectionTypeExtensions on CallConnectionType {
  int get toInt {
    switch (this) {
      case CallConnectionType.incoming:
        return 1;
      case CallConnectionType.connected:
        return 2;
      case CallConnectionType.outgoing:
        return 3;
      case CallConnectionType.finished:
        return 4;
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

  CallConnectionType get toCallConnectionType {
    switch (this) {
      case 1:
        return CallConnectionType.incoming;
      case 2:
        return CallConnectionType.connected;
      case 3:
        return CallConnectionType.outgoing;
      case 4:
        return CallConnectionType.finished;
    }
    return CallConnectionType.finished;
  }
}

extension DateExtensions on DateTime {
  bool isSameAvoidTime(DateTime t) {
    return DateTime(t.year, t.month, t.day) == DateTime(year, month, day);
  }
}
