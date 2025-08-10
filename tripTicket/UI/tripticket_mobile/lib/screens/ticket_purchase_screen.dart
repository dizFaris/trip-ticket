import 'dart:async';
import 'dart:convert';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:tripticket_mobile/app_colors.dart';
import 'package:tripticket_mobile/models/trip_model.dart';
import 'package:tripticket_mobile/providers/auth_provider.dart';
import 'package:tripticket_mobile/providers/purchases_provider.dart';

class TicketPurchaseScreen extends StatefulWidget {
  final Trip trip;

  const TicketPurchaseScreen({super.key, required this.trip});

  @override
  State<TicketPurchaseScreen> createState() => _TicketPurchaseScreenState();
}

class _TicketPurchaseScreenState extends State<TicketPurchaseScreen> {
  final PurchaseProvider _purchaseProvider = PurchaseProvider();
  Timer? _debounce;
  int _ticketCount = 1;
  double _totalPayment = 0;
  ImageProvider? _tripImage;
  bool _isLoading = false;

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
      await _purchaseProvider.insert(purchase);
      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: Text("Success"),
          content: Text("Purchase successfully added"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("Ok"),
            ),
          ],
        ),
      );
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
      body: _isLoading
          ? const Expanded(
              child: Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryGreen,
                    ),
                  ),
                ),
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
                          child: _buildIconButton(
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
                              onPressed: _createPurchase,
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

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(216),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color ?? Colors.black),
        onPressed: onPressed,
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
