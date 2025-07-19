import 'package:json_annotation/json_annotation.dart';
import 'package:tripticket_desktop/models/country_model.dart';

part 'city_model.g.dart';

@JsonSerializable()
class City {
  final int id;
  final String name;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final int? countryId;

  final Country? country;

  City({required this.id, required this.name, this.countryId, this.country});

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);

  Map<String, dynamic> toJson() => _$CityToJson(this);
}
