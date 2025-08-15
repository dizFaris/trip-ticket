import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:tripticket_desktop/providers/base_provider.dart';
import 'package:tripticket_desktop/models/purchase_model.dart';
import 'package:tripticket_desktop/utils/utils.dart';

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

  Future<void> completePurchase(int id) async {
    var url = "${BaseProvider.baseUrl}Purchase/$id/complete";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.put(uri, headers: headers);

    if (!isValidResponse(response)) {
      throw UserFriendlyException("Failed to complete purchase");
    }
  }

  Future<(Uint8List, String)> getTicketsPdf(int id) async {
    var url = "${BaseProvider.baseUrl}Purchase/$id/ticket-pdf";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final filename = extractFileName(response.headers['content-disposition']);
      return (response.bodyBytes, filename);
    } else {
      throw Exception('Failed to download monthly PDF');
    }
  }
}
