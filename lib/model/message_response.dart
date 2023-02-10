// ignore_for_file: prefer_typing_uninitialized_variables

import '../helpers/message_type.dart';
import 'carousel_button.dart';

// Allows you to classify the message type
class MessageResponse {
  MessageSingleResponse? message;
  bool? error;
  bool? isUser;
  int? receptionDate;
  String type;
  String? sender;
  String? method;

  MessageResponse(
      {this.message,
      this.error,
      this.isUser,
      this.receptionDate,
      this.method,
      this.sender,
      required this.type});

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    var message = MessageSingleResponse.fromJson(json["message"]);
    return MessageResponse(
        error: json["error"] ?? false,
        receptionDate: json["receptionDate"] ?? 0,
        method: json["method"] ?? "",
        isUser: json["isUser"],
        sender: json["sender"] ?? "",
        type: message.type.toString(),
        message: message);
  }

  toJson() {
    var messageToSend;
    if (type == MessageType.text.name ||
        type == MessageType.button.name ||
        type == MessageType.media.name ||
        type == MessageType.location.name ||
        type == MessageType.file.name) {
      messageToSend = message!.data![0];
    } else {
      messageToSend = message!.toJson();
    }
    return {
      'isUser': isUser,
      'message': messageToSend,
      'error': error,
      'receptionDate': receptionDate,
      'method': method,
      'type': type
    };
  }
}

class MessageSingleResponse {
  String? id;
  String? recipientId;
  String? senderId;
  int? createdAt;
  String? type;
  String? integrationId;
  String? sessionUuid;
  List<MessageResponseData>? data;
  MessageSingleResponse(
      {this.id,
      this.createdAt,
      this.data,
      this.integrationId,
      this.recipientId,
      this.senderId,
      this.sessionUuid,
      this.type});

  toJson() {
    var dataToSend;
    if (type == MessageType.text.name ||
        type == MessageType.button.name ||
        type == MessageType.media.name ||
        type == MessageType.file.name) {
      dataToSend = data!.map((e) => e.toJson()).toList()[0];
    } else {
      dataToSend = data!.map((e) => e.toJson()).toList();
    }

    return {
      'senderId': senderId,
      'createdAt': createdAt,
      'type': type,
      'integrationId': integrationId,
      'sessionId': sessionUuid,
      'data': dataToSend,
    };
  }

  factory MessageSingleResponse.fromJson(Map<String, dynamic> json) {
    var type = json["type"] as String;

    if (type == MessageType.text.name) {
      return MessageSingleResponse(
          createdAt: json["createdAt"] ?? 0,
          id: json["id"] ?? "",
          integrationId: json["integrationId"] ?? "",
          recipientId: json["recipientId"] ?? "",
          senderId: json["senderId"] ?? "",
          type: json["type"] ?? "",
          data: [MessageResponseData.text(json["data"])],
          sessionUuid: json["sessionUuid"] ?? "");
    } else if (type == MessageType.carousel.name) {
      var data = json["data"] as List;
      return MessageSingleResponse(
          createdAt: json["createdAt"] ?? 0,
          id: json["id"] ?? "",
          integrationId: json["integrationId"] ?? "",
          recipientId: json["recipientId"] ?? "",
          senderId: json["senderId"] ?? "",
          type: json["type"] ?? "",
          data: data.map((e) => MessageResponseData.carousel(e)).toList(),
          sessionUuid: json["sessionUuid"] ?? "");
    } else if (type == MessageType.button.name) {
      var data = json["data"] as Map<String, dynamic>;
      return MessageSingleResponse(
          createdAt: json["createdAt"] ?? 0,
          id: json["id"] ?? "",
          integrationId: json["integrationId"] ?? "",
          recipientId: json["recipientId"] ?? "",
          senderId: json["senderId"] ?? "",
          type: json["type"] ?? "",
          data: [MessageResponseData.buttons(data)],
          sessionUuid: json["sessionUuid"] ?? "");
    } else if (type == MessageType.media.name) {
      var data = json["data"] as Map<String, dynamic>;
      return MessageSingleResponse(
          createdAt: json["createdAt"] ?? 0,
          id: json["id"] ?? "",
          integrationId: json["integrationId"] ?? "",
          recipientId: json["recipientId"] ?? "",
          senderId: json["senderId"] ?? "",
          type: json["type"] ?? "",
          data: [MessageResponseData.image(data)],
          sessionUuid: json["sessionUuid"] ?? "");
    } else if (type == MessageType.location.name) {
      var data = json["data"] as Map<String, dynamic>;
      return MessageSingleResponse(
          createdAt: json["createdAt"] ?? 0,
          id: json["id"] ?? "",
          integrationId: json["integrationId"] ?? "",
          recipientId: json["recipientId"] ?? "",
          senderId: json["senderId"] ?? "",
          type: json["type"] ?? "",
          data: [MessageResponseData.location(data)],
          sessionUuid: json["sessionUuid"] ?? "");
    } else {
      var data = json["data"] as Map<String, dynamic>;
      return MessageSingleResponse(
          createdAt: json["createdAt"] ?? 0,
          id: json["id"] ?? "",
          integrationId: json["integrationId"] ?? "",
          recipientId: json["recipientId"] ?? "",
          senderId: json["senderId"] ?? "",
          type: json["type"] ?? "",
          data: [MessageResponseData.file(data)],
          sessionUuid: json["sessionUuid"] ?? "");
    }
  }
}

