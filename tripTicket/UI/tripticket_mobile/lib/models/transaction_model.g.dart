// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
  id: json['id'] as String,
  purchaseId: (json['purchaseId'] as num).toInt(),
  amount: (json['amount'] as num).toDouble(),
  status: json['status'] as String,
  paymentMethod: json['paymentMethod'] as String,
  transactionDate: DateTime.parse(json['transactionDate'] as String),
  stripeTransactionId: json['stripeTransactionId'] as String,
);

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'purchaseId': instance.purchaseId,
      'amount': instance.amount,
      'status': instance.status,
      'paymentMethod': instance.paymentMethod,
      'transactionDate': instance.transactionDate.toIso8601String(),
      'stripeTransactionId': instance.stripeTransactionId,
    };
