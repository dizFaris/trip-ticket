import 'package:http/http.dart' as http;
import 'package:tripticket_desktop/providers/base_provider.dart';
import 'package:tripticket_desktop/models/purchase_model.dart';

class PurchaseProvider extends BaseProvider<Purchase> {
  PurchaseProvider() : super("Purchase");

  @override
  Purchase fromJson(data) {
    return Purchase.fromJson(data);
  }

  Future<void> cancelPurchase(int id) async {
    var url = "${BaseProvider.baseUrl}Purchase/$id/cancel";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.put(uri, headers: headers);

    if (!isValidResponse(response)) {
      throw UserFriendlyException("Failed to cancel purchase");
    }
  }
}
