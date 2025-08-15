import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:country_flags/country_flags.dart';
import 'package:tripticket_mobile/app_colors.dart';
import 'package:tripticket_mobile/models/purchase_model.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:tripticket_mobile/providers/purchase_provider.dart';
import 'package:tripticket_mobile/screens/trip_details_screen.dart';
import 'package:tripticket_mobile/utils/utils.dart';

class PurchaseDetailsScreen extends StatefulWidget {
  final Purchase purchase;
  const PurchaseDetailsScreen({super.key, required this.purchase});

  @override
  State<PurchaseDetailsScreen> createState() => _PurchaseDetailsScreenState();
}

class _PurchaseDetailsScreenState extends State<PurchaseDetailsScreen> {
  final PurchaseProvider _purchaseProvider = PurchaseProvider();
  Timer? _debounce;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  _cancelPurchase() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var refundAmount = await _purchaseProvider.cancelPurchase(
        widget.purchase.id,
      );

      var message = refundAmount > 0
          ? "Refunded amount ${refundAmount.toStringAsFixed(2)} €"
          : "No money was refunded";

      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: Text("Success"),
          content: Text("Purchase successfully canceled. $message"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
                Navigator.pop(context, true);
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

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(
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
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 300,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: widget.purchase.trip.photo != null
                              ? DecorationImage(
                                  image: MemoryImage(
                                    base64Decode(widget.purchase.trip.photo!),
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : const DecorationImage(
                                  image: AssetImage(
                                    'assets/images/main_background.jpg',
                                  ),
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
                        Text(
                          "Purchase details",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Purchase ID: ${widget.purchase.id}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Status: ',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: getStatusColor(widget.purchase.status),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.purchase.status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Created at: ',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              widget.purchase.createdAt
                                  .toIso8601String()
                                  .substring(0, 10),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryYellow,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Text(
                              'Destination: ',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "${widget.purchase.trip.city} / ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            CountryFlag.fromCountryCode(
                              widget.purchase.trip.countryCode,
                              height: 16,
                              width: 20,
                              shape: const Circle(),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              widget.purchase.trip.country,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Text(
                              'Expires at: ',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              widget.purchase.trip.expirationDate
                                  .toIso8601String()
                                  .substring(0, 10),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryYellow,
                              ),
                            ),
                          ],
                        ),

                        if (widget.purchase.trip.freeCancellationUntil != null)
                          Row(
                            children: [
                              Text(
                                'Free cancellation untill: ',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                widget.purchase.trip.freeCancellationUntil!
                                    .toIso8601String()
                                    .substring(0, 10),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryYellow,
                                ),
                              ),
                            ],
                          ),

                        if (widget.purchase.trip.cancellationFee != null)
                          Row(
                            children: [
                              Text(
                                "Cancellation fee: ",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                "${widget.purchase.trip.cancellationFee} %",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryYellow,
                                ),
                              ),
                            ],
                          ),

                        Row(
                          children: [
                            Text(
                              "Tickets purchased: ",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "${widget.purchase.numberOfTickets}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryYellow,
                              ),
                            ),
                          ],
                        ),

                        Divider(),

                        Row(
                          children: [
                            Text(
                              "TOTAL: ",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "${widget.purchase.totalPayment} €",
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryYellow,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: BarcodeWidget(
                            barcode: Barcode.code128(),
                            data: "${widget.purchase.id}",
                            width: 200,
                            height: 80,
                            drawText: false,
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (widget.purchase.status == "accepted")
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 30,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: AppColors.primaryRed,
                                ),
                                onPressed: () {
                                  _cancelPurchase();
                                },
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: AppColors.primaryGreen,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TripDetailsScreen(
                                      tripId: widget.purchase.trip.id,
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                "Trip details",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryYellow,
                                ),
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
}
