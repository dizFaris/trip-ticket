import 'package:tripticket_mobile/providers/base_provider.dart';
import 'package:tripticket_mobile/models/transaction_model.dart';
import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class TransactionProvider extends BaseProvider<Transaction> {
  TransactionProvider() : super("Transaction");

  @override
  Transaction fromJson(data) {
    return Transaction.fromJson(data);
  }

  Future<PaymentResult> payWithPaymentSheet(int purchaseId) async {
    String? stripeTransactionId;
    try {
      var url = "${BaseProvider.baseUrl}Transaction/create-payment-intent";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      var body = jsonEncode({"PurchaseId": purchaseId});

      var response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode != 200) {
        return PaymentResult(
          success: false,
          errorMessage: 'Failed to create PaymentIntent',
        );
      }

      final data = jsonDecode(response.body);
      final clientSecret = data['clientSecret'];
      stripeTransactionId = data['stripeTransactionId'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'TripTicket',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      return PaymentResult(
        success: true,
        stripeTransactionId: stripeTransactionId,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        stripeTransactionId: stripeTransactionId,
        errorMessage: e.toString(),
      );
    }
  }
}

class PaymentResult {
  final bool success;
  final String? stripeTransactionId;
  final String? errorMessage;

  PaymentResult({
    required this.success,
    this.stripeTransactionId,
    this.errorMessage,
  });
}
