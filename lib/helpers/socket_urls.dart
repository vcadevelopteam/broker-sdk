//Custom urls that are used in the package for a correct function
class SocketUrls {
  static const baseFileUploadEndpoint =
      "https://zyxmelinux2.zyxmeapp.com/zyxmetest/bridge/api/processzyxme/uploadfile";
  static const baseResourceEndpoint =
      "https://zyxmelinux.zyxmeapp.com/zyxme/chat/";
  static const baseBrokerEndpoint = "https://goo.zyxmeapp.com/api/";
  static const baseSocketEndpoint = "wss://goo.zyxmeapp.com/ws/";
  static const poweredByUrl =
      "${baseResourceEndpoint}Image/Zyxme-powered-2020.png";
  static const companyHeaderUrl = "${baseResourceEndpoint}Image/ZyxMeLogo.png";

  static const audioAlertUrl = "${baseResourceEndpoint}Audio/Alert.mp3";
  static const chatOpenUrl = "${baseResourceEndpoint}Image/Chat.png";
  static const chatBotUrl = "${baseResourceEndpoint}Image/Bot.png";

  static const sendMessageEndpoint = "messages/send";
}
