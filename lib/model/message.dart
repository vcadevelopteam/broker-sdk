import '../helpers/message_type.dart';
import 'message_response.dart';

// Allows you to classify message content
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
        if (json["type"] == MessageType.text.name) {
          var messages = json["message"] as List;
          message = Message(
              type: MessageType.text,
              isUser: json['isUser'],
              isSaved: true,
              data: messages.map((e) => MessageResponseData.text(e)).toList(),
              messageDate: json['messageDate'] ?? json['receptionDate']);
        } else if (json["type"] == MessageType.media.name) {
          var messages = json["message"] as List;
          message = Message(
              type: MessageType.media,
              isUser: json['isUser'],
              isSaved: true,
              data: messages.map((e) => MessageResponseData.image(e)).toList(),
              messageDate: json['messageDate'] ?? json['receptionDate']);
        } else if (json["type"] == MessageType.location.name) {
          var messages = json["message"] as List;
          message = Message(
              type: MessageType.location,
              isUser: json['isUser'],
              isSaved: true,
              data:
                  messages.map((e) => MessageResponseData.location(e)).toList(),
              messageDate: json['messageDate'] ?? json['receptionDate']);
        } else {
          var messages = json["message"] as List;
          message = Message(
              type: MessageType.file,
              isUser: json['isUser'],
              isSaved: true,
              data: messages.map((e) => MessageResponseData.file(e)).toList(),
              messageDate: json['messageDate'] ?? json['receptionDate']);
        }
      } else {
        //VERIFICAR EL TIPO DE MENSAJE
        if (json["type"] == MessageType.text.name) {
          var messages = json["message"] as List;
          message = Message(
              type: MessageType.text,
              isSaved: true,
              isUser: json['isUser'],
              data: messages.map((e) => MessageResponseData.text(e)).toList(),
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
        } else if (json["type"] == MessageType.button.name) {
          var messages = json["message"] as List;
          message = Message(
              type: MessageType.button,
              isSaved: true,
              isUser: json['isUser'],
              data:
                  messages.map((e) => MessageResponseData.buttons(e)).toList(),
              messageDate: json['messageDate'] ?? json['receptionDate']);
        } else if (json["type"] == MessageType.media.name) {
          var messages = json["message"] as List;
          message = Message(
              type: MessageType.media,
              isSaved: true,
              isUser: json['isUser'],
              data: messages.map((e) => MessageResponseData.image(e)).toList(),
              messageDate: json['messageDate'] ?? json['receptionDate']);
        } else if (json["type"] == MessageType.location.name) {
          var messages = json["message"] as List;
          message = Message(
              type: MessageType.location,
              isSaved: true,
              isUser: json['isUser'],
              data:
                  messages.map((e) => MessageResponseData.location(e)).toList(),
              messageDate: json['messageDate'] ?? json['receptionDate']);
        } else {
          var messages = json["message"] as List;
          message = Message(
              type: MessageType.file,
              isSaved: true,
              isUser: json['isUser'],
              data: messages.map((e) => MessageResponseData.file(e)).toList(),
              messageDate: json['messageDate'] ?? json['receptionDate']);
        }
      }
    } else {
      var senderExists = json['isUser'] != null ? true : false;
      if (senderExists) {
        //VERIFICAR SI ES DEL USUARIO
        if (json["isUser"]) {
          if (json["type"] == MessageType.text.name) {
            var messagedata = json['message'] as MessageResponseData;
            message = Message(
                type: MessageType.text,
                isUser: json['isUser'],
                isSaved: true,
                data: [MessageResponseData.text(messagedata.toJson())],
                messageDate: json['messageDate'] ?? json['receptionDate']);
          } else if (json["type"] == MessageType.media.name) {
            var messagedata = json['message'] as MessageResponseData;
            message = Message(
                type: MessageType.media,
                isUser: json['isUser'],
                isSaved: true,
                data: [MessageResponseData.image(messagedata.toJson())],
                messageDate: json['messageDate'] ?? json['receptionDate']);
          } else if (json["type"] == MessageType.location.name) {
            var messagedata = json['message'] as MessageResponseData;
            message = Message(
                type: MessageType.location,
                isUser: json['isUser'],
                isSaved: true,
                data: [MessageResponseData.location(messagedata.toJson())],
                messageDate: json['messageDate'] ?? json['receptionDate']);
          } else {
            var messagedata = json['message'] as MessageResponseData;
            message = Message(
                type: MessageType.file,
                isUser: json['isUser'],
                isSaved: true,
                data: [MessageResponseData.file(messagedata.toJson())],
                messageDate: json['messageDate'] ?? json['receptionDate']);
          }
        } else {
          //RECIBIR LAS RESPUESTAS DEL SERVIDOR
          MessageResponse response = MessageResponse.fromJson(json);
          if (response.type == MessageType.text.name) {
            message = Message(
                type: MessageType.text,
                isUser: false,
                isSaved: true,
                data: response.message!.data,
                messageDate: response.receptionDate);
          } else if (response.type == MessageType.carousel.name) {
            message = Message(
                type: MessageType.carousel,
                isUser: false,
                isSaved: true,
                data: response.message!.data,
                messageDate: response.receptionDate);
          } else if (response.type == MessageType.button.name) {
            message = Message(
                type: MessageType.button,
                isUser: false,
                isSaved: true,
                data: response.message!.data,
                messageDate: response.receptionDate);
          } else if (response.type == MessageType.media.name) {
            message = Message(
                type: MessageType.media,
                isUser: false,
                isSaved: true,
                data: response.message!.data,
                messageDate: response.receptionDate);
          } else if (response.type == MessageType.file.name) {
            message = Message(
                type: MessageType.file,
                isUser: false,
                isSaved: true,
                data: response.message!.data,
                messageDate: response.receptionDate);
          } else {
            message = Message(
                type: MessageType.location,
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
              data: response.message!.data,
              messageDate: response.receptionDate);
        } else if (response.type == MessageType.carousel.name) {
          message = Message(
              type: MessageType.carousel,
              isUser: false,
              isSaved: true,
              data: response.message!.data,
              messageDate: response.receptionDate);
        } else if (response.type == MessageType.button.name) {
          message = Message(
              type: MessageType.button,
              isUser: false,
              isSaved: true,
              data: response.message!.data,
              messageDate: response.receptionDate);
        } else if (response.type == MessageType.media.name) {
          message = Message(
              type: MessageType.media,
              isUser: false,
              isSaved: true,
              data: response.message!.data,
              messageDate: response.receptionDate);
        } else if (response.type == MessageType.file.name) {
          message = Message(
              type: MessageType.file,
              isUser: false,
              isSaved: true,
              data: response.message!.data,
              messageDate: response.receptionDate);
        } else {
          message = Message(
              type: MessageType.location,
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

    messageToSend = data;

    return {
      'isUser': isUser,
      'message': messageToSend,
      'messageDate': messageDate,
      'type': type.name,
      'isSaved': isSaved
    };
  }
}
