class FormField {
  String? fielId;
  String? inputValidation;
  String? label;
  String? placeholder;
  String? required;
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
      fielId: json["fieId"] ?? "",
      inputValidation: json["inputValidation"] ?? "",
      label: json["label"] ?? "",
      placeholder: json["placeholder"] ?? "",
      required: json["required"] ?? "",
      type: json["type"] ?? "",
      validationText: json["validationText"] ?? "",
    );
  }
}
