import 'dart:async';
import 'dart:convert';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:tripticket_mobile/app_colors.dart';
import 'package:tripticket_mobile/models/trip_model.dart';
import 'package:tripticket_mobile/providers/auth_provider.dart';
import 'package:tripticket_mobile/providers/bookmarks_provider.dart';
import 'package:tripticket_mobile/providers/trip_provider.dart';
import 'package:tripticket_mobile/screens/ticket_purchase_screen.dart';
import 'package:tripticket_mobile/utils/utils.dart';

class TripDetailsScreen extends StatefulWidget {
  final int tripId;

  const TripDetailsScreen({super.key, required this.tripId});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final TripProvider _tripProvider = TripProvider();
  final BookmarkProvider _bookmarkProvider = BookmarkProvider();
  bool _isLoading = true;
  bool _isBookmarked = false;
  Trip? _trip;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _initialize() async {
    await _checkIfTripIsBookmarked(widget.tripId);
    await _getTripData(widget.tripId);
  }

  Future<void> _getTripData(int tripId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      var trip = await _tripProvider.getById(tripId);
      setState(() {
        _trip = trip;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading trip: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkIfTripIsBookmarked(int id) async {
    try {
      var isBookmarked = await _bookmarkProvider.isTripBookmarked(
        AuthProvider.id!,
        id,
      );

      setState(() {
        _isBookmarked = isBookmarked;
      });
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
  }

  Future<void> _handleBookmark() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_isBookmarked) {
        await _bookmarkProvider.deleteBookmark(AuthProvider.id!, _trip!.id);
        setState(() {
          _isBookmarked = false;
        });
      } else {
        await _bookmarkProvider.insert({
          "UserId": AuthProvider.id,
          "TripId": _trip!.id,
        });
        setState(() {
          _isBookmarked = true;
        });
      }
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
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 300), () {
      setState(() {
        _isLoading = false;
      });
    });
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
                        height: 350,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: _trip?.photo != null
                              ? DecorationImage(
                                  image: MemoryImage(
                                    base64Decode(_trip!.photo!),
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
                        bottom: 16,
                        right: 16,
                        child: _trip!.availableTickets > 0
                            ? ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TicketPurchaseScreen(trip: _trip!),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.shopping_cart,
                                  color: AppColors.primaryYellow,
                                ),
                                label: const Text(
                                  "Purchase tickets",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
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
                              )
                            : _trip!.tripStatus == "upcoming"
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "SOLD OUT",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                      ),

                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildIconButton(
                              icon: Icons.arrow_back,
                              onPressed: () => Navigator.pop(context),
                            ),
                            _buildIconButton(
                              icon: _isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: _isBookmarked
                                  ? Colors.green
                                  : Colors.white,
                              onPressed: _handleBookmark,
                            ),
                          ],
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
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _trip!.city.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Row(
                                  children: [
                                    CountryFlag.fromCountryCode(
                                      _trip!.city.country!.countryCode,
                                      height: 18,
                                      width: 24,
                                      shape: const Circle(),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _trip!.city.country!.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${_trip!.ticketPrice} €",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryYellow,
                                  ),
                                ),
                                if (_trip!.discountPercentage != null &&
                                    _trip!.discountPercentage! > 0)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.local_offer,
                                        color: AppColors.primaryYellow,
                                        size: 24,
                                      ),
                                      Text(
                                        "${_trip!.discountPercentage}% for ${_trip!.minTicketsForDiscount} tickets",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryYellow,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: getStatusColor(_trip!.tripStatus),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _trip!.tripStatus.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _trip!.tripType!,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withAlpha(128),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _trip?.description ?? 'No description provided.',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Divider(),
                        Row(
                          children: [
                            Text(
                              'Departure date:',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _trip!.departureDate.toIso8601String().substring(
                                0,
                                10,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Return date:',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _trip!.returnDate.toIso8601String().substring(
                                0,
                                10,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Transport type:',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _trip!.transportType!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Trip details:',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        buildTripDays(_trip!.tripDays),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildTripDays(List<TripDayRequest> tripDays) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tripDays.map((day) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Day ${day.dayNumber}: ${day.title}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...day.tripDayItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('-', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        item.time.split(':').sublist(0, 2).join(':'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryYellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.action,
                          style: const TextStyle(fontSize: 14),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
