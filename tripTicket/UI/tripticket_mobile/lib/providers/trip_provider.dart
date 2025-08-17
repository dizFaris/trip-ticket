import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tripticket_mobile/providers/auth_provider.dart';
import 'package:tripticket_mobile/providers/base_provider.dart';
import 'package:tripticket_mobile/models/trip_model.dart';

class TripProvider extends BaseProvider<Trip> {
  TripProvider() : super("Trip");

  @override
  Trip fromJson(data) {
    return Trip.fromJson(data);
  }

  Future<List<Trip>> getRecommendations() async {
    var url = "${BaseProvider.baseUrl}Trip/recommendations/${AuthProvider.id}";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body) as List;
      return data.map((item) => fromJson(item)).toList();
    } else {
      throw Exception("Failed to load recommendations");
    }
  }
}
