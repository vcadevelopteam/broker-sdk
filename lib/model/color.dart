class Color {
  String? chatBackgroundColor;
  String? chatBorderColor;
  String? chatHeaderColor;
  String? messageBotColor;
  String? messageClientColor;

  Color(
      {this.chatBackgroundColor,
      this.chatBorderColor,
      this.chatHeaderColor,
      this.messageBotColor,
      this.messageClientColor});

  factory Color.fromJson(Map<String, dynamic> json) {
    return Color(
        chatBackgroundColor: json["chatBackgroundColor"] ?? "",
        chatBorderColor: json["chatBorderColor"] ?? "",
        chatHeaderColor: json["chatHeaderColor"] ?? "",
        messageBotColor: json["messageBotColor"] ?? "",
        messageClientColor: json["messageClientColor"] ?? "");
  }
}
