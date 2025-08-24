import 'dart:convert';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:tripticket_mobile/app_colors.dart';
import 'package:tripticket_mobile/models/trip_model.dart';
import 'package:tripticket_mobile/providers/trip_provider.dart';
import 'package:tripticket_mobile/screens/trip_details_screen.dart';
import 'package:tripticket_mobile/utils/utils.dart';
import 'package:tripticket_mobile/widgets/date_picker.dart';
import 'package:tripticket_mobile/widgets/pagination_controls.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final TripProvider _tripProvider = TripProvider();
  final TextEditingController _ftsController = TextEditingController();
  final ScrollController _pageScrollController = ScrollController();
  List<Trip> _tripRecommendations = [];
  List<Trip> _trips = [];
  bool _isLoading = true;
  bool _isLoadingRecommendations = true;
  bool _isPaging = false;
  int _currentPage = 0;
  int _totalPages = 0;
  final List<String> _statuses = ["upcoming", "locked", "canceled", "complete"];
  String? _selectedStatus;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _fromDate = null;
    _toDate = null;
    _getTrips();
    _getTripRecommendations();
  }

  @override
  void dispose() {
    _ftsController.dispose();
    super.dispose();
  }

  void _goToPreviousPage() {
    if (_isPaging || _currentPage <= 0) return;
    _isPaging = true;

    _pageScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      _isPaging = false;
      setState(() {
        _currentPage--;
        _getTrips();
      });
    });
  }

  void _goToNextPage() {
    if (_isPaging || _currentPage >= _totalPages - 1) return;
    _isPaging = true;

    _pageScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      _isPaging = false;
      setState(() {
        _currentPage++;
        _getTrips();
      });
    });
  }

  Future<void> _getTripRecommendations() async {
    setState(() {
      _isLoadingRecommendations = true;
    });

    try {
      var recommendations = await _tripProvider.getRecommendations();

      if (!mounted) return;
      setState(() {
        _tripRecommendations = recommendations;
        _isLoadingRecommendations = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _tripRecommendations = [];
        _isLoadingRecommendations = false;
      });
    }
  }

  Future<void> _getTrips() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      var filter = {
        'status': _selectedStatus ?? 'upcoming',
        if (_ftsController.text.isNotEmpty) 'FTS': _ftsController.text,
        if (_fromDate != null)
          'FromDate': _fromDate!.toIso8601String().substring(0, 10),
        if (_toDate != null)
          'ToDate': _toDate!.toIso8601String().substring(0, 10),
      };

      var searchResult = await _tripProvider.get(
        filter: filter,
        page: _currentPage,
        pageSize: 8,
      );

      if (!mounted) return;
      setState(() {
        _trips = searchResult.result;
        _totalPages = (searchResult.count / 8).ceil();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _trips = [];
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Ok"),
            ),
          ],
        ),
      );
    }
  }

  Widget _dropdown<T>({
    required BuildContext context,
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        final selected = await showModalBottomSheet<T>(
          context: context,
          backgroundColor: AppColors.primaryGreen,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Select $label',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ...items.map((item) {
                    final isSelected = item == value;
                    return ListTile(
                      tileColor: isSelected ? Colors.white24 : null,
                      title: Text(
                        capitalize(item.toString()),
                        style: TextStyle(
                          color: isSelected ? Colors.yellow : Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      onTap: () => Navigator.of(context).pop(item),
                    );
                  }),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );

        if (selected != null) {
          onChanged(selected);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: value != null ? AppColors.primaryGreen : AppColors.primaryGray,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value != null ? capitalize(value.toString()) : label,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: value != null ? AppColors.primaryYellow : Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'Trips Overview',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          controller: _pageScrollController,
          padding: const EdgeInsets.all(16),
          children: [
            if (_tripRecommendations.isNotEmpty) ...[
              const Text(
                'For you',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Divider(),
              SizedBox(
                height: 250,
                child: _isLoadingRecommendations
                    ? const Center(
                        child: SizedBox(
                          height: 32,
                          width: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _tripRecommendations.length,
                        itemBuilder: (context, index) {
                          final screenWidth = MediaQuery.of(context).size.width;
                          final double horizontalPadding = 16 * 2;
                          final double spacing = 12;
                          final double cardWidth =
                              (screenWidth - horizontalPadding - spacing) / 2;

                          final trip = _tripRecommendations[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              left: index == 0 ? 0 : spacing,
                            ),
                            child: SizedBox(
                              width: cardWidth,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TripDetailsScreen(tripId: trip.id),
                                    ),
                                  ).then((value) {
                                    _getTrips();
                                    _getTripRecommendations();
                                  });
                                },
                                child: _tripWidget(trip),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),
            ],
            const Text(
              'Upcoming trips',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Divider(),
            TextFormField(
              controller: _ftsController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 4),
                  child: const Icon(Icons.search, size: 24),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                filled: true,
                fillColor: AppColors.primaryGray,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: const TextStyle(fontSize: 16),
              onChanged: (value) {
                _getTrips();
              },
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 50,
                  height: 40,
                  child: _dropdown<String>(
                    context: context,
                    label: 'Status',
                    value: _selectedStatus,
                    items: _statuses,
                    onChanged: (val) {
                      setState(() {
                        _selectedStatus = val;
                      });
                      _getTrips();
                    },
                  ),
                ),
                DatePickerButton(
                  initialDate: _fromDate,
                  allowPastDates: true,
                  placeHolder: 'Date from',
                  firstDate: DateTime(2025),
                  lastDate: _toDate ?? DateTime(2100),
                  onDateSelected: (date) {
                    setState(() {
                      _fromDate = date;
                    });
                    _getTrips();
                  },
                ),
                DatePickerButton(
                  initialDate: _toDate,
                  allowPastDates: true,
                  placeHolder: 'Date to',
                  firstDate: _fromDate ?? DateTime(2025),
                  onDateSelected: (date) {
                    setState(() {
                      _toDate = date;
                    });
                    _getTrips();
                  },
                ),
                SizedBox(
                  height: 40,
                  width: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedStatus = null;
                        _fromDate = null;
                        _toDate = null;
                      });
                      _getTrips();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Icon(
                      Icons.close_sharp,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            _isLoading
                ? SizedBox(
                    height: 1000,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  )
                : _trips.isEmpty
                ? SizedBox(
                    height: 300,
                    child: Center(
                      child: Text(
                        'No trips found',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ),
                  )
                : GridView.builder(
                    itemCount: _trips.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.73,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemBuilder: (context, index) {
                      final trip = _trips[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TripDetailsScreen(tripId: trip.id),
                            ),
                          ).then((value) {
                            _getTrips();
                            _getTripRecommendations();
                          });
                        },
                        child: _tripWidget(trip),
                      );
                    },
                  ),
            SizedBox(height: 12),
            PaginationControls(
              currentPage: _currentPage,
              totalPages: _totalPages,
              onPrevious: _goToPreviousPage,
              onNext: _goToNextPage,
              backgroundColor: AppColors.primaryYellow,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tripWidget(Trip trip) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryGray.withAlpha(77),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    image: trip.photo != null
                        ? DecorationImage(
                            image: MemoryImage(base64Decode(trip.photo!)),
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
                  top: 36,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      formatDate(trip.departureDate),
                      style: const TextStyle(color: AppColors.primaryYellow),
                    ),
                  ),
                ),

                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor(trip.tripStatus),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      trip.tripStatus.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 2.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        trip.city.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      trip.availableTickets > 0
                          ? Row(
                              children: [
                                const Icon(
                                  Icons.confirmation_num,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${trip.availableTickets} left",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "SOLD OUT",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                    ],
                  ),
                  Row(
                    children: [
                      CountryFlag.fromCountryCode(
                        trip.city.country!.countryCode,
                        height: 12,
                        width: 18,
                        shape: const Circle(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trip.city.country!.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        'Price',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${trip.ticketPrice} €',
                        style: const TextStyle(
                          color: AppColors.primaryYellow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      if (trip.discountPercentage != null &&
                          trip.discountPercentage! > 0)
                        Icon(
                          Icons.local_offer,
                          color: AppColors.primaryYellow,
                          size: 22,
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
