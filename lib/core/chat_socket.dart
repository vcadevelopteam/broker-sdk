import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:laraigo_chat/helpers/identifier_type.dart';
import 'package:laraigo_chat/helpers/message_type.dart';
import 'package:laraigo_chat/helpers/socket_urls.dart';
import 'package:laraigo_chat/model/integration_response.dart';
import 'package:laraigo_chat/model/message_response.dart';
import 'package:laraigo_chat/repository/chat_socket_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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

  void disconnect() {
    channel = null;
    controller = null;
  }

  Future<String> _generateRandomId(IdentifierType idType) async {
    final pref = await SharedPreferences.getInstance();
    if (pref.getString(idType.name) != null) {
      return pref.getString(idType.name)!;
    }
    final id = const Uuid().v4();
    pref.setString(idType.name, id);
    return id;
  }

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
