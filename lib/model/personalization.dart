class Personalization {
  String? headerSubtitle;
  String? headerTitle;
  Personalization({this.headerSubtitle, this.headerTitle});

  factory Personalization.fromJson(Map<String, dynamic> json) {
    return Personalization(
      headerTitle: json["headerTitle"] ?? "",
      headerSubtitle: json["headerSubtitle"] ?? "",
    );
  }
}
