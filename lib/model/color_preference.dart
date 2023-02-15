// Allows to identify the color preference to use in the UI of the chat 
class ColorPreference {
  String? chatBackgroundColor;
  String? chatBorderColor;
  String? chatHeaderColor;
  String? messageBotColor;
  String? messageClientColor;
  String? iconsColor;

  ColorPreference(
      {this.chatBackgroundColor,
      this.chatBorderColor,
      this.chatHeaderColor,
      this.messageBotColor,
      this.messageClientColor,
      this.iconsColor});

  factory ColorPreference.fromJson(Map<String, dynamic> json) {
    return ColorPreference(
        chatBackgroundColor: json["chatBackgroundColor"] ?? "",
        chatBorderColor: json["chatBorderColor"] ?? "",
        chatHeaderColor: json["chatHeaderColor"] ?? "",
        messageBotColor: json["messageBotColor"] ?? "",
        messageClientColor: json["messageClientColor"] ?? "",
        iconsColor: json["iconscolor"] ?? "");
        
  }
}
