import 'custom_metadata.dart';

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
        createdAt: DateTime.now(),
        name: json["name"] ?? "",
        status: json["status"] ?? "",
        type: json["type"] ?? "",
        updatedAt: DateTime.now(),
        metadata: CustomMetadata.fromJson(
          json["metada"],
        ));
  }
}
