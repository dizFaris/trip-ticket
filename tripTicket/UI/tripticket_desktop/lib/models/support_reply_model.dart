import 'package:json_annotation/json_annotation.dart';
import 'package:tripticket_desktop/models/support_ticket_model.dart';

part 'support_reply_model.g.dart';

@JsonSerializable()
class SupportReply {
  final int id;
  final int ticketId;
  final String message;
  final DateTime createdAt;
  final SupportTicket? ticket;

  SupportReply({
    required this.id,
    required this.ticketId,
    required this.message,
    required this.createdAt,
    this.ticket,
  });

  factory SupportReply.fromJson(Map<String, dynamic> json) =>
      _$SupportReplyFromJson(json);

  Map<String, dynamic> toJson() => _$SupportReplyToJson(this);
}
