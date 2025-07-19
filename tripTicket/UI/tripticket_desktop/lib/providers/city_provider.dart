import 'dart:convert';

import 'package:tripticket_desktop/models/city_model.dart';
import 'package:tripticket_desktop/models/search_result.dart';
import 'package:tripticket_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class CityProvider extends BaseProvider<City> {
  CityProvider() : super("City");

  @override
  City fromJson(data) {
    return City.fromJson(data);
  }

  Future<SearchResult<City>> getCitiesByCountryId(
    int id, {
    dynamic filter,
    int? page,
    int? pageSize,
  }) async {
    var url = "${BaseProvider.baseUrl}City/country/$id/cities";

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

      var result = SearchResult<City>();

      result.count = data['count'];

      for (var item in data['resultList']) {
        result.result.add(fromJson(item));
      }

      return result;
    } else {
      throw Exception("Unknown error");
    }
  }
}
