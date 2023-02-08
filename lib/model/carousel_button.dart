//Allows to identify the information contained in the carousel buttons
class CarouselButton {
  String? payload;
  String? text;
  String? type;
  String? uri;

  CarouselButton({this.payload, this.text, this.type, this.uri});
  factory CarouselButton.fromJson(Map<String, dynamic> json) {
    return CarouselButton(
        payload: json["payload"] ?? "",
        text: json["text"] ?? "",
        type: json["type"] ?? "",
        uri: json["uri"] ?? "");
  }
  toJson() {
    return {'payload': payload, 'text': text, 'type': type, 'uri': uri};
  }
}
