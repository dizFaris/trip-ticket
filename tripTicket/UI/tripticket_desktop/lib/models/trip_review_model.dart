import 'package:json_annotation/json_annotation.dart';
import 'package:tripticket_desktop/models/user_model.dart';

part 'trip_review_model.g.dart';

@JsonSerializable()
class TripReview {
  final int id;
  final int tripId;
  final int userId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final User user;

  TripReview({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.user,
  });

  factory TripReview.fromJson(Map<String, dynamic> json) =>
      _$TripReviewFromJson(json);

  Map<String, dynamic> toJson() => _$TripReviewToJson(this);
}
