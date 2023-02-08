// Allows you to identify the icon preference displayed in chat
class IconsPreference {
  String? chatbotImage;
  String? chatHeaderImage;
  String? chatOpenImage;
  IconsPreference(
      {this.chatbotImage, this.chatHeaderImage, this.chatOpenImage});

  factory IconsPreference.fromJson(Map<String, dynamic> json) {
    return IconsPreference(
      chatHeaderImage: json["chatHeaderImage"] ?? "",
      chatOpenImage: json["chatOpenImage"] ?? "",
      chatbotImage: json["chatBotImage"] ?? "",
    );
  }
}
