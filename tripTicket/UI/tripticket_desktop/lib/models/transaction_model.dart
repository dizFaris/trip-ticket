import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class Transaction {
  final String id;
  final int purchaseId;
  final double amount;
  final String status;
  final String paymentMethod;
  final String type;
  final DateTime transactionDate;
  final String stripeTransactionId;

  Transaction({
    required this.id,
    required this.purchaseId,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    required this.type,
    required this.transactionDate,
    required this.stripeTransactionId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}
