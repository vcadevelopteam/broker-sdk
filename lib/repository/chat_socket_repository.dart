import 'dart:convert';

import 'package:brokersdk/helpers/api_manager.dart';
import 'package:brokersdk/helpers/socket_urls.dart';
import 'package:brokersdk/model/integration_response.dart';

class ChatSocketRepository {
  static Future<IntegrationResponse> getIntegration(
      String integrationId) async {
    IntegrationResponse integrationResponse;
    var response = await ApiManager.get(SocketUrls.baseBrokerEndpoint);
    return IntegrationResponse.fromJson(jsonDecode(response.body));
  }
}
