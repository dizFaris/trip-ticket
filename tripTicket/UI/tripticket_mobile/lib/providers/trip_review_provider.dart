import 'package:tripticket_mobile/providers/base_provider.dart';
import 'package:tripticket_mobile/models/trip_review_model.dart';
import 'package:http/http.dart' as http;

class TripReviewProvider extends BaseProvider<TripReview> {
  TripReviewProvider() : super("TripReview");

  @override
  TripReview fromJson(data) {
    return TripReview.fromJson(data);
  }

  Future<double> getAverageRating(int tripId) async {
    var url = "${BaseProvider.baseUrl}TripReview/average/$tripId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (!isValidResponse(response)) {
      throw UserFriendlyException("Failed to fetch average rating");
    }

    final body = response.body;
    try {
      return double.parse(body);
    } catch (e) {
      throw UserFriendlyException("Invalid response for average rating");
    }
  }
}
