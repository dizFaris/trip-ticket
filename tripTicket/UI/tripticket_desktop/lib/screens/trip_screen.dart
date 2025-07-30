import 'dart:convert';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:tripticket_desktop/app_colors.dart';
import 'package:tripticket_desktop/models/city_model.dart';
import 'package:tripticket_desktop/models/country_model.dart';
import 'package:tripticket_desktop/models/trip_model.dart';
import 'package:tripticket_desktop/providers/city_provider.dart';
import 'package:tripticket_desktop/providers/country_provider.dart';
import 'package:tripticket_desktop/providers/trip_provider.dart';
import 'package:tripticket_desktop/screens/master_screen.dart';
import 'package:tripticket_desktop/screens/trips_screen.dart';
import 'package:tripticket_desktop/widgets/date_picker.dart';
import 'package:tripticket_desktop/utils/utils.dart';
import 'package:tripticket_desktop/widgets/photo_picker.dart';
import 'package:tripticket_desktop/widgets/trip_day_editor.dart';

class TripScreen extends StatefulWidget {
  final int? tripId;

  const TripScreen({super.key, this.tripId});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  final TripProvider _tripProvider = TripProvider();
  final CountryProvider _countryProvider = CountryProvider();
  final CityProvider _cityProvider = CityProvider();

  bool get _isEditing => widget.tripId != null;
  bool _isLoading = true;
  List<Country> countries = [];
  List<City> cities = [];
  List<City> departureCities = [];

  int? selectedCityId;
  int? departureCityId;
  int? selectedCountryId;
  int? departureCountryId;
  DateTime? departureDate;
  DateTime? returnDate;
  String? tripType;
  double? ticketPrice;
  int? availableTickets = 0;
  int? purchasedTickets = 0;
  String? transportType;
  List<Map<String, Object>>? tripDays = [];
  String? description;
  DateTime? freeCancellationUntil;
  double? cancellationFee = 0;
  double? discountPercentage;
  int? minTicketsForDiscount;
  List<int>? selectedPhoto;
  String? tripStatus;

