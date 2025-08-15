import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tripticket_mobile/providers/base_provider.dart';
import 'package:tripticket_mobile/models/purchase_model.dart';

class PurchaseProvider extends BaseProvider<Purchase> {
  PurchaseProvider() : super("Purchase");

  @override
  Purchase fromJson(data) {
    return Purchase.fromJson(data);
  }

  Future<double> cancelPurchase(int id) async {
    var url = "${BaseProvider.baseUrl}Purchase/$id/cancel";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.put(uri, headers: headers);

    if (!isValidResponse(response)) {
      throw UserFriendlyException("Failed to cancel purchase");
    }

    var data = jsonDecode(response.body);

    double refundAmount = (data['refundAmount'] as num).toDouble();

    return refundAmount;
  }

  Future<void> finalizePurchase(int id, bool paymentSucceeded) async {
    var url = "${BaseProvider.baseUrl}Purchase/$id/finalize";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var body = jsonEncode({"paymentSucceeded": paymentSucceeded});

    var response = await http.put(uri, headers: headers, body: body);

    if (!isValidResponse(response)) {
      throw UserFriendlyException("Failed to finalize purchase");
    }
  }
}
