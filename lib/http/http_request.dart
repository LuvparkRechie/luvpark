import 'dart:async';
import 'dart:convert';

import 'package:dart_ping/dart_ping.dart';
import 'package:http/http.dart' as http;
import 'package:luvpark_get/http/api_keys.dart';

class HttpRequest {
  final String api;
  final Map<String, dynamic>? parameters;

  const HttpRequest({required this.api, this.parameters});

  static Future<bool> checkInternetConn() async {
    final ping = Ping('google.com', count: 5);
    bool isConnected = false;

    await for (var event in ping.stream) {
      if (event.response != null) {
        isConnected = true;
        break;
      }
    }
    return isConnected;
  }

  static Future<http.Response> fetchDataWithTimeout(
      Future<http.Response> link) async {
    const timeoutDuration = Duration(seconds: 10);

    return await link.timeout(timeoutDuration, onTimeout: () {
      throw TimeoutException(
          'Connection timed out after ${timeoutDuration.inSeconds} seconds');
    });
  }

  Future<dynamic> get() async {
    bool isNetconn = await checkInternetConn();
    if (!isNetconn) {
      return "No Internet";
    }

    var links = http.get(
        Uri.parse(Uri.decodeFull(Uri.https(ApiKeys.gApiURL, api).toString())),
        headers: {"Content-Type": 'application/json; charset=utf-8'});
    try {
      final response = await fetchDataWithTimeout(links);

      if (response.statusCode == 200) {
        return jsonDecode(
            utf8.decode(response.bodyBytes, allowMalformed: true));
      } else {
        return null;
      }
    } catch (e) {
      return "No Internet";
    }
  }

  Future<dynamic> post() async {
    bool isNetconn = await checkInternetConn();
    if (!isNetconn) {
      return "No Internet";
    }
    var links = http.post(
        Uri.parse(Uri.decodeFull(Uri.https(ApiKeys.gApiURL, api).toString())),
        headers: {"Content-Type": 'application/json; charset=utf-8'},
        body: json.encode(parameters));

    try {
      final response = await fetchDataWithTimeout(links);
      if (response.statusCode == 200) {
        return response.headers;
      } else {
        return null;
      }
    } catch (e) {
      return "No Internet";
    }
  }

  Future<dynamic> postBody() async {
    bool isNetconn = await checkInternetConn();
    if (!isNetconn) {
      return "No Internet";
    }
    var links = http.post(
        Uri.parse(Uri.decodeFull(Uri.https(ApiKeys.gApiURL, api).toString())),
        headers: {"Content-Type": 'application/json; charset=utf-8'},
        body: json.encode(parameters));

    try {
      final response = await fetchDataWithTimeout(links);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return "No Internet";
    }
  }

  Future<dynamic> put() async {
    bool isNetconn = await checkInternetConn();
    if (!isNetconn) {
      return "No Internet";
    }
    var links = http.put(
        Uri.parse(Uri.decodeFull(Uri.https(ApiKeys.gApiURL, api).toString())),
        headers: {"Content-Type": "application/json"},
        body: json.encode(parameters));

    try {
      final response = await fetchDataWithTimeout(links);

      if (response.statusCode == 200) {
        return response.headers;
      } else {
        return null;
      }
    } catch (e) {
      return "No Internet";
    }
  }

  Future<dynamic> deleteData() async {
    bool isNetconn = await checkInternetConn();
    if (!isNetconn) {
      return "No Internet";
    }
    var links = http.delete(
        Uri.parse(Uri.decodeFull(Uri.https(ApiKeys.gApiURL, api).toString())),
        headers: {"Content-Type": 'application/json; charset=utf-8'},
        body: json.encode(parameters));

    try {
      final response = await fetchDataWithTimeout(links);

      if (response.statusCode == 200) {
        return "Success";
      } else {
        return null;
      }
    } catch (e) {
      return "No Internet";
    }
  }

  Future<dynamic> linkToPage() async {
    bool isNetconn = await checkInternetConn();
    if (!isNetconn) {
      return "No Internet";
    }
    var links = http.get(Uri.https("luvpark.ph", "/terms-of-use"),
        headers: {"Content-Type": 'application/json; charset=utf-8'});
    try {
      final response = await fetchDataWithTimeout(links);
      if (response.statusCode == 200) {
        return "Success";
      } else {
        return null;
      }
    } catch (e) {
      return "No Internet";
    }
  }
}
