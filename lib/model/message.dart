import 'package:brokersdk/helpers/message_type.dart';
import 'package:brokersdk/helpers/sender_type.dart';
import 'package:brokersdk/model/message_request.dart';
import 'package:brokersdk/model/message_response.dart';
import 'package:flutter/foundation.dart';

class Message {
  bool? isUser;
  int? messageDate;
  String? message;
  MessageType type;
  List<MessageResponseData>? data;
  Message(
      {required this.isUser,
      this.message,
      required this.messageDate,
      this.data,
      required this.type});

  static Message fromJson(Map<String, dynamic> json) {
    Message? message;
    // MessageResponse response = MessageResponse.fromJson(json);
    var sender = json["isUser"] != null ? true : false;
    if (sender) {
      message = Message(
          type: MessageType.text,
          isUser: json['isUser'],
          message: json['message'],
          messageDate: json['messageDate'] ?? json['receptionDate']);
    } else {
      MessageResponse response = MessageResponse.fromJson(json);
      if (response.type == MessageType.text.name) {
        message = Message(
            type: MessageType.text,
            isUser: false,
            message: response.message!.data![0].message,
            messageDate: response.receptionDate);
      } else {
        message = Message(
            type: MessageType.carousel,
            isUser: false,
            data: response.message!.data,
            messageDate: response.receptionDate);
      }
    }

    return message;
  }

  Map<String, dynamic> toJson() {
    var messageToSend;
    if (type == MessageType.text) {
      messageToSend = message;
    } else {
      messageToSend = data;
    }

    return {
      'isUser': isUser,
      'message': messageToSend,
      'messageDate': messageDate,
      'type': type!.name,
    };
  }
}
