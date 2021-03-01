import 'dart:io';
import 'dart:convert';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:wifi/wifi.dart';
import 'package:http/http.dart' as http;

class ServerModel {
  static Future<void> start(String deviceIp) async {
    final server = await createServer(deviceIp);
    print('Server started: ${server.address} port ${server.port}');
    await handleRequests(server);
  }

  static Future<HttpServer> createServer(String deviceIp) async {
    final address = await Wifi.ip; // InternetAddress.loopbackIPv4;
    const port = 4040;
    return await HttpServer.bind(address, port);
  }

  static Future<void> handleRequests(HttpServer server) async {
    await for (HttpRequest request in server) {
      switch (request.method) {
        case 'GET':
          handleGet(request);
          break;
        case 'POST':
          handlePost(request);
          break;
        default:
          handleDefault(request);
      }
    }
  }

  static void handleGet(HttpRequest request) async {
    final path = request.uri.path;
    switch (path) {
      case '/ping':
        request.response
          ..statusCode = HttpStatus.ok
          ..close();
        break;
      case '/tables':
        break;
      case '/orders':
        break;
      case '/items':
        break;
      case '/shift':
        var _getShiftOpen = await getShiftOpen();
        request.response
          ..statusCode = HttpStatus.ok
          ..write(_getShiftOpen)
          ..close();
        break;
      default:
        handleGetOther(request);
    }
  }

  static getShiftOpen() async {
    return await Preferences.getStringValuesSF(Constant.IS_SHIFT_OPEN);
  }

  static void handleGetOther(HttpRequest request) {
    request.response
      ..statusCode = HttpStatus.badRequest
      ..close();
  }

  static Future<void> handlePost(HttpRequest request) async {
    final path = request.uri.path;
    switch (path) {
      case '/items':
        break;
      default:
    }
    request.response
      ..write('Got it. Thanks.')
      ..close();
  }

  static void handleDefault(HttpRequest request) {
    request.response
      ..statusCode = HttpStatus.methodNotAllowed
      ..write('Unsupported request: ${request.method}.')
      ..close();
  }
  
  static broadcastByURL(String apiURL, Map<String, dynamic> params) async {
    final address = await Wifi.ip;

    List<String> addressList = [];
    for (var i = 0; i < 20; i++) {
      addressList.add(address.substring(0, address.lastIndexOf(".")) + '.'+
          (255 - i).toString());
    }
    for (String _address in addressList) {
      try {
        http.post(
          '$_address/$apiURL',
          body: json.encode(params),
        );
      } catch (e) {}
    }
  }
}
