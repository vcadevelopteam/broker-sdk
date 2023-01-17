import 'package:brokersdk/helpers/identifier_type.dart';
import 'package:brokersdk/helpers/socket_urls.dart';
import 'package:brokersdk/model/integration_response.dart';
import 'package:brokersdk/repository/chat_socket_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatSocket {
  final String? _integrationId;
  late final WebSocketChannel? channel;
  IntegrationResponse? integrationResponse;

  ChatSocket(this._integrationId, this.integrationResponse);

  static Future<ChatSocket> getInstance(String integrationId) async {
    var integrationResponse =
        await ChatSocketRepository.getIntegration(integrationId);

    return ChatSocket(integrationId, integrationResponse);
  }

  void connect() {
    var userId = _generateRandomId(IdentifierType.userId);
    var sessionId = _generateRandomId(IdentifierType.sessionId);
    channel = WebSocketChannel.connect(
      Uri.parse('${SocketUrls.baseSocketEndpoint}$userId/$sessionId'),
    );
  }

  Future<String> _generateRandomId(IdentifierType idType) async {
    final pref = await SharedPreferences.getInstance();
    final id = const Uuid().v4();
    pref.setString(idType.name, id);
    return id;
  }
}
