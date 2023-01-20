import 'dart:convert';

import 'package:brokersdk/core/chat_socket.dart';
import 'package:brokersdk/helpers/api_manager.dart';
import 'package:brokersdk/helpers/identifier_type.dart';
import 'package:brokersdk/helpers/message_type.dart';
import 'package:brokersdk/helpers/socket_urls.dart';
import 'package:brokersdk/model/integration_response.dart';
import 'package:brokersdk/model/message.dart';
import 'package:brokersdk/model/message_request.dart';
import 'package:flutter/material.dart';
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

  static Future<Response> sendMessage(String message, MessageType type) async {
    final pref = await SharedPreferences.getInstance();

    MessageRequest request = MessageRequest(
        type: type.name,
        data: MessageRequestData(message: message, title: "null"),
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

  static Future<void> saveMessageInLocal(List<Message> messages) async {
    final pref = await SharedPreferences.getInstance();

    var encodedMessages = messages.map((e) => e.toJson()).toList();
    pref.setString('messages', jsonEncode(encodedMessages));

    var validateMessages = pref.getString('messages');
    List decodedList = jsonDecode(validateMessages!);
    print("Size del arreglo " + decodedList.length.toString());
  }
}
