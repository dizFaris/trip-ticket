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
import 'package:tripticket_mobile/widgets/icon_button.dart';

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
                              "Purchase details",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                        'Purchase ID:',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${widget.purchase.id}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                        'Status:',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: getStatusColor(
                                          widget.purchase.status,
                                        ),
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
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                        'Created at:',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      widget.purchase.createdAt
                                          .toIso8601String()
                                          .substring(0, 10),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                        'Destination:',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          "${widget.purchase.trip.city} / ",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            CountryFlag.fromCountryCode(
                                              widget.purchase.trip.countryCode,
                                              height: 16,
                                              width: 20,
                                              shape: const Circle(),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              widget.purchase.trip.country,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                        'Expires at:',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      widget.purchase.trip.expirationDate
                                          .toIso8601String()
                                          .substring(0, 10),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                if (widget
                                        .purchase
                                        .trip
                                        .freeCancellationUntil !=
                                    null)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 180,
                                        child: Text(
                                          'Free cancel until:',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        widget
                                            .purchase
                                            .trip
                                            .freeCancellationUntil!
                                            .toIso8601String()
                                            .substring(0, 10),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                    ],
                                  ),
                                if (widget.purchase.trip.cancellationFee !=
                                    null)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 180,
                                        child: Text(
                                          'Cancellation fee:',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "${widget.purchase.trip.cancellationFee} %",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                    ],
                                  ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                        'Tickets purchased:',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "${widget.purchase.numberOfTickets}",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        Divider(),

                        Row(
                          children: [
                            Text(
                              "TOTAL: ",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "${widget.purchase.totalPayment} €",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: BarcodeWidget(
                            barcode: Barcode.qrCode(),
                            data: "${widget.purchase.id}",
                            width: 100,
                            height: 100,
                            drawText: false,
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (widget.purchase.status == "accepted")
                              SizedBox(
                                width: 160,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    backgroundColor: AppColors.primaryRed,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text("Cancel Purchase"),
                                        content: const Text(
                                          "Are you sure you want to cancel this purchase?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(),
                                            child: const Text("No"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(ctx).pop();
                                              _cancelPurchase();
                                            },
                                            child: const Text("Yes"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Cancel purchase",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(
                              width: 160,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
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
}
