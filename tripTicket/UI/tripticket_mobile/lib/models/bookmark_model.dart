import 'package:json_annotation/json_annotation.dart';

part 'bookmark_model.g.dart';

@JsonSerializable()
class Bookmark {
  final int id;
  final int userId;
  final int tripId;
  final DateTime? createdAt;

  Bookmark({
    required this.id,
    required this.userId,
    required this.tripId,
    this.createdAt,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) =>
      _$BookmarkFromJson(json);

  Map<String, dynamic> toJson() => _$BookmarkToJson(this);
}
