import 'custom_metadata.dart';

//Allows you to identify data from the IntegrationResponse needed to start laraigo's service
class IntegrationResponse {
  String? applicationId;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;
  String? name;
  String? status;
  String? type;
  CustomMetadata? metadata;

  IntegrationResponse(
      {this.applicationId,
      this.createdAt,
      this.updatedAt,
      this.id,
      this.metadata,
      this.name,
      this.status,
      this.type});

  factory IntegrationResponse.fromJson(Map<String, dynamic> json) {
    return IntegrationResponse(
        id: json["id"] ?? "",
        applicationId: json["applicationId"] ?? "",
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(json["createdAt"] * 1000),
        name: json["name"] ?? "",
        status: json["status"] ?? "",
        type: json["type"] ?? "",
        updatedAt:
            DateTime.fromMillisecondsSinceEpoch(json["updatedAt"] * 1000),
        metadata: CustomMetadata.fromJson(
          json["metadata"],
        ));
  }
}
