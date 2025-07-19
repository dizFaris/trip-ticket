import 'package:tripticket_desktop/models/country_model.dart';
import 'package:tripticket_desktop/providers/base_provider.dart';

class CountryProvider extends BaseProvider<Country> {
  CountryProvider() : super("Country");

  @override
  Country fromJson(data) {
    return Country.fromJson(data);
  }
}
