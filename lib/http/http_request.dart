import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:luvpark_get/http/api_keys.dart';

class HttpRequest {
  final String api;
  final Map<String, dynamic>? parameters;

  const HttpRequest({required this.api, this.parameters});

  static Future<http.Response> fetchDataWithTimeout(link) async {
    const timeoutDuration = Duration(seconds: 10);

    return await link.timeout(timeoutDuration, onTimeout: () {
      throw TimeoutException(
          'Connection timed out after ${timeoutDuration.inSeconds} seconds');
    });
  }

  Future<dynamic> get() async {
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
}
