import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mime/mime.dart';

import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../helpers/api_manager.dart';
import '../helpers/identifier_type.dart';
import '../helpers/message_type.dart';
import '../helpers/socket_urls.dart';
import '../model/integration_response.dart';
import '../model/message.dart';
import '../model/message_request.dart';

/*Repository File that handles all the request that are sent to the server for complete funtion */
class ChatSocketRepository {
  /*
  When you are initializing the floating button, the information is downloaded from
  Laraigo's Website to allow customization online, that customization information is downloaded as 
  Json, called integration and saved in shared preferences
  */
  static Future<IntegrationResponse> getIntegration(
      String integrationId) async {
    //Request to get the integration Json data
    var response = await ApiManager.get(
        '${SocketUrls.baseBrokerEndpoint}integrations/$integrationId');
    final pref = await SharedPreferences.getInstance();
    //Saved into shared preferences as IntegrationId
    pref.setString(IdentifierType.integrationId.name, integrationId);

    print(IntegrationResponse.fromJson(jsonDecode(response.body)));

    return IntegrationResponse.fromJson(jsonDecode(response.body));
  }

  /*
  Request to send the message to Laraigo's Hook only used in Text  and Payload Type
   */
  static Future<Response> sendMessage(
      String message, String title, MessageType type) async {
    final pref = await SharedPreferences.getInstance();
    //Message request model is needed to ensure that the request is send correctly and recollects all the data needed
    MessageRequest request = MessageRequest(
        type: type.name,
        data: MessageRequestData(message: message, title: title),
        metadata: MessageRequestMetadata(idTemp: const Uuid().v4()),
        createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        senderId: pref.getString(IdentifierType.userId.name),
        sessionUuid: pref.getString(IdentifierType.sessionId.name),
        recipinetId: "HOOK",
        integrationId: pref.getString(IdentifierType.integrationId.name));
    //Serializing the data as Json
    var encoded = request.toJson();
    //Waiting for response while is sent as an Http Post
    var response = await ApiManager.post(
        '${SocketUrls.baseBrokerEndpoint}${SocketUrls.sendMessageEndpoint}',
        body: jsonEncode(encoded));
    return response;
  }

