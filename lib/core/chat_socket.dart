// ignore_for_file: body_might_complete_normally_nullable, unused_field, avoid_init_to_null

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../helpers/identifier_type.dart';
import '../helpers/message_type.dart';
import '../helpers/socket_urls.dart';
import '../model/integration_response.dart';
import '../model/message_response.dart';
import '../repository/chat_socket_repository.dart';

/*
Main package class, it encapsules the main methods for the first initialization of the ChatSocket
 */
class ChatSocket {
  final String? _integrationId;
  WebSocketChannel? channel = null;
  IntegrationResponse? integrationResponse;
  StreamController? controller = StreamController();
  ChatSocket(this._integrationId, this.integrationResponse);

  static Future<ChatSocket> getInstance(String integrationId) async {
    var integrationResponse =
        await ChatSocketRepository.getIntegration(integrationId);

    return ChatSocket(integrationId, integrationResponse);
  }

//The connect method allows user to connect to the Laraigo Chat Web using an userId and sessionId
  Future<void> connect() async {
    var userId = await _generateRandomId(IdentifierType.userId);
    var sessionId = await _generateRandomId(IdentifierType.sessionId);

    channel = WebSocketChannel.connect(
      Uri.parse('${SocketUrls.baseSocketEndpoint}$userId/$sessionId'),
    );
    controller = StreamController();
    if (kDebugMode) {
      print('${SocketUrls.baseSocketEndpoint}$userId/$sessionId');
    }
  }

//The disconect method allows user to disconnect from the ChatSocket
//The disconect method set nulls to dispose the chat socket current initialization to allow a future reconnection
  void disconnect() {
    channel = null;
    controller = null;
  }

  //Method to generate a randonId for Identifiers
  Future<String> _generateRandomId(IdentifierType idType) async {
    final pref = await SharedPreferences.getInstance();
    if (pref.getString(idType.name) != null) {
      return pref.getString(idType.name)!;
    }
    final id = const Uuid().v4();
    pref.setString(idType.name, id);
    return id;
  }

  //Method to send text messages
  static Future<Map?> sendMessage(String text, String title) async {
    var response =
        await ChatSocketRepository.sendMessage(text, title, MessageType.text);
    if (response.statusCode != 500 || response.statusCode != 400) {
      List<MessageResponseData> data = [];
      data.add(MessageResponseData(message: text, title: title));
      var messageSent = MessageResponse(
              type: MessageType.text.name,
              isUser: true,
              error: false,
              message: MessageSingleResponse(
                  createdAt: DateTime.now().millisecondsSinceEpoch,
                  data: data,
                  type: MessageType.text.name,
                  id: const Uuid().v4().toString()),
              receptionDate: DateTime.now().millisecondsSinceEpoch)
          .toJson();
      return messageSent;
    }
  }
}
