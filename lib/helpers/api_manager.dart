import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
/*
Class that encapsule all the API Manager methods to allow seding and receiving 
Http Requests from/to the online server
 */

//Types of requests
enum RequestType { get, post, put, delete }

//Method that allows getting the headers to use in the request
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
  /*Template for GET requests */
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

  /*Template for POST requests */
  static Future<http.Response> post(
    String path, {
    Map<String, dynamic> params = const {},
    String body = "",
    bool tokenRequired = true,
  }) async {
    var uri = Uri.parse(path);
    uri.replace(queryParameters: params);
    final headers = await _getHeaders(RequestType.post);
    final response = await http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 300), onTimeout: () {
      return decorateResponse(http.Response('Time out exception', 504));
    });
    return decorateResponse(response);
  }
}

/*A custom response to any of the previous requests*/
http.Response decorateResponse(http.Response response) {
  // debugPrint('req: ${response.request!.url} ${response.statusCode}');
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

/*Class that allow handling the exceptions and showing them to the users */
class RequestException extends HttpException {
  final int status;

  const RequestException({required String message, required this.status})
      : super(message);

  @override
  String toString() {
    return message;
  }
}
