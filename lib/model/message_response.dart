class MessageResponse {
  MessageSingleResponse? message;
  String? error;
  DateTime? receptionDate;
  String? method;
  MessageResponse({this.message, this.error, this.receptionDate, this.method});
}

class MessageSingleResponse {
  String? id;
  String? recipientId;
  String? senderId;
  DateTime? createdAt;
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
}

class MessageResponseData {
  String? messge;
  MessageResponseData({this.messge});
}
