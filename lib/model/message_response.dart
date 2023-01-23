import 'package:brokersdk/helpers/message_type.dart';
import 'package:brokersdk/model/carousel_button.dart';

class MessageResponse {
  MessageSingleResponse? message;
  bool? error;
  bool isUser = false;
  int? receptionDate;
  String type;
  String? method;

  MessageResponse(
      {this.message,
      this.error,
      this.receptionDate,
      this.method,
      required this.type});

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    var message = MessageSingleResponse.fromJson(json["message"]);
    return MessageResponse(
        error: json["error"] ?? false,
        receptionDate: json["receptionDate"] ?? 0,
        method: json["method"] ?? "",
        type: message.type.toString(),
        message: message);
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
    } else {
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
    }
  }
}

class MessageResponseData {
  String? message;
  String? description;
  String? mediaUrl;
  String? title;
  String? action;
  List<CarouselButton>? buttons;

  MessageResponseData(
      {this.message,
      this.description,
      this.mediaUrl,
      this.title,
      this.action,
      this.buttons});
  factory MessageResponseData.text(Map<String, dynamic> json) {
    return MessageResponseData(message: json["message"] ?? "");
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
}
