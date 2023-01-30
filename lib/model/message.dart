import 'package:brokersdk/helpers/message_type.dart';
import 'package:brokersdk/helpers/sender_type.dart';
import 'package:brokersdk/model/message_request.dart';
import 'package:brokersdk/model/message_response.dart';
import 'package:flutter/foundation.dart';

class Message {
  bool? isUser;
  bool isSaved = false;
  int? messageDate;
  String? message;
  MessageType type;
  List<MessageResponseData>? data;
  Message(
      {required this.isUser,
      this.message,
      required this.messageDate,
      this.data,
      required this.isSaved,
      required this.type});

  static Message fromJson(Map<String, dynamic> json) {
    Message? message;
    //VERIFICAR SI EL MENSAJE SE LEE DESDE EL SERVIDOR O DESDE
    // EL GUARDADO LOCAL
    if (json['isSaved'] != null) {
      //VERIFICAR SI ES DEL USUARIO O DEL CHAT / BOT
      if (json["isUser"]) {
        message = Message(
            type: MessageType.text,
            isUser: json['isUser'],
            isSaved: true,
            message: json['message'],
            messageDate: json['messageDate'] ?? json['receptionDate']);
      } else {
        //VERIFICAR EL TIPO DE MENSAJE
        if (json["type"] == MessageType.text.name) {
          message = Message(
              type: MessageType.text,
              isSaved: true,
              isUser: json['isUser'],
              message: json['message'],
              messageDate: json['messageDate'] ?? json['receptionDate']);
        } else if (json["type"] == MessageType.carousel.name) {
          var messages = json["message"] as List;
          message = Message(
              type: MessageType.carousel,
              isSaved: true,
              isUser: json['isUser'],
              data:
                  messages.map((e) => MessageResponseData.carousel(e)).toList(),
              messageDate: json['messageDate'] ?? json['receptionDate']);
        } else {
          var messages = json["message"] as List;
          message = Message(
              type: MessageType.buttons,
              isSaved: true,
              isUser: json['isUser'],
              data:
                  messages.map((e) => MessageResponseData.buttons(e)).toList(),
              messageDate: json['messageDate'] ?? json['receptionDate']);
        }
      }
    } else {
      var senderExists = json['isUser'] != null ? true : false;
      if (senderExists) {
        //VERIFICAR SI ES DEL USUARIO
        if (json["isUser"]) {
          message = Message(
              type: MessageType.text,
              isUser: json['isUser'],
              isSaved: true,
              message: json['message'],
              messageDate: json['messageDate'] ?? json['receptionDate']);
        } else {
          //RECIBIR LAS RESPUESTAS DEL SERVIDOR
          MessageResponse response = MessageResponse.fromJson(json);
          if (response.type == MessageType.text.name) {
            message = Message(
                type: MessageType.text,
                isUser: false,
                isSaved: true,
                message: response.message!.data![0].message,
                messageDate: response.receptionDate);
          } else if (response.type == MessageType.carousel.name) {
            message = Message(
                type: MessageType.carousel,
                isUser: false,
                isSaved: true,
                data: response.message!.data,
                messageDate: response.receptionDate);
          } else {
            message = Message(
                type: MessageType.buttons,
                isUser: false,
                isSaved: true,
                data: response.message!.data,
                messageDate: response.receptionDate);
          }
        }
      } else {
        //RECIBIR LAS RESPUESTAS DEL SERVIDOR PARA NO CAER EN NULOS
        MessageResponse response = MessageResponse.fromJson(json);
        if (response.type == MessageType.text.name) {
          message = Message(
              type: MessageType.text,
              isUser: false,
              isSaved: true,
              message: response.message!.data![0].message,
              messageDate: response.receptionDate);
        } else if (response.type == MessageType.carousel.name) {
          message = Message(
              type: MessageType.carousel,
              isUser: false,
              isSaved: true,
              data: response.message!.data,
              messageDate: response.receptionDate);
        } else {
          message = Message(
              type: MessageType.buttons,
              isUser: false,
              isSaved: true,
              data: response.message!.data,
              messageDate: response.receptionDate);
        }
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
      'type': type.name,
      'isSaved': isSaved
    };
  }
}
