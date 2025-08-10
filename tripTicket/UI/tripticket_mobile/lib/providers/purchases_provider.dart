import 'package:tripticket_mobile/providers/base_provider.dart';
import 'package:tripticket_mobile/models/purchase_model.dart';

class PurchaseProvider extends BaseProvider<Purchase> {
  PurchaseProvider() : super("Purchase");

  @override
  Purchase fromJson(data) {
    return Purchase.fromJson(data);
  }
}
