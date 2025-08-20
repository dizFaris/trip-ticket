import 'package:json_annotation/json_annotation.dart';
import 'package:tripticket_desktop/models/user_model.dart';

part 'support_ticket_model.g.dart';

@JsonSerializable()
class SupportTicket {
  final int id;
  final int userId;
  final User user;
  final String subject;
  final String message;
  final String status;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.user,
    required this.subject,
    required this.message,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) =>
      _$SupportTicketFromJson(json);

  Map<String, dynamic> toJson() => _$SupportTicketToJson(this);
}
