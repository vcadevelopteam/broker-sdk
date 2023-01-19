class MessageResponse {
  MessageSingleResponse? message;
  bool? error;
  bool isUser = false;
  int? receptionDate;
  String? method;
  MessageResponse({this.message, this.error, this.receptionDate, this.method});

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
        error: json["error"] ?? false,
        receptionDate: json["receptionDate"] ?? 0,
        method: json["method"] ?? "",
        message: MessageSingleResponse.fromJson(json["message"]));
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
  MessageResponseData? data;
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
    return MessageSingleResponse(
        createdAt: json["createdAt"] ?? 0,
        id: json["id"] ?? "",
        integrationId: json["integrationId"] ?? "",
        recipientId: json["recipientId"] ?? "",
        senderId: json["senderId"] ?? "",
        type: json["text"] ?? "",
        data: MessageResponseData.fromJson(json["data"]),
        sessionUuid: json["sessionUuid"] ?? "");
  }
}

class MessageResponseData {
  String? message;
  MessageResponseData({this.message});
  factory MessageResponseData.fromJson(Map<String, dynamic> json) {
    return MessageResponseData(message: json["message"] ?? "");
  }
}
