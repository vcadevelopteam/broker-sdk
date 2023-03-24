// allows you identify extra information to upload new data between user and laraigo services
class Extra {
  String? cssBody;
  String? cssHeader;
  String? jsscript;
  bool? enableFormHistory;
  bool? inputAlwaysActive;
  bool? playerAlertSound;
  bool? showChatRestart;
  bool? showLaraigoLogo;
  bool? showPlatformLogo;
  bool? uploadAudio;
  bool? uploadFile;
  bool? uploadImage;
  bool? uploadVideo;
  int? chatTextSize;
  int? chatTextWeight;
  String? iconColorActive;
  String? iconColorDisabled;
  int? inputTextSize;
  int? inputTextWeight;
  bool? withBorder;
  bool? withHour;

  Extra({
    this.cssBody,
    this.cssHeader,
    this.enableFormHistory,
    this.inputAlwaysActive,
    this.playerAlertSound,
    this.showChatRestart,
    this.showLaraigoLogo,
    this.showPlatformLogo,
    this.uploadAudio,
    this.uploadFile,
    this.jsscript,
    this.uploadImage,
    this.uploadVideo,
    this.chatTextSize,
    this.chatTextWeight,
    this.iconColorActive,
    this.iconColorDisabled,
    this.inputTextSize,
    this.inputTextWeight,
    this.withBorder,
    this.withHour,
  });

  factory Extra.fromJson(Map<String, dynamic> json) {
    return Extra(
      cssBody: json["cssbody"] ?? "",
      jsscript: json["jsscript"] ?? "",
      cssHeader: json["cssheader"] ?? "",
      enableFormHistory: json["enableformhistory"] ?? false,
      inputAlwaysActive: json["inputalwaysactive"] ?? "",
      playerAlertSound: json["playalertsound"] ?? "",
      showChatRestart: json["showchatrestart"] ?? "",
      showLaraigoLogo: json["showlaraigologo"] ?? "",
      showPlatformLogo: json["showplatformlogo"] ?? "",
      uploadAudio: json["uploadaudio"] ?? "",
      uploadFile: json["uploadfile"] ?? "",
      uploadImage: json["uploadimage"] ?? "",
      uploadVideo: json["uploadvideo"] ?? "",
      chatTextSize: json["chatTextSize"] ?? 0,
      chatTextWeight: json["chatTextWeight"] ?? 0,
      iconColorActive: json["iconColorActive"] ?? "",
      iconColorDisabled: json["iconColorDisabled"] ?? "",
      inputTextSize: json["inputTextSize"] ?? 0,
      inputTextWeight: json["inputTextWeight"] ?? 0,
      withBorder: json["withBorder"] ?? false,
      withHour: json["withHour"] ?? false,
    );
  }
}
