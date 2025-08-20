// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripReview _$TripReviewFromJson(Map<String, dynamic> json) => TripReview(
  id: (json['id'] as num).toInt(),
  tripId: (json['tripId'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  user: User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TripReviewToJson(TripReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tripId': instance.tripId,
      'userId': instance.userId,
      'rating': instance.rating,
      'comment': instance.comment,
      'createdAt': instance.createdAt.toIso8601String(),
      'user': instance.user,
    };
