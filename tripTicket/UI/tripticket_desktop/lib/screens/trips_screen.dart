import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tripticket_desktop/app_colors.dart';
import 'package:tripticket_desktop/models/trip_model.dart';
import 'package:tripticket_desktop/providers/trip_provider.dart';
import 'package:tripticket_desktop/screens/master_screen.dart';
import 'package:tripticket_desktop/screens/trip_screen.dart';
import 'dart:async';

import 'package:tripticket_desktop/utils/utils.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

String _formatDate(DateTime? date) {
  if (date == null) return '';
  return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}

class _TripsScreenState extends State<TripsScreen> {
  final TripProvider _tripProvider = TripProvider();
  List<Trip> _trips = [];
  bool _isLoading = true;
  int? selectedYear;
  int? selectedMonth;
  int? selectedDay;
  String? selectedStatus;
  final TextEditingController _ftsController = TextEditingController();
  Timer? _debounce;
  int _currentPage = 0;
  int _totalPages = 0;

  final List<int> years = List.generate(30, (index) => 2000 + index);
  final List<int> months = List.generate(12, (index) => index + 1);
  List<int> days = [];
  List<String> statuses = ["upcoming", "locked", "canceled", "complete"];

  @override
  void initState() {
    super.initState();

    _currentPage = 0;
    selectedYear = null;
    selectedMonth = null;
    _updateDays();
    selectedDay = null;
    selectedStatus = null;

    _getTrips();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ftsController.dispose();
    super.dispose();
  }

  void _updateDays() {
    if (selectedYear != null && selectedMonth != null) {
      final int daysInMonth = DateTime(
        selectedYear!,
        selectedMonth! + 1,
        0,
      ).day;
      setState(() {
        days = List.generate(daysInMonth, (index) => index + 1);

        // Adjust days number to days in month
        if (selectedDay != null && selectedDay! > daysInMonth) {
          selectedDay = daysInMonth;
        }
      });
    }
  }

  _clearFilters() {
    setState(() {
      selectedYear = null;
      selectedMonth = null;
      _updateDays();
      selectedDay = null;
      selectedStatus = null;
      _ftsController.clear();
      _currentPage = 0;
      _getTrips();
    });
  }

  void _goToPreviousPage() {
    setState(() {
      _currentPage--;
      _getTrips();
    });
  }

  void _goToNextPage() {
    setState(() {
      _currentPage++;
      _getTrips();
    });
  }

  Future<void> _getTrips() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var filter = {
        if (selectedStatus != null) 'status': selectedStatus,
        if (selectedYear != null) 'year': selectedYear.toString(),
        if (selectedMonth != null) 'month': selectedMonth.toString(),
        if (selectedDay != null) 'day': selectedDay.toString(),
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
      });
    }
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
                    image: MemoryImage(Uint8List.fromList(trip.photo!)),
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
              _formatDate(trip.departureDate),
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
                        trip.city,
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Row(
                        children: [
                          CountryFlag.fromCountryCode(
                            trip.countryCode,
                            height: 15,
                            width: 20,
                            shape: const Circle(),
                          ),
                          SizedBox(width: 8),
                          Text(
                            trip.country,
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
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.confirmation_num),
                          SizedBox(width: 4),
                          Text(
                            "${trip.availableTickets} left",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
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
                            "Edit trip",
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
                  value: selectedYear,
                  items: years,
                  onChanged: (val) {
                    setState(() {
                      selectedYear = val;
                      _updateDays();
                    });
                    _getTrips();
                  },
                ),
                SizedBox(width: 8),
                _dropdown<int>(
                  label: 'Month',
                  value: selectedMonth,
                  items: months,
                  onChanged: (val) {
                    setState(() {
                      selectedMonth = val;
                      _updateDays();
                    });
                    _getTrips();
                  },
                ),
                SizedBox(width: 8),
                _dropdown<int>(
                  label: 'Day',
                  value: selectedDay,
                  items: days,
                  onChanged: (val) {
                    setState(() {
                      selectedDay = val;
                    });
                    _getTrips();
                  },
                ),
                SizedBox(width: 8),

                _dropdown<String>(
                  label: 'Status',
                  value: selectedStatus,
                  items: statuses,
                  onChanged: (val) {
                    setState(() {
                      selectedStatus = val;
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
                      _debounce?.cancel();
                      _debounce = Timer(Duration(milliseconds: 300), () {
                        _getTrips();
                      });
                    },
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

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 38,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: _currentPage > 0 ? _goToPreviousPage : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: AppColors.primaryYellow,
                      disabledForegroundColor: Colors.grey[600],
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                      shadowColor: Colors.black26,
                    ),
                    child: const Icon(Icons.chevron_left),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Page ${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 16),
                SizedBox(
                  width: 38,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: _currentPage < _totalPages - 1
                        ? _goToNextPage
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: AppColors.primaryYellow,
                      disabledForegroundColor: Colors.grey[600],
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                      shadowColor: Colors.black26,
                    ),
                    child: const Icon(Icons.chevron_right),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
