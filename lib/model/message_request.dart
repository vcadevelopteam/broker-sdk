//Allows you to identify data to get and send information with laraigo's services
class MessageRequest {
  String? integrationId;
  String? sessionUuid;
  int? createdAt;
  String? recipinetId;
  String? senderId;
  String? type;
  MessageRequestData? data;
  MessageRequestMetadata? metadata;

  MessageRequest(
      {this.integrationId,
      this.sessionUuid,
      this.createdAt,
      this.recipinetId,
      this.data,
      this.metadata,
      this.senderId,
      this.type});

  toJson() {
    return {
      "integrationId": integrationId,
      "sessionUuid": sessionUuid,
      "createdAt": createdAt,
      "type": type,
      "recipientId": recipinetId,
      "senderId": senderId,
      "metadata": metadata!.toJson(),
      "data": data!.toJson()
    };
  }
}

class MessageRequestData {
  String? message;
  String? fileName;
  String? mimeType;
  String? mediaUrl;
  String? title;
  double? long;
  double? lat;
  MessageRequestData(
      {this.message,
      this.title,
      this.fileName,
      this.mimeType,
      this.mediaUrl,
      this.lat,
      this.long});
  toJson() {
    return {
      "message": message,
      "title": title,
      "fileName": fileName,
      "mimeTye": mimeType,
      "mediaUrl": mediaUrl,
      "longitude": long,
      "latitude": lat
    };
  }
}

class MessageRequestMetadata {
  String? idTemp;
  MessageRequestMetadata({this.idTemp});
  toJson() {
    return {"idtemp": idTemp};
  }
}
