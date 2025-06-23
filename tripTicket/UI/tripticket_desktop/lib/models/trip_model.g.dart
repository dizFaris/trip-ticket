// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trip _$TripFromJson(Map<String, dynamic> json) => Trip(
  id: (json['id'] as num).toInt(),
  city: json['city'] as String,
  country: json['country'] as String,
  countryCode: json['countryCode'] as String,
  departureCity: json['departureCity'] as String,
  departureDate: DateTime.parse(json['departureDate'] as String),
  returnDate: DateTime.parse(json['returnDate'] as String),
  ticketSaleEnd: DateTime.parse(json['ticketSaleEnd'] as String),
  tripType: json['tripType'] as String?,
  transportType: json['transportType'] as String?,
  ticketPrice: (json['ticketPrice'] as num).toDouble(),
  availableTickets: (json['availableTickets'] as num).toInt(),
  purchasedTickets: (json['purchasedTickets'] as num).toInt(),
  description: json['description'] as String?,
  freeCancellationUntil: json['freeCancellationUntil'] == null
      ? null
      : DateTime.parse(json['freeCancellationUntil'] as String),
  cancellationFee: (json['cancellationFee'] as num?)?.toDouble(),
  minTicketsForDiscount: (json['minTicketsForDiscount'] as num?)?.toInt(),
  discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
  photo: (json['photo'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  tripStatus: json['tripStatus'] as String,
  isCanceled: json['isCanceled'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  tripDays: (json['tripDays'] as List<dynamic>)
      .map((e) => TripDayRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TripToJson(Trip instance) => <String, dynamic>{
  'id': instance.id,
  'city': instance.city,
  'country': instance.country,
  'countryCode': instance.countryCode,
  'departureCity': instance.departureCity,
  'departureDate': instance.departureDate.toIso8601String(),
  'returnDate': instance.returnDate.toIso8601String(),
  'ticketSaleEnd': instance.ticketSaleEnd.toIso8601String(),
  'tripType': instance.tripType,
  'transportType': instance.transportType,
  'ticketPrice': instance.ticketPrice,
  'availableTickets': instance.availableTickets,
  'purchasedTickets': instance.purchasedTickets,
  'description': instance.description,
  'freeCancellationUntil': instance.freeCancellationUntil?.toIso8601String(),
  'cancellationFee': instance.cancellationFee,
  'minTicketsForDiscount': instance.minTicketsForDiscount,
  'discountPercentage': instance.discountPercentage,
  'photo': instance.photo,
  'tripStatus': instance.tripStatus,
  'isCanceled': instance.isCanceled,
  'createdAt': instance.createdAt.toIso8601String(),
  'tripDays': instance.tripDays,
};

TripDayRequest _$TripDayRequestFromJson(Map<String, dynamic> json) =>
    TripDayRequest(
      dayNumber: (json['dayNumber'] as num).toInt(),
      title: json['title'] as String,
      tripDayItems: (json['tripDayItems'] as List<dynamic>)
          .map((e) => TripDayItemRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TripDayRequestToJson(TripDayRequest instance) =>
    <String, dynamic>{
      'dayNumber': instance.dayNumber,
      'title': instance.title,
      'tripDayItems': instance.tripDayItems,
    };

TripDayItemRequest _$TripDayItemRequestFromJson(Map<String, dynamic> json) =>
    TripDayItemRequest(
      time: json['time'] as String,
      action: json['action'] as String,
      orderNumber: (json['orderNumber'] as num).toInt(),
    );

Map<String, dynamic> _$TripDayItemRequestToJson(TripDayItemRequest instance) =>
    <String, dynamic>{
      'time': instance.time,
      'action': instance.action,
      'orderNumber': instance.orderNumber,
    };
