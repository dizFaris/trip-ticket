import 'package:json_annotation/json_annotation.dart';

part 'purchase_model.g.dart';

@JsonSerializable()
class Purchase {
  final int id;
  final int tripId;
  final TripShortDto trip;
  final int userId;
  final UserShortDto user;
  final int numberOfTickets;
  final double totalPayment;
  final double? discount;
  final DateTime createdAt;
  final String status;
  final String paymentMethod;
  final bool isPrinted;

  Purchase({
    required this.id,
    required this.tripId,
    required this.trip,
    required this.userId,
    required this.user,
    required this.numberOfTickets,
    required this.totalPayment,
    this.discount,
    required this.createdAt,
    required this.status,
    required this.paymentMethod,
    required this.isPrinted,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) =>
      _$PurchaseFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseToJson(this);
}

@JsonSerializable()
class TripShortDto {
  final String? photo;
  final String city;
  final String country;
  final DateTime expirationDate;
  final String countryCode;

  TripShortDto({
    this.photo,
    required this.city,
    required this.country,
    required this.expirationDate,
    required this.countryCode,
  });

  factory TripShortDto.fromJson(Map<String, dynamic> json) =>
      _$TripShortDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TripShortDtoToJson(this);
}

@JsonSerializable()
class UserShortDto {
  final String firstName;
  final String lastName;
  final String username;

  UserShortDto({
    required this.firstName,
    required this.lastName,
    required this.username,
  });

  factory UserShortDto.fromJson(Map<String, dynamic> json) =>
      _$UserShortDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserShortDtoToJson(this);
}
