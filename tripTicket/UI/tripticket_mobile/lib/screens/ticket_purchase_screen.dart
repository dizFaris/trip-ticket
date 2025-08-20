import 'dart:async';
import 'dart:convert';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:tripticket_mobile/app_colors.dart';
import 'package:tripticket_mobile/models/trip_model.dart';
import 'package:tripticket_mobile/providers/auth_provider.dart';
import 'package:tripticket_mobile/providers/purchase_provider.dart';
import 'package:tripticket_mobile/providers/transaction_provider.dart';
import 'package:tripticket_mobile/widgets/icon_button.dart';

class TicketPurchaseScreen extends StatefulWidget {
  final Trip trip;

  const TicketPurchaseScreen({super.key, required this.trip});

  @override
  State<TicketPurchaseScreen> createState() => _TicketPurchaseScreenState();
}

class _TicketPurchaseScreenState extends State<TicketPurchaseScreen> {
  final PurchaseProvider _purchaseProvider = PurchaseProvider();
  final TransactionProvider _transactionProvider = TransactionProvider();
  Timer? _debounce;
  int _ticketCount = 1;
  double _totalPayment = 0;
  ImageProvider? _tripImage;
  bool _isLoading = false;
  String? _purchaseStatusText;

  @override
  void initState() {
    super.initState();
    _totalPayment = widget.trip.ticketPrice;
    if (widget.trip.photo != null) {
      _tripImage = MemoryImage(base64Decode(widget.trip.photo!));
    } else {
      _tripImage = const AssetImage('assets/images/main_background.jpg');
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _increment() {
    setState(() {
      if (_ticketCount < widget.trip.availableTickets) {
        _ticketCount++;
      }
      _calculateTotalPrice();
    });
  }

  void _decrement() {
    setState(() {
      if (_ticketCount > 1) {
        _ticketCount--;
        _calculateTotalPrice();
      }
    });
  }

  Future<void> _createPurchase() async {
    setState(() {
      _isLoading = true;
    });
    final purchase = {
      "TripId": widget.trip.id,
      "UserId": AuthProvider.id,
      "NumberOfTickets": _ticketCount,
      "TotalPayment": _totalPayment,
      "PaymentMethod": "Stripe",
    };

    try {
      setState(() {
        _purchaseStatusText = 'Creating purchase...';
      });
      var purchaseResult = await _purchaseProvider.insert(purchase);

      setState(() {
        _purchaseStatusText = 'Waiting for payment...';
      });
      var paymentResult = await _transactionProvider.payWithPaymentSheet(
        purchaseResult.id,
      );

      setState(() {
        _purchaseStatusText = 'Processing transaction...';
      });

      var transaction = {
        'PurchaseId': purchaseResult.id,
        'Amount': purchaseResult.totalPayment,
        'PaymentMethod': 'Stripe',
        'Type': 'Payment',
        'Status': paymentResult.success ? 'complete' : 'failed',
        'TransactionDate': DateTime.now().toIso8601String(),
        'StripeTransactionId': paymentResult.stripeTransactionId,
      };

      await _transactionProvider.insert(transaction);

      setState(() {
        _purchaseStatusText = 'Finalizing purchase...';
      });
      await _purchaseProvider.finalizePurchase(
        purchaseResult.id,
        paymentResult.success,
      );

      if (!mounted) return;

      setState(() {
        _purchaseStatusText = paymentResult.success
            ? "Purchase successfully completed!"
            : "Payment failed";
      });

      await Future.delayed(Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pop(context);
    } on Exception catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Ok"),
            ),
          ],
        ),
      );
    }
    setState(() {
      _isLoading = false;
      _purchaseStatusText = null;
    });
  }

  void _calculateTotalPrice() {
    final pricePerTicket = widget.trip.ticketPrice;
    final minForDiscount = widget.trip.minTicketsForDiscount ?? 0;
    final discountPercent = widget.trip.discountPercentage ?? 0;

    double total;
    if (minForDiscount > 0 &&
        discountPercent > 0 &&
        _ticketCount >= minForDiscount) {
      final discountMultiplier = (100 - discountPercent) / 100;
      total = _ticketCount * pricePerTicket * discountMultiplier;
    } else {
      total = _ticketCount * pricePerTicket;
    }

    _totalPayment = double.parse(total.toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body:
          (_isLoading ||
              (_purchaseStatusText != null && _purchaseStatusText!.isNotEmpty))
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_purchaseStatusText != null &&
                      _purchaseStatusText!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        _purchaseStatusText!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryBlack,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  if (_isLoading)
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryGreen,
                        ),
                      ),
                    ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 350,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: _tripImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: 16,
                        child: SizedBox(
                          child: CircleIconButton(
                            icon: Icons.arrow_back,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Container(
                    height: 20,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black26, Colors.transparent],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.trip.city.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Row(
                              children: [
                                CountryFlag.fromCountryCode(
                                  widget.trip.city.country!.countryCode,
                                  height: 18,
                                  width: 24,
                                  shape: const Circle(),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  widget.trip.city.country!.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              "Price per ticket -",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black.withAlpha(128),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${widget.trip.ticketPrice} €",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryYellow,
                              ),
                            ),
                          ],
                        ),
                        if (widget.trip.discountPercentage != null)
                          Text(
                            "${widget.trip.discountPercentage}% discount if you buy ${widget.trip.minTicketsForDiscount} tickets",
                            style: TextStyle(fontSize: 20),
                          ),
                        Row(
                          children: [
                            Text(
                              'Departure date: ',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              widget.trip.departureDate
                                  .toIso8601String()
                                  .substring(0, 10),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        if (widget.trip.freeCancellationUntil != null)
                          Row(
                            children: [
                              Text(
                                'Free cancellation until: ',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                widget.trip.freeCancellationUntil!
                                    .toIso8601String()
                                    .substring(0, 10),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        if (widget.trip.cancellationFee != null)
                          Row(
                            children: [
                              Text(
                                'Cancellation fee: ',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                "${widget.trip.cancellationFee}%",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        Row(
                          children: [
                            Text(
                              'Available tickets: ',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "${widget.trip.availableTickets}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Ticket count - ',
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.black,
                              ),
                            ),
                            _buildSquareButton(Icons.remove, _decrement),
                            Container(
                              width: 50,
                              height: 35,
                              alignment: Alignment.center,
                              color: Colors.white,
                              child: Text(
                                '$_ticketCount',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildSquareButton(Icons.add, _increment),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 26,
                            color: Colors.black.withAlpha(128),
                          ),
                        ),
                        Divider(),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$_totalPayment €",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryYellow,
                                  ),
                                ),
                                Text(
                                  '$_ticketCount tickets',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black.withAlpha(128),
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),

                            ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Confirm Purchase"),
                                    content: const Text(
                                      "Are you sure you want to proceed with this purchase?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(),
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop();
                                          _createPurchase();
                                        },
                                        child: const Text("Confirm"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.shopping_cart,
                                color: AppColors.primaryYellow,
                                size: 24,
                              ),
                              label: const Text(
                                "Proceed",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: AppColors.primaryYellow,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSquareButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 35,
        height: 35,
        color: AppColors.primaryGreen,
        child: Icon(icon, color: AppColors.primaryYellow, size: 24),
      ),
    );
  }
}
