import 'package:brokersdk/helpers/sender_type.dart';
import 'package:brokersdk/model/message_request.dart';
import 'package:brokersdk/model/message_response.dart';

class Message {
  bool? isUser;
  int? messageDate;
  String? message;
  Message(
      {required this.isUser, required this.message, required this.messageDate});

  static Message fromJson(Map<String, dynamic> json) {
    Message? message;
    if (json["sender"] == SenderType.user) {
      message = Message(
          isUser: true,
          message: json["message"],
          messageDate: json["messageDate"]);
    } else {
      MessageResponse response = MessageResponse.fromJson(json);
      message = Message(
          isUser: false,
          message: response.message!.data!.message,
          messageDate: response.receptionDate);
    }

    return message;
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
