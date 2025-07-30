import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:tripticket_desktop/models/earnings_report_model.dart';
import 'package:tripticket_desktop/providers/auth_provider.dart';
import 'package:tripticket_desktop/utils/utils.dart';

class StatisticsProvider {
  static const String _baseUrl = String.fromEnvironment(
    "baseUrl",
    defaultValue: "http://localhost:5255/",
  );

  Map<String, String> _createHeaders() {
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

  Future<double> getDailyEarnings(DateTime date) async {
    final uri = Uri.parse(
      '${_baseUrl}statistics/earnings/daily?date=${date.toIso8601String()}',
    );

    final response = await http.get(uri, headers: _createHeaders());

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['total'] as num).toDouble();
    } else {
      throw Exception('Failed to load daily earnings');
    }
  }

  Future<EarningsReport> getMonthlyEarnings(int year, int month) async {
    final uri = Uri.parse(
      '${_baseUrl}statistics/earnings/monthly?year=$year&month=$month',
    );

    final response = await http.get(uri, headers: _createHeaders());

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return EarningsReport.fromJson(json);
    } else {
      throw Exception('Failed to load monthly earnings');
    }
  }

  Future<EarningsReport> getYearlyEarnings(int year) async {
    final uri = Uri.parse('${_baseUrl}statistics/earnings/yearly?year=$year');

    final response = await http.get(uri, headers: _createHeaders());

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return EarningsReport.fromJson(json);
    } else {
      throw Exception('Failed to load yearly earnings');
    }
  }

  Future<(Uint8List, String)> getDailyEarningsPdf(DateTime date) async {
    final uri = Uri.parse(
      '${_baseUrl}statistics/earnings/daily/pdf?date=${date.toIso8601String()}',
    );

    final response = await http.get(uri, headers: _createHeaders());

    if (response.statusCode == 200) {
      final filename = extractFileName(response.headers['content-disposition']);
      return (response.bodyBytes, filename);
    } else {
      throw Exception('Failed to download daily PDF');
    }
  }

  Future<(Uint8List, String)> getMonthlyEarningsPdf(int year, int month) async {
    final uri = Uri.parse(
      '${_baseUrl}statistics/earnings/monthly/pdf?year=$year&month=$month',
    );

    final response = await http.get(uri, headers: _createHeaders());

    if (response.statusCode == 200) {
      final filename = extractFileName(response.headers['content-disposition']);
      return (response.bodyBytes, filename);
    } else {
      throw Exception('Failed to download monthly PDF');
    }
  }

  Future<(Uint8List, String)> getYearlyEarningsPdf(int year) async {
    final uri = Uri.parse(
      '${_baseUrl}statistics/earnings/yearly/pdf?year=$year',
    );

    final response = await http.get(uri, headers: _createHeaders());

    if (response.statusCode == 200) {
      final filename = extractFileName(response.headers['content-disposition']);
      return (response.bodyBytes, filename);
    } else {
      throw Exception('Failed to download yearly PDF');
    }
  }
}