  /*
  Request to send the message to Laraigo's Hook  used all Media Messages Type (Video, Image, Location and File)
   */
  static Future<Response> sendMediaMessage(
      dynamic data, MessageType type) async {
    final pref = await SharedPreferences.getInstance();
    var encoded = {};
    //Validation of the Message Type that is going to be sent
    var messageType = type.name;
    switch (type) {
      case MessageType.media:
        var url = data as String;
        var parseName = url.split("/");
        final mimeType = lookupMimeType(url);
        //Validation of mimetype to know if the current media is a video or an image
        if (mimeType!.contains("jpg") ||
            mimeType.contains("jpeg") ||
            mimeType.contains("png") ||
            mimeType.contains("tiff") ||
            mimeType.contains("svg")) {
          messageType = "image";
        } else {
          messageType = "video";
        }
        //Message request model is needed to ensure that the request is send correctly and recollects all the data needed
        MessageRequest request = MessageRequest(
            type: messageType,
            data: MessageRequestData(
                mediaUrl: url,
                mimeType: mimeType,
                fileName: parseName[parseName.length - 1]),
            metadata: MessageRequestMetadata(idTemp: const Uuid().v4()),
            createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
            senderId: pref.getString(IdentifierType.userId.name),
            sessionUuid: pref.getString(IdentifierType.sessionId.name),
            recipinetId: "HOOK",
            integrationId: pref.getString(IdentifierType.integrationId.name));
        encoded = request.toJson();

        break;
      case MessageType.location:
        //In case of location it gets the coordinates that are going to be sent
        var position = data["data"][0] as Position;
        MessageRequest request = MessageRequest(
            type: type.name,
            data: MessageRequestData(
                lat: position.latitude,
                long: position.longitude,
                message: "Se envió data de localización"),
            metadata: MessageRequestMetadata(idTemp: const Uuid().v4()),
            createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
            senderId: pref.getString(IdentifierType.userId.name),
            sessionUuid: pref.getString(IdentifierType.sessionId.name),
            recipinetId: "HOOK",
            integrationId: pref.getString(IdentifierType.integrationId.name));
        encoded = request.toJson();
        break;
      //In case of file it gets the files that are going to be sent as an URL
      case MessageType.file:
        var url = data as String;
        var parseName = url.split("/");
        final mimeType = lookupMimeType(url);
        MessageRequest request = MessageRequest(
            type: type.name,
            data: MessageRequestData(
                mediaUrl: url,
                mimeType: mimeType,
                fileName: parseName[parseName.length - 1]),
            metadata: MessageRequestMetadata(idTemp: const Uuid().v4()),
            createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
            senderId: pref.getString(IdentifierType.userId.name),
            sessionUuid: pref.getString(IdentifierType.sessionId.name),
            recipinetId: "HOOK",
            integrationId: pref.getString(IdentifierType.integrationId.name));
        encoded = request.toJson();
        break;
      //No avalaible here
      case MessageType.text:
        break;
      //No avalaible here
      case MessageType.button:
        break;
      //No avalaible here
      case MessageType.carousel:
        break;
    }
    //Waiting for response while is sent as an Http Post
    var response = await ApiManager.post(
        '${SocketUrls.baseBrokerEndpoint}${SocketUrls.sendMessageEndpoint}',
        body: jsonEncode(encoded));
    return response;
  }

/*
To upload a file is mandatory to upload it first to and COS, that COS Api request only 
allows to recieve the data encoded as Base64 and need the properties of fileName and fileData
 */
  static Future<Response> uploadFile(PlatformFile file) async {
    //Converting Platformfile to File
    File fileToSend = File(file.path!);
    //Converting file to bytes
    List<int> imageBytes = fileToSend.readAsBytesSync();
    //Converting bytes to Base64
    String base64Image = base64Encode(imageBytes);
    var requestBody = {
      "fileName": 'EXTERNAL/${file.name}',
      "fileData": base64Image
    };
    //Waiting for response while is sent as an Http Post
    var response = await ApiManager.post(SocketUrls.baseFileUploadEndpoint,
        body: jsonEncode(requestBody));
    return response;
  }

/*
Function to save messages in local, the messages are saved in SharedPreferece to avoid 
using internal databases as SQLite, Hive, etc.
 */
  static Future<void> saveMessageInLocal(Message message) async {
    final pref = await SharedPreferences.getInstance();
    var validateMessages = pref.getString('messages');
    List<Message> messagesToSave = [];
    //The list of messages are intialized if the messages are null (no messages),
    //a new array of messages is created and the message is added to it
    if (validateMessages == null) {
      messagesToSave.add(message);
    } else {
      //If the list is not null we create a new decoded list where stores all the messages
      //that were previously saved in the device
      List decodedList = jsonDecode(validateMessages);
      try {
        messagesToSave = decodedList.map((e) => Message.fromJson(e)).toList();
      } catch (ex) {
        messagesToSave = [];
      }
      //If the message has the same TimeStamp means that the same message is going to be added twice
      //we filter those messages to not allow any unncesary adding
      messagesToSave.firstWhere(
        (element) => element.messageDate == message.messageDate,
        orElse: () {
          messagesToSave.add(message);
          return message;
        },
      );
    }
    //Finally we encode the messages to save it
    var encodedMessages = messagesToSave.map((e) => e.toJson()).toList();
    pref.setString('messages', jsonEncode(encodedMessages));

    if (kDebugMode) {
      print("Size del arreglo ${encodedMessages.length}");
    }
  }

  static Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');

      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  //This function is related to obtain all the local messages that were saved in the device to allow having a history
  //If there is any message saved we obtain it otherwise we return an empty array
  static Future<List<dynamic>> getLocalMessages() async {
    final pref = await SharedPreferences.getInstance();

    if (pref.getString('messages') != null) {
      var encodedMessages = pref.getString('messages');
      List decodedList = jsonDecode(encodedMessages!);

      return Future.value(decodedList);
    }
    return [];
  }

  static Future<File> downloadFile(String url, String filename) async {
    var httpClient = new HttpClient();

    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = File('$dir/$filename');
    // await file.writeAsBytes(bytes);
    return file;
  }
}
