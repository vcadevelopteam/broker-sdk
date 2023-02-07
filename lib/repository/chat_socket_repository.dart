import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mime/mime.dart';

import 'package:laraigo_chat/helpers/api_manager.dart';
import 'package:laraigo_chat/helpers/identifier_type.dart';
import 'package:laraigo_chat/helpers/message_type.dart';
import 'package:laraigo_chat/helpers/socket_urls.dart';
import 'package:laraigo_chat/model/integration_response.dart';
import 'package:laraigo_chat/model/message.dart';
import 'package:laraigo_chat/model/message_request.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ChatSocketRepository {
  static Future<IntegrationResponse> getIntegration(
      String integrationId) async {
    var response = await ApiManager.get(
        '${SocketUrls.baseBrokerEndpoint}integrations/$integrationId');
    final pref = await SharedPreferences.getInstance();
    pref.setString(IdentifierType.integrationId.name, integrationId);

    return IntegrationResponse.fromJson(jsonDecode(response.body));
  }

  static Future<Response> sendMessage(
      String message, String title, MessageType type) async {
    final pref = await SharedPreferences.getInstance();

    MessageRequest request = MessageRequest(
        type: type.name,
        data: MessageRequestData(message: message, title: title),
        metadata: MessageRequestMetadata(idTemp: const Uuid().v4()),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        senderId: pref.getString(IdentifierType.userId.name),
        sessionUuid: pref.getString(IdentifierType.sessionId.name),
        recipinetId: "HOOK",
        integrationId: pref.getString(IdentifierType.integrationId.name));

    var encoded = request.toJson();

    var response = await ApiManager.post(
        '${SocketUrls.baseBrokerEndpoint}${SocketUrls.sendMessageEndpoint}',
        body: jsonEncode(encoded));
    return response;
  }

  static Future<Response> sendMediaMessage(
      dynamic data, MessageType type) async {
    final pref = await SharedPreferences.getInstance();
    var encoded = {};
    var messageType = type.name;
    switch (type) {
      case MessageType.media:
        var url = data as String;
        var parseName = url.split("/");
        final mimeType = lookupMimeType(url);

        if (mimeType!.contains("jpg") ||
            mimeType!.contains("jpeg") ||
            mimeType!.contains("png") ||
            mimeType!.contains("tiff") ||
            mimeType!.contains("svg")) {
          messageType = "image";
        } else {
          messageType = "video";
        }
        MessageRequest request = MessageRequest(
            type: messageType,
            data: MessageRequestData(
                mediaUrl: url,
                mimeType: mimeType,
                fileName: parseName[parseName.length - 1]),
            metadata: MessageRequestMetadata(idTemp: const Uuid().v4()),
            createdAt: DateTime.now().millisecondsSinceEpoch,
            senderId: pref.getString(IdentifierType.userId.name),
            sessionUuid: pref.getString(IdentifierType.sessionId.name),
            recipinetId: "HOOK",
            integrationId: pref.getString(IdentifierType.integrationId.name));
        encoded = request.toJson();

        break;
      case MessageType.location:
        var position = data["data"] as Position;
        MessageRequest request = MessageRequest(
            type: type.name,
            data: MessageRequestData(
                lat: position.latitude,
                long: position.longitude,
                message: "Se envió data de localización"),
            metadata: MessageRequestMetadata(idTemp: const Uuid().v4()),
            createdAt: DateTime.now().millisecondsSinceEpoch,
            senderId: pref.getString(IdentifierType.userId.name),
            sessionUuid: pref.getString(IdentifierType.sessionId.name),
            recipinetId: "HOOK",
            integrationId: pref.getString(IdentifierType.integrationId.name));
        encoded = request.toJson();
        break;
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
            createdAt: DateTime.now().millisecondsSinceEpoch,
            senderId: pref.getString(IdentifierType.userId.name),
            sessionUuid: pref.getString(IdentifierType.sessionId.name),
            recipinetId: "HOOK",
            integrationId: pref.getString(IdentifierType.integrationId.name));
        encoded = request.toJson();
        break;
    }

    var response = await ApiManager.post(
        '${SocketUrls.baseBrokerEndpoint}${SocketUrls.sendMessageEndpoint}',
        body: jsonEncode(encoded));
    return response;
  }

  static Future<Response> uploadImage(PlatformFile file) async {
    File fileToSend = File(file.path!);
    List<int> imageBytes = fileToSend.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    var requestBody = {
      "fileName": 'EXTERNAL/${file.name}',
      "fileData": base64Image
    };

    var response = await ApiManager.post(SocketUrls.baseFileUploadEndpoint,
        body: jsonEncode(requestBody));
    return response;
  }

  static Future<Response> uploadFile(PlatformFile file) async {
    File fileToUpload = File(file.path!);

    List<int> imageBytes = fileToUpload.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    var requestBody = {
      "fileName": 'EXTERNAL/${file.name}',
      "fileData": base64Image
    };

    var response = await ApiManager.post(SocketUrls.baseFileUploadEndpoint,
        body: jsonEncode(requestBody));
    return response;
  }

  static Future<void> saveMessageInLocal(Message message) async {
    final pref = await SharedPreferences.getInstance();
    var validateMessages = pref.getString('messages');
    List<Message> messagesToSave = [];
    if (validateMessages == null) {
      messagesToSave.add(message);
    } else {
      List decodedList = jsonDecode(validateMessages);
      try {
        messagesToSave = decodedList.map((e) => Message.fromJson(e)).toList();
      } catch (ex) {
        messagesToSave = [];
      }

      messagesToSave.firstWhere(
        (element) => element.messageDate == message.messageDate,
        orElse: () {
          messagesToSave.add(message);
          return message;
        },
      );
    }
    var encodedMessages = messagesToSave.map((e) => e.toJson()).toList();
    pref.setString('messages', jsonEncode(encodedMessages));

    print("Size del arreglo " + encodedMessages.length.toString());
  }

  static Future<List<dynamic>> getLocalMessages() async {
    final pref = await SharedPreferences.getInstance();

    if (pref.getString('messages') != null) {
      var encodedMessages = pref.getString('messages');
      List decodedList = jsonDecode(encodedMessages!);

      return Future.value(decodedList);
    }
    return [];
  }
}
