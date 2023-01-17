import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum RequestType { get, post, put, delete }

Future<Map<String, String>> _getHeaders(RequestType type) async {
  final Map<String, String> headers = {
    HttpHeaders.acceptHeader: 'application/json',
  };
  if (type != RequestType.get) {
    headers[HttpHeaders.contentTypeHeader] = 'application/json';
  }
  return headers;
}

class ApiManager {
  static Future<http.Response> get(String path,
      {Map<String, dynamic> params = const {}}) async {
    var uri = Uri.parse(path);
    uri.replace(queryParameters: params);
    final headers = await _getHeaders(RequestType.get);
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 300), onTimeout: () {
      return decorateResponse(http.Response('Time out exception', 504));
    });
    return decorateResponse(response);
  }
}

http.Response decorateResponse(http.Response response) {
  debugPrint('req: ${response.request!.url} ${response.statusCode}');
  final code = response.statusCode;
  final body = response.body;

  switch (code) {
    case HttpStatus.internalServerError:
    case HttpStatus.badGateway:
    case HttpStatus.unauthorized:
    case HttpStatus.badRequest:
    case HttpStatus.notFound:
    case HttpStatus.gatewayTimeout:
      debugPrint("Error: $body");
      throw RequestException(
        message: 'Hubo un problema - Timeout',
        status: code,
      );
    case HttpStatus.forbidden:
      debugPrint("Error: $body");
      throw RequestException(
        message: 'Hubo un problema - Forbidden',
        status: code,
      );
    default:
      return response;
  }
}

class RequestException extends HttpException {
  final int status;

  const RequestException({required String message, required this.status})
      : super(message);

  @override
  String toString() {
    return message;
  }
}