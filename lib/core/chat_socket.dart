import 'package:brokersdk/model/integration_response.dart';
import 'package:brokersdk/repository/chat_socket_repository.dart';

class ChatSocket {
  final String? _integrationId;
  IntegrationResponse? integrationResponse;

  ChatSocket(this._integrationId, this.integrationResponse);

  static Future<ChatSocket> getInstance(String integrationId) async {
    var integrationResponse =
        await ChatSocketRepository.getIntegration(integrationId);

    return ChatSocket(integrationId, integrationResponse);
  }
}
