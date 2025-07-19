import 'package:http/http.dart' as http;
import 'package:tripticket_desktop/providers/base_provider.dart';
import 'package:tripticket_desktop/models/trip_model.dart';

class TripProvider extends BaseProvider<Trip> {
  TripProvider() : super("Trip");

  @override
  Trip fromJson(data) {
    return Trip.fromJson(data);
  }

  Future<void> cancelTrip(int id) async {
    var url = "${BaseProvider.baseUrl}Trip/$id/cancel";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.put(uri, headers: headers);

    if (!isValidResponse(response)) {
      throw UserFriendlyException("Failed to cancel trip");
    }
  }
}
