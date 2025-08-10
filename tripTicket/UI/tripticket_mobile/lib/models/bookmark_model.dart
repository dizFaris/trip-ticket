import 'package:json_annotation/json_annotation.dart';
import 'trip_model.dart';

part 'bookmark_model.g.dart';

@JsonSerializable()
class Bookmark {
  final int id;
  final int userId;
  final DateTime? createdAt;
  final Trip trip;

  Bookmark({
    required this.id,
    required this.userId,
    this.createdAt,
    required this.trip,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) =>
      _$BookmarkFromJson(json);
  Map<String, dynamic> toJson() => _$BookmarkToJson(this);
}
