import 'package:json_annotation/json_annotation.dart';

part 'trip_model.g.dart';

@JsonSerializable()
class Trip {
  final int id;
  final String city;
  final String country;
  final String departureCity;
  final DateTime departureDate;
  final DateTime returnDate;
  final DateTime ticketSaleEnd;
  final String? tripType;
  final String? transportType;
  final double ticketPrice;
  final int availableTickets;
  final int purchasedTickets;
  final String? description;
  final DateTime? freeCancellationUntil;
  final double? cancellationFee;
  final int? minTicketsForDiscount;
  final double? discountPercentage;
  final List<int>? photo;
  final String tripStatus;
  final bool isCanceled;
  final DateTime createdAt;
  final List<TripDayRequest> tripDays;

  Trip({
    required this.id,
    required this.city,
    required this.country,
    required this.departureCity,
    required this.departureDate,
    required this.returnDate,
    required this.ticketSaleEnd,
    this.tripType,
    this.transportType,
    required this.ticketPrice,
    required this.availableTickets,
    required this.purchasedTickets,
    this.description,
    this.freeCancellationUntil,
    this.cancellationFee,
    this.minTicketsForDiscount,
    this.discountPercentage,
    this.photo,
    required this.tripStatus,
    required this.isCanceled,
    required this.createdAt,
    required this.tripDays,
  });

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);

  Map<String, dynamic> toJson() => _$TripToJson(this);
}

@JsonSerializable()
class TripDayRequest {
  final int dayNumber;
  final String title;
  final List<TripDayItemRequest> tripDayItems;

  TripDayRequest({
    required this.dayNumber,
    required this.title,
    required this.tripDayItems,
  });

  factory TripDayRequest.fromJson(Map<String, dynamic> json) =>
      _$TripDayRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TripDayRequestToJson(this);
}

@JsonSerializable()
class TripDayItemRequest {
  final String time;
  final String action;
  final int orderNumber;

  TripDayItemRequest({
    required this.time,
    required this.action,
    required this.orderNumber,
  });

  factory TripDayItemRequest.fromJson(Map<String, dynamic> json) =>
      _$TripDayItemRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TripDayItemRequestToJson(this);
}
