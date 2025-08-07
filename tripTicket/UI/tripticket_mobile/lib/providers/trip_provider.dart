import 'package:tripticket_mobile/providers/base_provider.dart';
import 'package:tripticket_mobile/models/trip_model.dart';

class TripProvider extends BaseProvider<Trip> {
  TripProvider() : super("Trip");

  @override
  Trip fromJson(data) {
    return Trip.fromJson(data);
  }
}
