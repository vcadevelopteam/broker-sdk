class Icons {
  String? chatbotImage;
  String? chatHeaderImage;
  String? chatOpenImage;
  Icons({this.chatbotImage, this.chatHeaderImage, this.chatOpenImage});

  factory Icons.fromJson(Map<String, dynamic> json) {
    return Icons(
      chatHeaderImage: json["chatHeaderImage"] ?? "",
      chatOpenImage: json["chatOpenImage"] ?? "",
      chatbotImage: json["chatbotImage"] ?? "",
    );
  }
}
