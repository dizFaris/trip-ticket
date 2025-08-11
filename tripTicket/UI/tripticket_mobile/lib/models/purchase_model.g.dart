// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Purchase _$PurchaseFromJson(Map<String, dynamic> json) => Purchase(
  id: (json['id'] as num).toInt(),
  tripId: (json['tripId'] as num).toInt(),
  trip: TripShortDto.fromJson(json['trip'] as Map<String, dynamic>),
  userId: (json['userId'] as num).toInt(),
  user: UserShortDto.fromJson(json['user'] as Map<String, dynamic>),
  numberOfTickets: (json['numberOfTickets'] as num).toInt(),
  totalPayment: (json['totalPayment'] as num).toDouble(),
  discount: (json['discount'] as num?)?.toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  status: json['status'] as String,
  paymentMethod: json['paymentMethod'] as String,
  isPrinted: json['isPrinted'] as bool,
);

Map<String, dynamic> _$PurchaseToJson(Purchase instance) => <String, dynamic>{
  'id': instance.id,
  'tripId': instance.tripId,
  'trip': instance.trip,
  'userId': instance.userId,
  'user': instance.user,
  'numberOfTickets': instance.numberOfTickets,
  'totalPayment': instance.totalPayment,
  'discount': instance.discount,
  'createdAt': instance.createdAt.toIso8601String(),
  'status': instance.status,
  'paymentMethod': instance.paymentMethod,
  'isPrinted': instance.isPrinted,
};

TripShortDto _$TripShortDtoFromJson(Map<String, dynamic> json) => TripShortDto(
  id: (json['id'] as num).toInt(),
  photo: json['photo'] as String?,
  city: json['city'] as String,
  country: json['country'] as String,
  expirationDate: DateTime.parse(json['expirationDate'] as String),
  countryCode: json['countryCode'] as String,
  freeCancellationUntil: json['freeCancellationUntil'] == null
      ? null
      : DateTime.parse(json['freeCancellationUntil'] as String),
  cancellationFee: (json['cancellationFee'] as num?)?.toDouble(),
);

Map<String, dynamic> _$TripShortDtoToJson(
  TripShortDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'photo': instance.photo,
  'city': instance.city,
  'country': instance.country,
  'expirationDate': instance.expirationDate.toIso8601String(),
  'countryCode': instance.countryCode,
  'freeCancellationUntil': instance.freeCancellationUntil?.toIso8601String(),
  'cancellationFee': instance.cancellationFee,
};

UserShortDto _$UserShortDtoFromJson(Map<String, dynamic> json) => UserShortDto(
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  username: json['username'] as String,
);

Map<String, dynamic> _$UserShortDtoToJson(UserShortDto instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'username': instance.username,
    };
