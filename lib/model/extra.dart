class Extra {
  String? cssBody;
  String? cssHeader;
  String? enableFormHistory;
  String? inputAlwaysActive;
  String? playerAlertSound;
  String? showChatRestart;
  String? showLaraigoLogo;
  String? showPlatformLogo;
  String? uploadAudio;
  String? uploadFile;
  String? uploadImage;
  String? uploadVideo;
  Extra(
      {this.cssBody,
      this.cssHeader,
      this.enableFormHistory,
      this.inputAlwaysActive,
      this.playerAlertSound,
      this.showChatRestart,
      this.showLaraigoLogo,
      this.showPlatformLogo,
      this.uploadAudio,
      this.uploadFile,
      this.uploadImage,
      this.uploadVideo});

  factory Extra.fromJson(Map<String, dynamic> json) {
    return Extra(
      cssBody: json["cssBody"] ?? "",
      cssHeader: json["cssHeader"] ?? "",
      enableFormHistory: json["enableFormHistory"] ?? "",
      inputAlwaysActive: json["inputAlwaysActive"] ?? "",
      playerAlertSound: json["playerAlertSound"] ?? "",
      showChatRestart: json["showChatRestart"] ?? "",
      showLaraigoLogo: json["showLaraigoLogo"] ?? "",
      showPlatformLogo: json["showPlatformLogo"] ?? "",
      uploadAudio: json["uploadAudio"] ?? "",
      uploadFile: json["uploadFile"] ?? "",
      uploadImage: json["uploadImage"] ?? "",
      uploadVideo: json["uploadVideo"] ?? "",
    );
  }
}
