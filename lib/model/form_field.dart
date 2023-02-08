// allows you to identify the information from the input chat
class FormField {
  String? fielId;
  String? inputValidation;
  String? label;
  String? placeholder;
  bool? required;
  String? type;
  String? validationText;
  FormField(
      {this.fielId,
      this.inputValidation,
      this.label,
      this.placeholder,
      this.required,
      this.type,
      this.validationText});
  factory FormField.fromJson(Map<String, dynamic> json) {
    return FormField(
      fielId: json["field"] ?? "",
      inputValidation: json["inputvalidation"] ?? "",
      label: json["label"] ?? "",
      placeholder: json["placeholder"] ?? "",
      required: json["required"] ?? "",
      type: json["type"] ?? "",
      validationText: json["validationtext"] ?? "",
    );
  }
}
