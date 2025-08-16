import 'package:tripticket_desktop/providers/base_provider.dart';
import 'package:tripticket_desktop/models/transaction_model.dart';

class TransactionProvider extends BaseProvider<Transaction> {
  TransactionProvider() : super("Transaction");

  @override
  Transaction fromJson(data) {
    return Transaction.fromJson(data);
  }
}
