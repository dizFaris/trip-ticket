import 'dart:convert';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:tripticket_desktop/app_colors.dart';
import 'package:tripticket_desktop/models/trip_model.dart';
import 'package:tripticket_desktop/providers/trip_provider.dart';
import 'package:tripticket_desktop/widgets/date_picker.dart';
import 'package:tripticket_desktop/utils/utils.dart';
import 'package:tripticket_desktop/widgets/trip_day_editor.dart';

class TripScreen extends StatefulWidget {
  final int? tripId;

  const TripScreen({super.key, this.tripId});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  final TripProvider _tripProvider = TripProvider();
  bool get _isEditing => widget.tripId != null;
  bool _isLoading = true;
  Map<String, String> countries = {};
  List<String> cities = [];
  final List<String> tripTypes = [
    "Romantic",
    "Adventure",
    "Cultural",
    "Relaxing",
    "Family",
    "Luxury",
    "Eco-tourism",
    "Road Trip",
    "Wellness",
    "Historical",
    "City Tour",
    "Safari",
    "Nature",
    "Beach",
    "Vacation",
  ];

  final Map<String, IconData> transportTypes = {
    'Bus': Icons.directions_bus,
    'Plane': Icons.flight,
    'Car': Icons.directions_car,
    'Train': Icons.train,
    'Boat': Icons.directions_boat,
    'Bike': Icons.directions_bike,
  };

