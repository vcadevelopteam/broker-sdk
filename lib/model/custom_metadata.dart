import 'color_preference.dart';
import 'extra.dart';
import 'form_field.dart';
import 'icons_preference.dart.dart';
import 'personalization.dart';

//Data used to integrate chat services
class CustomMetadata {
  int? applicationId;
  int? integrationId;
  ColorPreference? color;
  Extra? extra;
  List<FormField>? form;
  IconsPreference? icons;
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
    List<dynamic> formJsonList = json["form"];

    return CustomMetadata(
        applicationId: json["applicationid"] ?? 0,
        integrationId: json["integrationid"] ?? 0,
        color: ColorPreference.fromJson(colorJson),
        extra: Extra.fromJson(extraJson),
        icons: IconsPreference.fromJson(iconsJson),
        personalization: Personalization.fromJson(personalizationJson),
        form: formJsonList.map((e) => FormField.fromJson(e)).toList());
  }
}
