// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_reply_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportReply _$SupportReplyFromJson(Map<String, dynamic> json) => SupportReply(
  id: (json['id'] as num).toInt(),
  ticketId: (json['ticketId'] as num).toInt(),
  message: json['message'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  ticket: json['ticket'] == null
      ? null
      : SupportTicket.fromJson(json['ticket'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SupportReplyToJson(SupportReply instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ticketId': instance.ticketId,
      'message': instance.message,
      'createdAt': instance.createdAt.toIso8601String(),
      'ticket': instance.ticket,
    };
