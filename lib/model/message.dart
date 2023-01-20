import 'package:brokersdk/model/message_request.dart';
import 'package:brokersdk/model/message_response.dart';

class Message {
  bool? isUser;
  Message({
    this.isUser,
  });

  static dynamic fromJson(Map<String, dynamic> json) {
    return MessageResponse.fromJson(json);
  }

  // Map<String, dynamic> ToJson(Message message) {
  //   return {
  //     'id': message.id,
  //     'text': message.text,
  //     'date': message.date,
  //     'is_user': message.isUser,
  //     'time': message.time,
  //     'url': message.url
  //   };
  // }
}
