import 'package:tripticket_desktop/providers/base_provider.dart';
import 'package:tripticket_desktop/models/trip_model.dart';

class TripProvider extends BaseProvider<Trip> {
  TripProvider() : super("Trip");

  @override
  Trip fromJson(data) {
    return Trip.fromJson(data);
  }
}