  bool get inputEnabled =>
      !_isEditing || (_isEditing && tripStatus == 'upcoming');

  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _availableTicketsController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cancellationFeeController =
      TextEditingController();
  final TextEditingController _discountPercentageController =
      TextEditingController();
  final TextEditingController _minTicketsForDiscountController =
      TextEditingController();

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
          'tripDayItems': day.tripDayItems.map((item) {
            return {
              'time': item.time,
              'action': item.action,
              'orderNumber': item.orderNumber,
            };
          }).toList(),
        };
      }).toList();
    }

    var tripCountryCities = await _getCountryCities(trip.city.country!.id);
    var departureCountryCities = await _getCountryCities(
      trip.departureCity.country!.id,
    );

    setState(() {
      selectedCityId = trip.city.id;
      cities = tripCountryCities;

      departureCityId = trip.departureCity.id;
      departureCities = departureCountryCities;

      selectedCountryId = trip.city.country!.id;
      departureCountryId = trip.departureCity.country!.id;

      departureDate = trip.departureDate;
      returnDate = trip.returnDate;
      tripType = trip.tripType;

      ticketPrice = trip.ticketPrice;
      _priceController.text = ticketPrice.toString();

      availableTickets = trip.availableTickets;
      _availableTicketsController.text = availableTickets.toString();

      purchasedTickets = trip.purchasedTickets;
      transportType = trip.transportType;

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

      selectedPhoto = (trip.photo != null && trip.photo!.isNotEmpty)
          ? base64Decode(trip.photo!)
          : null;
      tripStatus = trip.tripStatus;

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
      var searchResult = await _countryProvider.get();

      setState(() {
        countries = searchResult.result;
        if (!_isEditing) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        countries = [];
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
  }

  Future<List<City>> _getCountryCities(int countryId) async {
    try {
      var searchResult = await _cityProvider.getCitiesByCountryId(countryId);

      if (!_isEditing) {
        setState(() {
          _isLoading = false;
        });
      }

      return searchResult.result;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      return [];
    }
  }

  @override
  void dispose() {
    super.dispose();
    _priceController.dispose();
    _availableTicketsController.dispose();
    _descriptionController.dispose();
    _cancellationFeeController.dispose();
  }

  Widget countryDropdown({
    required List<Country> countries,
    required void Function(int?) onChanged,
    required int? value,
    bool? enabled,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    );

    return SizedBox(
      width: 256,
      child: DropdownButtonFormField<int>(
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
          hintText: 'Select a country',
          hintStyle: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        value: value,
        items: countries.map((country) {
          return DropdownMenuItem<int>(
            value: country.id,
            child: Row(
              children: [
                CountryFlag.fromCountryCode(
                  country.countryCode,
                  height: 15,
                  width: 20,
                  shape: const Circle(),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 180,
                  child: Text(
                    country.name,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
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

  Widget cityDropdown({
    required List<City> cities,
    required void Function(int?) onChanged,
    required int? value,
    bool? enabled,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    );
    return SizedBox(
      width: 256,
      child: DropdownButtonFormField<int>(
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
          hintText: 'Select a city',
          hintStyle: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        value: value,
        items: cities.map((city) {
          return DropdownMenuItem<int>(
            value: city.id,
            child: SizedBox(
              width: 180,
              child: Text(
                city.name,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          );
        }).toList(),
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
    bool? enabled,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () =>
                    masterScreenKey.currentState?.navigateTo(TripsScreen()),
              ),
            ),
            SizedBox(width: 12),
            Text(
              _isEditing ? "Edit trip" : "Add new trip",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 170,
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
                                  enabled: inputEnabled,
                                  value: selectedCountryId,
                                  onChanged: (value) async {
                                    var countryCities = await _getCountryCities(
                                      value!,
                                    );
                                    setState(() {
                                      selectedCityId = null;
                                      selectedCountryId = value;
                                      cities = countryCities;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                SizedBox(
                                  width: 170,
                                  child: Text(
                                    "City",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                cityDropdown(
                                  cities: cities,
                                  enabled: inputEnabled,
                                  value: selectedCityId,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCityId = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                SizedBox(
                                  width: 170,
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
                                  enabled: inputEnabled,
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
                                  width: 170,
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
                                  enabled: inputEnabled,
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
                                  width: 170,
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
                                  enabled: inputEnabled,
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
                                  width: 170,
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
                                  width: 170,
                                  height: 32,
                                  child: TextField(
                                    controller: _priceController,
                                    enabled: inputEnabled,
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
                                      fillColor: inputEnabled
                                          ? AppColors.primaryGray
                                          : Colors.blueGrey[300],
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
                                  width: 170,
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
                                          enabled: inputEnabled,
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
                                            fillColor: inputEnabled
                                                ? AppColors.primaryGray
                                                : Colors.blueGrey[300],
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
                                  width: 170,
                                  child: Text(
                                    "Departure Country",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                countryDropdown(
                                  countries: countries,
                                  enabled: inputEnabled,
                                  value: departureCountryId,
                                  onChanged: (value) async {
                                    var departureCountryCities =
                                        await _getCountryCities(value!);
                                    setState(() {
                                      departureCityId = null;
                                      departureCountryId = value;
                                      departureCities = departureCountryCities;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                SizedBox(
                                  width: 170,
                                  child: Text(
                                    "Departure City",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                cityDropdown(
                                  cities: departureCities,
                                  enabled: inputEnabled,
                                  value: departureCityId,
                                  onChanged: (value) {
                                    setState(() {
                                      departureCityId = value;
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
                                  width: 170,
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
                                  enabled: inputEnabled,
                                  onChanged: (updatedTripDays) {
                                    tripDays = updatedTripDays;
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
                                  width: 170,
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
                                    enabled: inputEnabled,
                                    maxLines: null,
                                    expands: true,
                                    textAlignVertical: TextAlignVertical.top,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(200),
                                    ],
                                    decoration: InputDecoration(
                                      hintText: 'Describe your trip...',
                                      filled: true,
                                      fillColor: inputEnabled
                                          ? AppColors.primaryGray
                                          : Colors.blueGrey[300],
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
                                  width: 170,
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
                                  enabled: inputEnabled,
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
                              children: [
                                SizedBox(
                                  width: 170,
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
                                      enabled: inputEnabled,
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
                                SizedBox(width: 170, child: Text("")),
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
                                      width: 100,
                                      height: 32,
                                      child: TextField(
                                        controller: _cancellationFeeController,
                                        enabled: inputEnabled,
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
                                          fillColor: inputEnabled
                                              ? AppColors.primaryGray
                                              : Colors.blueGrey[300],
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
                                  width: 170,
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
                                        enabled: inputEnabled,
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
                                          fillColor: inputEnabled
                                              ? AppColors.primaryGray
                                              : Colors.blueGrey[300],
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
                                        enabled: inputEnabled,
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
                                          fillColor: inputEnabled
                                              ? AppColors.primaryGray
                                              : Colors.blueGrey[300],
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
                            SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 170,
                                  child: Text(
                                    "Photo",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                TripPhotoPicker(
                                  initialPhoto: selectedPhoto,
                                  enabled: inputEnabled,
                                  onPhotoSelected: (bytes) {
                                    selectedPhoto = bytes;
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        tripStatus == "upcoming"
                            ? SizedBox(
                                height: 32,
                                width: 120,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirm Cancel'),
                                        content: const Text(
                                          'Are you sure you want to cancel this trip?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(
                                              context,
                                            ).pop(false),
                                            child: const Text('No'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text('Yes'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmed == true) {
                                      _cancelTrip();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryRed,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  child: const Text(
                                    "CANCEL TRIP",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),

                        SizedBox(width: 8),
                        SizedBox(
                          height: 32,
                          width: 120,
                          child: ElevatedButton(
                            onPressed: () {
                              masterScreenKey.currentState?.navigateTo(
                                TripsScreen(),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryYellow,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: Text(
                              "RETURN",
                              style: TextStyle(color: AppColors.primaryBlack),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        _isEditing
                            ? tripStatus == "upcoming"
                                  ? SizedBox(
                                      height: 32,
                                      width: 120,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _saveTrip();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryGreen,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          "SAVE",
                                          style: TextStyle(
                                            color: AppColors.primaryYellow,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink()
                            : SizedBox(
                                height: 32,
                                width: 120,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _addNewTrip();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryGreen,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  child: Text(
                                    "ADD",
                                    style: TextStyle(
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
            ),
    );
  }

  Future<void> _addNewTrip() async {
    final tripData = {
      "CityId": selectedCityId,
      "DepartureCityId": departureCityId,
      "DepartureDate": departureDate?.toIso8601String().substring(0, 10),
      "ReturnDate": returnDate?.toIso8601String().substring(0, 10),
      "TripType": tripType,
      "TransportType": transportType,
      "TicketPrice": double.tryParse(_priceController.text) ?? 0.0,
      "AvailableTickets": int.tryParse(_availableTicketsController.text) ?? 0,
      "Description": _descriptionController.text,
      "FreeCancellationUntil": freeCancellationUntil
          ?.toIso8601String()
          .substring(0, 10),
      "CancellationFee":
          double.tryParse(_cancellationFeeController.text) ?? 0.0,
      "MinTicketsForDiscount":
          int.tryParse(_minTicketsForDiscountController.text) ?? 0,
      "DiscountPercentage":
          double.tryParse(_discountPercentageController.text) ?? 0.0,
      "Photo": selectedPhoto != null ? base64Encode(selectedPhoto!) : null,
      "TripDays": tripDays,
    };

    final validationError = _validateTripData(tripData);
    if (validationError != null) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Validation Error"),
          content: Text(validationError),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Ok"),
            ),
          ],
        ),
      );
      return;
    }

    try {
      await _tripProvider.insert(tripData);
      if (!mounted) return;

      final result = await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: Text("Success"),
          content: Text("Trip successfully added"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text("Ok"),
            ),
          ],
        ),
      );

      if (result == true || result == null) {
        masterScreenKey.currentState?.navigateTo(TripsScreen());
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
  }

  Future<void> _saveTrip() async {
    final tripData = {
      "CityId": selectedCityId,
      "DepartureCityId": departureCityId,
      "DepartureDate": departureDate?.toIso8601String().substring(0, 10),
      "ReturnDate": returnDate?.toIso8601String().substring(0, 10),
      "TripType": tripType,
      "TransportType": transportType,
      "TicketPrice": double.tryParse(_priceController.text) ?? 0.0,
      "AvailableTickets": int.tryParse(_availableTicketsController.text) ?? 0,
      "Description": _descriptionController.text,
      "FreeCancellationUntil": freeCancellationUntil
          ?.toIso8601String()
          .substring(0, 10),
      "CancellationFee":
          double.tryParse(_cancellationFeeController.text) ?? 0.0,
      "MinTicketsForDiscount":
          int.tryParse(_minTicketsForDiscountController.text) ?? 0,
      "DiscountPercentage":
          double.tryParse(_discountPercentageController.text) ?? 0.0,
      "Photo": selectedPhoto != null ? base64Encode(selectedPhoto!) : null,
      "TripDays": tripDays,
    };

    final validationError = _validateTripData(tripData);
    if (validationError != null) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Validation Error"),
          content: Text(validationError),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Ok"),
            ),
          ],
        ),
      );
      return;
    }

    try {
      await _tripProvider.update(widget.tripId!, tripData);
      if (!mounted) return;

      final result = await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: Text("Success"),
          content: Text("Trip successfully updated"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text("Ok"),
            ),
          ],
        ),
      );

      if (result == true || result == null) {
        masterScreenKey.currentState?.navigateTo(TripsScreen());
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
  }

  String? _validateTripData(Map<String, dynamic> tripData) {
    final errors = <String>[];

    if (tripData["CityId"] == null) {
      errors.add("City must be selected.");
    }
    if (tripData["DepartureCityId"] == null) {
      errors.add("Departure city must be selected.");
    }
    if (tripData["DepartureDate"] == null ||
        tripData["DepartureDate"].isEmpty) {
      errors.add("Departure date is required.");
    }
    if (tripData["ReturnDate"] == null || tripData["ReturnDate"].isEmpty) {
      errors.add("Return date is required.");
    }
    if (tripData["TripType"] == null || tripData["TripType"].isEmpty) {
      errors.add("Trip type is required.");
    }
    if (tripData["TransportType"] == null ||
        tripData["TransportType"].isEmpty) {
      errors.add("Transport type is required.");
    }
    if (tripData["TicketPrice"] == null || tripData["TicketPrice"] <= 0) {
      errors.add("Ticket price must be greater than zero.");
    }
    if (tripData["AvailableTickets"] == null ||
        tripData["AvailableTickets"] < 0) {
      errors.add("Available tickets must be zero or more.");
    }

    DateTime? departureDate;
    DateTime? returnDate;
    DateTime? freeCancellationUntil;

    try {
      if (tripData["DepartureDate"] != null &&
          tripData["DepartureDate"].isNotEmpty) {
        departureDate = DateTime.parse(tripData["DepartureDate"]);
      }
    } catch (_) {
      errors.add("Departure date format is invalid.");
    }
    try {
      if (tripData["ReturnDate"] != null && tripData["ReturnDate"].isNotEmpty) {
        returnDate = DateTime.parse(tripData["ReturnDate"]);
      }
    } catch (_) {
      errors.add("Return date format is invalid.");
    }
    try {
      if (tripData["FreeCancellationUntil"] != null &&
          tripData["FreeCancellationUntil"].isNotEmpty) {
        freeCancellationUntil = DateTime.parse(
          tripData["FreeCancellationUntil"],
        );
      }
    } catch (_) {
      errors.add("Free cancellation date format is invalid.");
    }

    if (departureDate != null && returnDate != null) {
      if (departureDate.isAfter(returnDate)) {
        errors.add("Departure date must be before return date.");
      }
    }

    if (departureDate != null && freeCancellationUntil != null) {
      final diff = departureDate.difference(freeCancellationUntil).inDays;
      if (diff < 3) {
        errors.add(
          "Free cancellation must end at least 3 days before departure.",
        );
      }
    }

    final discount = tripData["DiscountPercentage"] ?? 0.0;
    if (discount < 0 || discount > 100) {
      errors.add("Discount percentage must be between 0 and 100.");
    }

    final cancellationFee = tripData["CancellationFee"] ?? 0.0;
    if (cancellationFee < 0) {
      errors.add("Cancellation fee cannot be negative.");
    }

    final minTickets = tripData["MinTicketsForDiscount"] ?? 0;
    if (minTickets < 0) {
      errors.add("Minimum tickets for discount cannot be negative.");
    }

    if (errors.isEmpty) {
      return null;
    } else {
      return errors.join('\n');
    }
  }

  _cancelTrip() async {
    try {
      await _tripProvider.cancelTrip(widget.tripId!);

      if (!mounted) return;
      final result = await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: Text("Success"),
          content: Text("Trip successfully canceled"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text("Ok"),
            ),
          ],
        ),
      );

      if (result == true || result == null) {
        masterScreenKey.currentState?.navigateTo(TripsScreen());
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
  }
}
