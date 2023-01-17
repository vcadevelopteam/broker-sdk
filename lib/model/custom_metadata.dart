import 'color.dart';
import 'extra.dart';
import 'form_field.dart';
import 'icons.dart';
import 'personalization.dart';

class CustomMetadata {
  int? applicationId;
  int? integrationId;
  Color? color;
  Extra? extra;
  List<FormField>? form;
  Icons? icons;
  Personalization? personalization;

  CustomMetadata(
      {this.applicationId,
      this.color,
      this.icons,
      this.extra,
      this.form,
      this.integrationId,
      this.personalization});

  factory CustomMetadata.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> colorJson = json["color"];
    Map<String, dynamic> extraJson = json["extra"];
    Map<String, dynamic> iconsJson = json["icons"];
    Map<String, dynamic> personalizationJson = json["personalization"];
    List<Map<String, dynamic>> formJsonList = json["form"];

    return CustomMetadata(
        applicationId: json["applicationId"] ?? 0,
        integrationId: json["integrationId"] ?? 0,
        color: Color.fromJson(colorJson),
        extra: Extra.fromJson(extraJson),
        icons: Icons.fromJson(iconsJson),
        personalization: Personalization.fromJson(personalizationJson),
        form: formJsonList.map((e) => FormField.fromJson(e)).toList());
  }
}
