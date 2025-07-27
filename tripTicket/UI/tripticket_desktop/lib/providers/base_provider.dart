import 'dart:convert';
import 'package:tripticket_desktop/models/search_result.dart';
import 'package:tripticket_desktop/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? _baseUrl;
  String _endpoint = "";

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://localhost:5255/",
    );
  }
  static String get baseUrl {
    if (_baseUrl == null) {
      throw Exception("Base URL is not set");
    }
    return _baseUrl!;
  }

  Future<SearchResult<T>> get({
    dynamic filter,
    int? page,
    int? pageSize,
  }) async {
    var url = "$_baseUrl$_endpoint";

    Map<String, dynamic> queryParams = {};

    if (filter != null) {
      queryParams.addAll(Map<String, dynamic>.from(filter));
    }

    if (page != null) {
      queryParams['page'] = page;
    }
    if (pageSize != null) {
      queryParams['pageSize'] = pageSize;
    }
    if (queryParams.isNotEmpty) {
      var queryString = getQueryString(queryParams);
      url = "$url?$queryString";
    }
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      var result = SearchResult<T>();

      result.count = data['count'];

      for (var item in data['resultList']) {
        result.result.add(fromJson(item));
      }

      return result;
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<T> getById(int id) async {
    var url = "$_baseUrl$_endpoint/$id";

    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<T> insert(dynamic request) async {
    var url = "$_baseUrl$_endpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future delete(int id) async {
    var url = "$_baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.delete(uri, headers: headers);
    if (isValidResponse(response)) {
      return;
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<T> update(int id, [dynamic request]) async {
    var url = "$_baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.put(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<T> patch(int id, dynamic request, {String? customPath}) async {
    var url = "$_baseUrl$_endpoint/$id";
    if (customPath != null) {
      url = "$_baseUrl$_endpoint/$id/$customPath";
    }

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var jsonRequest = jsonEncode(request);

    var response = await http.patch(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  T fromJson(data) {
    throw Exception("Method not implemented");
  }

  bool isValidResponse(Response response) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }

      final dynamic errorResponse = jsonDecode(response.body);
      String? errorMessage;

      if (errorResponse is Map<String, dynamic>) {
        if (errorResponse.containsKey('message')) {
          errorMessage = errorResponse['message'];
        } else if (errorResponse['errors'] is Map<String, dynamic> &&
            errorResponse['errors']['userError'] is List) {
          errorMessage = (errorResponse['errors']['userError'] as List).join(
            ', ',
          );
        }
      }

      if (response.statusCode == 400) {
        throw UserFriendlyException(errorMessage ?? "Bad request");
      } else if (response.statusCode == 401) {
        throw UserFriendlyException(errorMessage ?? "Unauthorized");
      } else if (response.statusCode == 403) {
        throw UserFriendlyException(errorMessage ?? "Access denied");
      } else if (response.statusCode == 404) {
        throw UserFriendlyException(errorMessage ?? "Not found");
      } else if (response.statusCode >= 500) {
        throw UserFriendlyException(errorMessage ?? "Internal server error");
      }

      throw UserFriendlyException(errorMessage ?? "Unexpected error occurred");
    } catch (e) {
      if (e is UserFriendlyException) {
        rethrow;
      }
      throw UserFriendlyException(
        "Failed to process response. Please check your connection and try again.",
      );
    }
  }

  Map<String, String> createHeaders() {
    String username = AuthProvider.username ?? "";
    String password = AuthProvider.password ?? "";

    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";

    return {
      "Content-Type": "application/json",
      "Authorization": basicAuth,
      "X-Client-Type": "desktop",
    };
  }

  String getQueryString(
    Map params, {
    String prefix = '&',
    bool inRecursion = false,
  }) {
    String query = '';
    params.forEach((key, value) {
      if (inRecursion) {
        if (key is int) {
          key = '[$key]';
        } else if (value is List || value is Map) {
          key = '.$key';
        } else {
          key = '.$key';
        }
      }
      if (value is String || value is int || value is double || value is bool) {
        var encoded = value;
        if (value is String) {
          encoded = Uri.encodeComponent(value);
        }
        query += '$prefix$key=$encoded';
      } else if (value is DateTime) {
        query += '$prefix$key=${value.toIso8601String()}';
      } else if (value is List || value is Map) {
        if (value is List) value = value.asMap();
        value.forEach((k, v) {
          query += getQueryString(
            {k: v},
            prefix: '$prefix$key',
            inRecursion: true,
          );
        });
      }
    });
    return query;
  }
}

class UserFriendlyException implements Exception {
  final String message;

  UserFriendlyException(this.message);

  @override
  String toString() => message;
}