  String? selectedCountry;
  String? selectedState;
  String? selectedCity;
  String? selectedCountryCode;
  DateTime? departureDate;
  DateTime? returnDate;
  String? tripType;
  double? ticketPrice;
  int? availableTickets = 0;
  int? purchasedTickets = 0;
  String? transportType;
  String? departureCity;
  List<Map<String, Object>>? tripDays;
  String? description;
  DateTime? freeCancellationUntil;
  double? cancellationFee = 0;
  double? discountPercentage;
  int? minTicketsForDiscount;

  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _availableTicketsController =
      TextEditingController();
  final TextEditingController _departureCityController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cancellationFeeController =
      TextEditingController();
  final TextEditingController _discountPercentageController =
      TextEditingController();
  final TextEditingController _minTicketsForDiscountController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCountries();
    if (_isEditing) {
      getTripData(widget.tripId!);
    } else {
      _isLoading = false;
    }
  }

  void getTripData(int tripId) async {
    setState(() {
      _isLoading = true;
    });

    var trip = await _tripProvider.getById(tripId);

    List<Map<String, Object>> convertModelTripDaysToState(
      List<TripDayRequest> modelTripDays,
    ) {
      return modelTripDays.map((day) {
        return {
          'dayNumber': day.dayNumber,
          'title': day.title,
          'items': day.tripDayItems.map((item) {
            return {
              'time': item.time,
              'action': item.action,
              'orderNumber': item.orderNumber,
            };
          }).toList(),
        };
      }).toList();
    }

    setState(() {
      selectedCountryCode = trip.countryCode;
      selectedCountry = trip.country;
      departureDate = trip.departureDate;
      returnDate = trip.returnDate;
      tripType = trip.tripType;

      ticketPrice = trip.ticketPrice;
      _priceController.text = ticketPrice.toString();

      availableTickets = trip.availableTickets;
      _availableTicketsController.text = availableTickets.toString();

      purchasedTickets = trip.purchasedTickets;
      transportType = trip.transportType;

      departureCity = trip.departureCity;
      _departureCityController.text = trip.departureCity;

      tripDays = convertModelTripDaysToState(trip.tripDays);

      _descriptionController.text = trip.description!;

      cancellationFee = trip.cancellationFee;
      _cancellationFeeController.text = trip.cancellationFee.toString();

      freeCancellationUntil = trip.freeCancellationUntil;

      discountPercentage = trip.discountPercentage;
      _discountPercentageController.text = trip.discountPercentage != null
          ? trip.discountPercentage!.toInt().toString()
          : '';

      minTicketsForDiscount = trip.minTicketsForDiscount;
      _minTicketsForDiscountController.text = trip.minTicketsForDiscount != null
          ? trip.minTicketsForDiscount!.toInt().toString()
          : '';

      _getCountryCities();
      selectedCity = trip.city;
      _isLoading = false;
    });
  }

  Future<void> _getCountries() async {
    if (!_isEditing) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/countries.json',
      );
      final Map<String, dynamic> json = jsonDecode(jsonString);
      final List<dynamic> data = json['data'];

      final Map<String, String> countryMap = {
        for (var item in data)
          item['iso2'] as String: item['country'] as String,
      };

      setState(() {
        countries = countryMap;
        if (!_isEditing) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCountryCities() async {
    setState(() {
      cities = [];
    });
    final String jsonString = await rootBundle.loadString(
      'assets/countries.json',
    );
    final Map<String, dynamic> json = jsonDecode(jsonString);
    final List<dynamic> data = json['data'];

    final country = data.firstWhere(
      (item) => item['iso2'] == selectedCountryCode,
      orElse: () => null,
    );

    if (country != null && country['cities'] is List) {
      setState(() {
        cities = List<String>.from(country['cities']);
      });
      return;
    }

    setState(() {
      cities = [];
    });
  }

  @override
  void dispose() {
    super.dispose();
    _priceController.dispose();
    _availableTicketsController.dispose();
    _departureCityController.dispose();
    _descriptionController.dispose();
    _cancellationFeeController.dispose();
  }

  Widget countryDropdown({
    required Map<String, String> countries,
    required String? selectedCountryCode,
    required void Function(String?) onChanged,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    );

    return SizedBox(
      width: 256,
      child: DropdownButtonFormField<String>(
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
          hintText: 'Select a country',
          hintStyle: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        value: selectedCountryCode,
        items: countries.entries.map((entry) {
          final code = entry.key;
          final name = entry.value;
          return DropdownMenuItem<String>(
            value: code,
            child: Row(
              children: [
                CountryFlag.fromCountryCode(
                  code,
                  height: 15,
                  width: 20,
                  shape: const Circle(),
                ),

                const SizedBox(width: 8),
                SizedBox(
                  width: 180,
                  child: Text(
                    name,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
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

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    bool? enabled,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    );

    return SizedBox(
      width: 256,
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          filled: true,
          fillColor: (enabled ?? true)
              ? AppColors.primaryGray
              : Colors.blueGrey[300],
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
                child: SizedBox(
                  width: 200,
                  child: Text(
                    capitalize(item.toString()),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: (enabled ?? true) ? onChanged : null,
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

  Widget _transportTypeDropdown({
    required String label,
    required String? value,
    required Map<String, IconData> items,
    required ValueChanged<String?> onChanged,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    );

    return SizedBox(
      width: 161,
      child: DropdownButtonFormField<String>(
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
        items: items.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: SizedBox(
              width: 67,
              child: Row(
                children: [
                  Icon(entry.value, size: 20, color: Colors.black),
                  const SizedBox(width: 8),
                  Text(entry.key, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        }).toList(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGreen,
                ),
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditing ? "Edit trip" : "Add new trip",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    "Country",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                countryDropdown(
                                  countries: countries,
                                  selectedCountryCode: selectedCountryCode,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCity = null;
                                      selectedCountry = value;
                                      selectedCountryCode = value;
                                      _getCountryCities();
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    "City",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                _dropdown<String>(
                                  label: 'Select a city',
                                  value: selectedCity,
                                  items: cities,
                                  enabled: selectedCountryCode != null,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedCity = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    "Departure date",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                DatePickerButton(
                                  initialDate: departureDate,
                                  onDateSelected: (date) {
                                    setState(() {
                                      departureDate = date;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    "Return date",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                DatePickerButton(
                                  initialDate: returnDate,
                                  onDateSelected: (date) {
                                    setState(() {
                                      returnDate = date;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    "Trip type",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                _dropdown<String>(
                                  label: 'Select type',
                                  value: tripType,
                                  items: tripTypes,
                                  onChanged: (val) {
                                    setState(() {
                                      tripType = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    "Ticket price",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                SizedBox(
                                  width: 140,
                                  height: 32,
                                  child: TextField(
                                    controller: _priceController,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(8),
                                    ],
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: InputDecoration(
                                      labelText: null,
                                      prefixIcon: Icon(Icons.euro_symbol),
                                      hintText: '0.00',
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
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    "Available tickets",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                SizedBox(
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 50,
                                        height: 32,
                                        child: TextField(
                                          controller:
                                              _availableTicketsController,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(3),
                                          ],
                                          decoration: InputDecoration(
                                            labelText: null,
                                            hintText: '0',
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 6,
                                                ),
                                            filled: true,
                                            fillColor: AppColors.primaryGray,
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "$purchasedTickets already purchased",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    "Departure city",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                SizedBox(
                                  width: 256,
                                  child: TextField(
                                    controller: _departureCityController,
                                    keyboardType: TextInputType.text,
                                    inputFormatters: <TextInputFormatter>[
                                      LengthLimitingTextInputFormatter(25),
                                    ],
                                    decoration: InputDecoration(
                                      labelText: null,
                                      hintText: 'Enter text',
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
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    "Transport type",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                _transportTypeDropdown(
                                  label: 'Select Transport',
                                  value: transportType,
                                  items: transportTypes,
                                  onChanged: (val) {
                                    setState(() {
                                      transportType = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    "Schedule",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                TripDayEditor(
                                  initialDays: tripDays,
                                  onChanged: (updatedTripDays) {
                                    tripDays = updatedTripDays;
                                    print(tripDays);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    "Short description",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                SizedBox(
                                  width: 400,
                                  height: 150,
                                  child: TextField(
                                    controller: _descriptionController,
                                    maxLines: null,
                                    expands: true,
                                    textAlignVertical: TextAlignVertical.top,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(200),
                                    ],
                                    decoration: InputDecoration(
                                      hintText: 'Describe your trip...',
                                      filled: true,
                                      fillColor: AppColors.primaryGray,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: EdgeInsets.all(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    "Cancellation",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Row(
                                  children: [
                                    Text(
                                      "Free until",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    DatePickerButton(
                                      initialDate: freeCancellationUntil,
                                      onDateSelected: (date) {
                                        setState(() {
                                          freeCancellationUntil = date;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 140, child: Text("")),
                                SizedBox(width: 8),
                                Row(
                                  children: [
                                    Text(
                                      "Fee",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    SizedBox(
                                      width: 80,
                                      height: 32,
                                      child: TextField(
                                        controller: _cancellationFeeController,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(2),
                                        ],
                                        decoration: InputDecoration(
                                          labelText: null,
                                          prefixIcon: Icon(Icons.percent),
                                          hintText: '0',
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 6,
                                          ),
                                          filled: true,
                                          fillColor: AppColors.primaryGray,
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    "Discount",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 80,
                                      height: 32,
                                      child: TextField(
                                        controller:
                                            _discountPercentageController,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(2),
                                        ],
                                        decoration: InputDecoration(
                                          labelText: null,
                                          prefixIcon: Icon(Icons.percent),
                                          hintText: '0',
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 6,
                                          ),
                                          filled: true,
                                          fillColor: AppColors.primaryGray,
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "for",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    SizedBox(
                                      width: 80,
                                      height: 32,
                                      child: TextField(
                                        controller:
                                            _minTicketsForDiscountController,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(2),
                                        ],
                                        decoration: InputDecoration(
                                          labelText: null,
                                          prefixIcon: Icon(
                                            Icons.confirmation_num,
                                            size: 16,
                                            color: Colors.black,
                                          ),
                                          hintText: '0',
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 6,
                                          ),
                                          filled: true,
                                          fillColor: AppColors.primaryGray,
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _saveTrip() {
    if (_isEditing) {
      print("Updating trip ${widget.tripId}");
    } else {
      print("Creating new trip");
    }

    Navigator.pop(context);
  }
}
