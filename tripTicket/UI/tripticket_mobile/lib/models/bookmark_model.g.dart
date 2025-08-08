// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bookmark _$BookmarkFromJson(Map<String, dynamic> json) => Bookmark(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  tripId: (json['tripId'] as num).toInt(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$BookmarkToJson(Bookmark instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'tripId': instance.tripId,
  'createdAt': instance.createdAt?.toIso8601String(),
};