class MessageResponseData {
  String? message;
  String? description;
  String? mediaUrl;
  String? title;
  String? action;
  String? filename;
  int? height;
  int? width;
  double? lat;
  double? long;
  String? mimeType;
  List<CarouselButton>? buttons;

  MessageResponseData(
      {this.message,
      this.description,
      this.mediaUrl,
      this.title,
      this.mimeType,
      this.filename,
      this.height,
      this.width,
      this.action,
      this.lat,
      this.long,
      this.buttons});

  toJson() {
    return {
      'height': height,
      'width': width,
      'mimeType': mimeType,
      'fileName': filename,
      'message': message,
      'description': description,
      'latitude': lat,
      'longitude': long,
      'mediaUrl': mediaUrl,
      'title': title,
      'action': action,
      'buttons': buttons != null ? buttons!.map((e) => e.toJson()).toList() : []
    };
  }

  factory MessageResponseData.text(Map<String, dynamic> json) {
    return MessageResponseData(
        message: json["message"] ?? "", title: json["title"] ?? "");
  }

  factory MessageResponseData.carousel(Map<String, dynamic> json) {
    var buttons = json["buttons"] as List;
    return MessageResponseData(
        message: json["message"] ?? "",
        description: json["description"] ?? "",
        mediaUrl: json["mediaUrl"] ?? "",
        title: json["title"],
        buttons: buttons.map((e) => CarouselButton.fromJson(e)).toList(),
        action: json['actions']);
  }

  factory MessageResponseData.buttons(Map<String, dynamic> json) {
    var buttons = json["buttons"] as List;

    return MessageResponseData(
      message: json["message"],
      buttons: buttons.map((e) => CarouselButton.fromJson(e)).toList(),
    );
  }

  factory MessageResponseData.image(Map<String, dynamic> json) {
    return MessageResponseData(
        mimeType: json['mimeType'],
        height: json["height"],
        filename: json["fileName"],
        width: json["width"],
        mediaUrl: json["mediaUrl"]);
  }
  factory MessageResponseData.file(Map<String, dynamic> json) {
    return MessageResponseData(
        mimeType: json['mimeType'],
        filename: json["fileName"],
        mediaUrl: json["mediaUrl"]);
  }

  factory MessageResponseData.location(Map<String, dynamic> json) {
    return MessageResponseData(
        message: json["message"] ?? "",
        lat: json["latitude"] ?? 0.0,
        long: json["longitude"] ?? 0.0);
  }
}
