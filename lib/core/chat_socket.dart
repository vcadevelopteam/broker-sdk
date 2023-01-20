import 'dart:async';

import 'package:brokersdk/helpers/identifier_type.dart';
import 'package:brokersdk/helpers/socket_urls.dart';
import 'package:brokersdk/model/integration_response.dart';
import 'package:brokersdk/model/message_response.dart';
import 'package:brokersdk/repository/chat_socket_repository.dart';
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
    print('${SocketUrls.baseSocketEndpoint}$userId/$sessionId');
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
}
