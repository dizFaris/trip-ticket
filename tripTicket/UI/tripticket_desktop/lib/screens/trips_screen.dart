import 'dart:convert';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:tripticket_desktop/app_colors.dart';
import 'package:tripticket_desktop/models/trip_model.dart';
import 'package:tripticket_desktop/providers/trip_provider.dart';
import 'package:tripticket_desktop/screens/master_screen.dart';
import 'package:tripticket_desktop/screens/trip_screen.dart';
import 'dart:async';

import 'package:tripticket_desktop/utils/utils.dart';
import 'package:tripticket_desktop/widgets/pagination_controls.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final TripProvider _tripProvider = TripProvider();
  List<Trip> _trips = [];
  bool _isLoading = true;
  int? _selectedYear;
  int? _selectedMonth;
  int? _selectedDay;
  String? _selectedStatus;
  final TextEditingController _ftsController = TextEditingController();
  Timer? _debounce;
  int _currentPage = 0;
  int _totalPages = 0;

  final List<int> _years = List.generate(30, (index) => 2000 + index);
  final List<int> _months = List.generate(12, (index) => index + 1);
  List<int> _days = [];
  final List<String> _statuses = ["upcoming", "locked", "canceled", "complete"];

  @override
  void initState() {
    super.initState();

    _currentPage = 0;
    _selectedYear = null;
    _selectedMonth = null;
    _updateDays();
    _selectedDay = null;
    _selectedStatus = null;

    _getTrips();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ftsController.dispose();
    super.dispose();
  }

  void _updateDays() {
    if (_selectedYear != null && _selectedMonth != null) {
      final int daysInMonth = DateTime(
        _selectedYear!,
        _selectedMonth! + 1,
        0,
      ).day;
      setState(() {
        _days = List.generate(daysInMonth, (index) => index + 1);

        // Adjust _days number to _days in month
        if (_selectedDay != null && _selectedDay! > daysInMonth) {
          _selectedDay = daysInMonth;
        }
      });
    }
  }

  _clearFilters() {
    setState(() {
      _selectedYear = null;
      _selectedMonth = null;
      _updateDays();
      _selectedDay = null;
      _selectedStatus = null;
      _ftsController.clear();
      _currentPage = 0;
      _getTrips();
    });
  }

  void _goToPreviousPage() {
    if (_isLoading) return;
    setState(() {
      _currentPage--;
      _getTrips();
    });
  }

  void _goToNextPage() {
    if (_isLoading) return;
    setState(() {
      _currentPage++;
      _getTrips();
    });
  }

  Future<void> _getTrips() async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() {
        _isLoading = true;
      });

      try {
        var filter = {
          if (_selectedStatus != null) 'Status': _selectedStatus,
          if (_selectedYear != null) 'Year': _selectedYear.toString(),
          if (_selectedMonth != null) 'Month': _selectedMonth.toString(),
          if (_selectedDay != null) 'Day': _selectedDay.toString(),
          if (_ftsController.text.isNotEmpty) 'FTS': _ftsController.text,
        };

        var searchResult = await _tripProvider.get(
          filter: filter,
          page: _currentPage,
          pageSize: 8,
        );

        setState(() {
          _trips = searchResult.result;
          _isLoading = false;
          _totalPages = (searchResult.count / 8).ceil();
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _trips = [];
        });

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
    });
  }

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    );

    return SizedBox(
      width: 125,
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          filled: true,
          fillColor: AppColors.primaryGray,
          border: border,
          enabledBorder: border,
          focusedBorder: border,
          hintText: label,
          hintStyle: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        value: value,
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  capitalize(item.toString()),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        dropdownColor: Colors.white,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          size: 24,
          color: Colors.black,
        ),
        iconSize: 24,
      ),
    );
  }

  Widget _tripWidget(Trip trip) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: trip.photo != null
                ? DecorationImage(
                    image: MemoryImage(base64Decode(trip.photo!)),
                    fit: BoxFit.cover,
                  )
                : const DecorationImage(
                    image: AssetImage('assets/images/main_background.jpg'),
                    fit: BoxFit.cover,
                  ),
          ),
        ),

        Positioned(
          top: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          top: 34,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.city.name,
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Row(
                        children: [
                          CountryFlag.fromCountryCode(
                            trip.city.country!.countryCode,
                            height: 15,
                            width: 20,
                            shape: const Circle(),
                          ),
                          SizedBox(width: 8),
                          Text(
                            trip.city.country!.name,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),

                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Price: ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "${trip.ticketPrice.toStringAsFixed(2)} EUR",
                              style: TextStyle(
                                color: Colors.yellow,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),

                Padding(
                  padding: EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      trip.availableTickets > 0
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.confirmation_num),
                                SizedBox(width: 4),
                                Text(
                                  "${trip.availableTickets} left",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : trip.tripStatus == "upcoming"
                          ? Container(
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
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                      Spacer(),
                      SizedBox(
                        width: 110,
                        child: ElevatedButton(
                          onPressed: () => {
                            masterScreenKey.currentState?.navigateTo(
                              TripScreen(tripId: trip.id),
                            ),
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryYellow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            trip.tripStatus == "complete"
                                ? "View trip"
                                : "Edit trip",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trip schedule',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            Row(
              children: [
                _dropdown<int>(
                  label: 'Year',
                  value: _selectedYear,
                  items: _years,
                  onChanged: (val) {
                    setState(() {
                      _selectedYear = val;
                      _updateDays();
                    });
                    _getTrips();
                  },
                ),
                SizedBox(width: 8),
                _dropdown<int>(
                  label: 'Month',
                  value: _selectedMonth,
                  items: _months,
                  onChanged: (val) {
                    setState(() {
                      _selectedMonth = val;
                      _updateDays();
                    });
                    _getTrips();
                  },
                ),
                SizedBox(width: 8),
                _dropdown<int>(
                  label: 'Day',
                  value: _selectedDay,
                  items: _days,
                  onChanged: (val) {
                    setState(() {
                      _selectedDay = val;
                    });
                    _getTrips();
                  },
                ),
                SizedBox(width: 8),

                _dropdown<String>(
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

                SizedBox(width: 8),

                SizedBox(
                  width: 300,
                  height: 32,
                  child: TextFormField(
                    controller: _ftsController,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: null,
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search, size: 16),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      filled: true,
                      fillColor: AppColors.primaryGray,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      _getTrips();
                    },
                  ),
                ),

                SizedBox(width: 8),

                SizedBox(
                  height: 32,
                  width: 32,
                  child: ElevatedButton(
                    onPressed: _getTrips,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Icon(Icons.refresh, color: Colors.black, size: 20),
                  ),
                ),

                SizedBox(width: 8),

                SizedBox(
                  height: 32,
                  width: 100,
                  child: ElevatedButton(
                    onPressed: _clearFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("CLEAR", style: TextStyle(color: Colors.black)),
                  ),
                ),

                Spacer(),

                SizedBox(
                  height: 38,
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      masterScreenKey.currentState?.navigateTo(TripScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      "ADD NEW",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 4),

            _isLoading
                ? Expanded(
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
                : Expanded(
                    child: _trips.isEmpty
                        ? const Center(
                            child: Text(
                              'No results found',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  mainAxisSpacing: 20,
                                  crossAxisSpacing: 20,
                                  childAspectRatio: 1.2,
                                ),
                            itemCount: _trips.length,
                            itemBuilder: (context, index) {
                              final trip = _trips[index];
                              return _tripWidget(trip);
                            },
                          ),
                  ),

            SizedBox(height: 8),

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
}
