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
import 'package:tripticket_desktop/screens/trip_reviews_screen.dart';
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
  Trip? _trip;
  bool get _isEditing => widget.tripId != null;
  bool _isLoading = true;
  List<Country> _countries = [];
  List<City> _cities = [];
  List<City> _departureCities = [];

  int? _selectedCityId;
  int? _departureCityId;
  int? _selectedCountryId;
  int? _departureCountryId;
  DateTime? _departureDate;
  DateTime? _returnDate;
  String? _tripType;
  double? _ticketPrice;
  int? _availableTickets = 0;
  int? _purchasedTickets = 0;
  String? _transportType;
  List<Map<String, Object>>? _tripDays = [];
  DateTime? _freeCancellationUntil;
  List<int>? _selectedPhoto;
  String? _tripStatus;
  bool _isSaving = false;
  bool get _inputEnabled =>
      !_isEditing || (_isEditing && _tripStatus == 'upcoming');
  final _formKey = GlobalKey<FormState>();

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

  String? _ticketsError;
  String? _priceError;
  String? _departureDateError;
  String? _returnDateError;
  String? _cancellationDateError;
  String? _discountError;
  String? _cancellationFeeError;

  final List<String> _tripTypes = [
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

  final Map<String, IconData> _transportTypes = {
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
      _getTripData(widget.tripId!);
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _availableTicketsController.dispose();
    _descriptionController.dispose();
    _cancellationFeeController.dispose();
    _discountPercentageController.dispose();
    _minTicketsForDiscountController.dispose();
    super.dispose();
  }

  void _getTripData(int tripId) async {
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
      _trip = trip;

      _selectedCityId = trip.city.id;
      _cities = tripCountryCities;

      _departureCityId = trip.departureCity.id;
      _departureCities = departureCountryCities;

      _selectedCountryId = trip.city.country!.id;
      _departureCountryId = trip.departureCity.country!.id;

      _departureDate = trip.departureDate;
      _returnDate = trip.returnDate;
      _tripType = trip.tripType;

      _ticketPrice = trip.ticketPrice;
      _priceController.text = _ticketPrice.toString();

      _availableTickets = trip.availableTickets;
      _availableTicketsController.text = _availableTickets.toString();

      _purchasedTickets = trip.purchasedTickets;
      _transportType = trip.transportType;

      _tripDays = convertModelTripDaysToState(trip.tripDays);

      _descriptionController.text = trip.description!;

      _cancellationFeeController.text = trip.cancellationFee.toString();

      _freeCancellationUntil = trip.freeCancellationUntil;

      _discountPercentageController.text = trip.discountPercentage != null
          ? trip.discountPercentage!.toInt().toString()
          : '';

      _minTicketsForDiscountController.text = trip.minTicketsForDiscount != null
          ? trip.minTicketsForDiscount!.toInt().toString()
          : '';

      _selectedPhoto = (trip.photo != null && trip.photo!.isNotEmpty)
          ? base64Decode(trip.photo!)
          : null;
      _tripStatus = trip.tripStatus;

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
        _countries = searchResult.result;
        if (!_isEditing) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _countries = [];
      });

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

  Future<void> _addNewTrip() async {
    final tripData = {
      "CityId": _selectedCityId,
      "DepartureCityId": _departureCityId,
      "DepartureDate": _departureDate?.toIso8601String().substring(0, 10),
      "ReturnDate": _returnDate?.toIso8601String().substring(0, 10),
      "TripType": _tripType,
      "TransportType": _transportType,
      "TicketPrice": double.tryParse(_priceController.text) ?? 0.0,
      "AvailableTickets": int.tryParse(_availableTicketsController.text) ?? 0,
      "Description": _descriptionController.text,
      "FreeCancellationUntil": _freeCancellationUntil
          ?.toIso8601String()
          .substring(0, 10),
      "CancellationFee":
          double.tryParse(_cancellationFeeController.text) ?? 0.0,
      "MinTicketsForDiscount":
          int.tryParse(_minTicketsForDiscountController.text) ?? 0,
      "DiscountPercentage":
          double.tryParse(_discountPercentageController.text) ?? 0.0,
      "Photo": _selectedPhoto != null ? base64Encode(_selectedPhoto!) : null,
      "TripDays": _tripDays,
    };

    final validationError = _validateTripData(tripData);
    if (!validationError) {
      setState(() {
        _isSaving = false;
      });
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to add this trip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

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
      setState(() {
        _isSaving = false;
      });
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
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _saveTrip() async {
    final tripData = {
      "CityId": _selectedCityId,
      "DepartureCityId": _departureCityId,
      "DepartureDate": _departureDate?.toIso8601String().substring(0, 10),
      "ReturnDate": _returnDate?.toIso8601String().substring(0, 10),
      "TripType": _tripType,
      "TransportType": _transportType,
      "TicketPrice": double.tryParse(_priceController.text) ?? 0.0,
      "AvailableTickets": int.tryParse(_availableTicketsController.text) ?? 0,
      "Description": _descriptionController.text,
      "FreeCancellationUntil": _freeCancellationUntil
          ?.toIso8601String()
          .substring(0, 10),
      "CancellationFee":
          double.tryParse(_cancellationFeeController.text) ?? 0.0,
      "MinTicketsForDiscount":
          int.tryParse(_minTicketsForDiscountController.text) ?? 0,
      "DiscountPercentage":
          double.tryParse(_discountPercentageController.text) ?? 0.0,
      "Photo": _selectedPhoto != null ? base64Encode(_selectedPhoto!) : null,
      "TripDays": _tripDays,
    };

    final validationError = _validateTripData(tripData);
    if (!validationError) {
      setState(() {
        _isSaving = false;
      });
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to edit this trip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

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
      setState(() {
        _isSaving = false;
      });
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
      setState(() {
        _isSaving = false;
      });
    }
  }

  bool _validateTripData(Map<String, dynamic> tripData) {
    final isFormValid = _formKey.currentState?.validate() ?? false;

    setState(() {
      _ticketsError = null;
      _priceError = null;
      _departureDateError = null;
      _returnDateError = null;
      _cancellationDateError = null;
      _discountError = null;
      _cancellationFeeError = null;

      final tickets = tripData["AvailableTickets"] ?? 0;
      final price = tripData["TicketPrice"] ?? 0.0;

      if (tickets <= 0) {
        _ticketsError = "Number of tickets must be greater than zero";
      }
      if (price <= 0) _priceError = "Ticket price must be greater than zero";

      final departureDateStr = tripData["DepartureDate"];
      final returnDateStr = tripData["ReturnDate"];
      final departureDate = departureDateStr != null
          ? DateTime.tryParse(departureDateStr)
          : null;
      final returnDate = returnDateStr != null
          ? DateTime.tryParse(returnDateStr)
          : null;

      if (departureDateStr == null || departureDateStr.isEmpty) {
        _departureDateError = "Departure date is required";
      }
      if (returnDateStr == null || returnDateStr.isEmpty) {
        _returnDateError = "Return date is required";
      }

      if (departureDate != null &&
          returnDate != null &&
          departureDate.isAfter(returnDate)) {
        _returnDateError = "Departure date must be before return date";
      }

      final freeCancellationUntilStr = tripData["FreeCancellationUntil"];
      final freeCancellationUntil = freeCancellationUntilStr != null
          ? DateTime.tryParse(freeCancellationUntilStr)
          : null;

      if (departureDate != null && freeCancellationUntil != null) {
        final diff = departureDate.difference(freeCancellationUntil).inDays;
        if (diff < 3) {
          _cancellationDateError =
              "Free cancellation must end at least 3 days before departure";
        }
      }

      final discount = (tripData["DiscountPercentage"] ?? 0.0).toDouble();
      final minTickets = (tripData["MinTicketsForDiscount"] ?? 0).toInt();

      if (discount < 0 || discount > 100 || minTickets < 0) {
        _discountError = "Discount must be 0-100% for at least 1 ticket";
      } else if ((discount > 0 && minTickets == 0) ||
          (minTickets > 0 && discount == 0)) {
        _discountError =
            "Both discount and minimum tickets must be set if one is > 0";
      }

      final cancellationFee = (tripData["CancellationFee"] ?? 0.0).toDouble();

      if (freeCancellationUntil != null) {
        if (cancellationFee <= 0) {
          _cancellationFeeError =
              "Cancellation fee must be set if free cancellation is selected";
        } else if (cancellationFee < 1 || cancellationFee > 100) {
          _cancellationFeeError = "Cancellation fee must be between 1 and 100";
        }
      } else {
        if (cancellationFee > 0) {
          _cancellationDateError = "Select Free Cancellation Until";
        }
      }
    });

    final noCustomErrors =
        _ticketsError == null &&
        _priceError == null &&
        _departureDateError == null &&
        _returnDateError == null &&
        _cancellationDateError == null &&
        _discountError == null &&
        _cancellationFeeError == null;

    return isFormValid && noCustomErrors;
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

  Widget _countryDropdown({
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
          errorStyle: const TextStyle(color: Colors.red),
        ),
        validator: (value) {
          if (value == null) return "Country must be selected";
          return null;
        },
        value: value,
        items: _countries.map((country) {
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
        onChanged: (enabled ?? true)
            ? (val) {
                onChanged(val);
                if (_formKey.currentState != null) {
                  _formKey.currentState!.validate();
                }
              }
            : null,
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

  Widget _cityDropdown({
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
          errorStyle: const TextStyle(color: Colors.red),
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
        validator: (value) {
          if (value == null) return "City must be selected";
          return null;
        },
        onChanged: (enabled ?? true)
            ? (val) {
                onChanged(val);
                if (_formKey.currentState != null) {
                  _formKey.currentState!.validate();
                }
              }
            : null,
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
          errorStyle: const TextStyle(color: Colors.red),
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
        onChanged: (enabled ?? true)
            ? (val) {
                onChanged(val);
                if (_formKey.currentState != null) {
                  _formKey.currentState!.validate();
                }
              }
            : null,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        dropdownColor: Colors.white,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          size: 24,
          color: Colors.black,
        ),
        iconSize: 24,
        validator: (value) {
          if (value == null) return "Trip type must be selected";
          return null;
        },
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
          errorStyle: const TextStyle(color: Colors.red),
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
        onChanged: (enabled ?? true)
            ? (val) {
                onChanged(val);
                if (_formKey.currentState != null) {
                  _formKey.currentState!.validate();
                }
              }
            : null,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        dropdownColor: Colors.white,
        validator: (value) {
          if (value == null) return "Transport is required";
          return null;
        },
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
                    Form(
                      key: _formKey,
                      child: Row(
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
                                  _countryDropdown(
                                    countries: _countries,
                                    enabled: _inputEnabled,
                                    value: _selectedCountryId,
                                    onChanged: (value) async {
                                      var countryCities =
                                          await _getCountryCities(value!);
                                      setState(() {
                                        _selectedCityId = null;
                                        _selectedCountryId = value;
                                        _cities = countryCities;
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
                                  _cityDropdown(
                                    cities: _cities,
                                    enabled: _inputEnabled,
                                    value: _selectedCityId,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCityId = value;
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
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DatePickerButton(
                                        firstDate: DateTime.now().add(
                                          const Duration(days: 5),
                                        ),
                                        lastDate: _returnDate ?? DateTime(2100),
                                        initialDate: _departureDate,
                                        enabled: _inputEnabled,
                                        onDateSelected: (date) {
                                          setState(() {
                                            _departureDate = date;
                                            _departureDateError = null;
                                          });
                                        },
                                      ),
                                      if (_departureDateError != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2,
                                            left: 12,
                                          ),
                                          child: Text(
                                            _departureDateError!,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
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
                                  Column(
                                    children: [
                                      DatePickerButton(
                                        firstDate:
                                            _departureDate ??
                                            DateTime.now().add(
                                              Duration(days: 5),
                                            ),
                                        lastDate: DateTime(2100),
                                        initialDate: _returnDate,
                                        enabled: _inputEnabled,
                                        onDateSelected: (date) {
                                          setState(() {
                                            _returnDate = date;
                                            _returnDateError = null;
                                          });
                                        },
                                      ),
                                      if (_returnDateError != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2,
                                            left: 12,
                                          ),
                                          child: Text(
                                            _returnDateError!,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
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
                                    enabled: _inputEnabled,
                                    value: _tripType,
                                    items: _tripTypes,
                                    onChanged: (val) {
                                      setState(() {
                                        _tripType = val;
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
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 170,
                                        height: 32,
                                        child: TextFormField(
                                          controller: _priceController,
                                          enabled: _inputEnabled,
                                          onChanged: (_) {
                                            if (_priceError != null) {
                                              setState(() {
                                                _priceError = null;
                                              });
                                            }
                                          },
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly,
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
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 6,
                                                ),
                                            filled: true,
                                            fillColor: _inputEnabled
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
                                      if (_priceError != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2,
                                            left: 12,
                                          ),
                                          child: Text(
                                            _priceError!,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 50,
                                              height: 32,
                                              child: TextFormField(
                                                controller:
                                                    _availableTicketsController,
                                                enabled: _inputEnabled,
                                                onChanged: (_) {
                                                  if (_ticketsError != null) {
                                                    setState(() {
                                                      _ticketsError = null;
                                                    });
                                                  }
                                                },
                                                keyboardType:
                                                    TextInputType.number,
                                                textAlign: TextAlign.center,
                                                inputFormatters:
                                                    <TextInputFormatter>[
                                                      FilteringTextInputFormatter
                                                          .digitsOnly,
                                                      LengthLimitingTextInputFormatter(
                                                        3,
                                                      ),
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
                                                  fillColor: _inputEnabled
                                                      ? AppColors.primaryGray
                                                      : Colors.blueGrey[300],
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "$_purchasedTickets already purchased",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                        if (_ticketsError != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 2,
                                              left: 12,
                                            ),
                                            child: Text(
                                              _ticketsError!,
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 12,
                                              ),
                                            ),
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
                                  _countryDropdown(
                                    countries: _countries,
                                    enabled: _inputEnabled,
                                    value: _departureCountryId,
                                    onChanged: (value) async {
                                      var departureCountryCities =
                                          await _getCountryCities(value!);
                                      setState(() {
                                        _departureCityId = null;
                                        _departureCountryId = value;
                                        _departureCities =
                                            departureCountryCities;
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
                                  _cityDropdown(
                                    cities: _departureCities,
                                    enabled: _inputEnabled,
                                    value: _departureCityId,
                                    onChanged: (value) {
                                      setState(() {
                                        _departureCityId = value;
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
                                    initialDays: _tripDays,
                                    enabled: _inputEnabled,
                                    onChanged: (updatedTripDays) {
                                      _tripDays = updatedTripDays;
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
                                    child: TextFormField(
                                      controller: _descriptionController,
                                      enabled: _inputEnabled,
                                      onChanged: (_) {
                                        if (_formKey.currentState != null) {
                                          _formKey.currentState!.validate();
                                        }
                                      },
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return "Description is required";
                                        }
                                        return null;
                                      },
                                      maxLines: null,
                                      expands: true,
                                      textAlignVertical: TextAlignVertical.top,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(200),
                                      ],
                                      decoration: InputDecoration(
                                        hintText: 'Describe your trip...',
                                        filled: true,
                                        fillColor: _inputEnabled
                                            ? AppColors.primaryGray
                                            : Colors.blueGrey[300],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: EdgeInsets.all(8),
                                        errorStyle: TextStyle(
                                          color: Colors.red,
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
                                    value: _transportType,
                                    enabled: _inputEnabled,
                                    items: _transportTypes,
                                    onChanged: (val) {
                                      setState(() {
                                        _transportType = val;
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
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
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
                                            initialDate: _freeCancellationUntil,
                                            enabled: _inputEnabled,
                                            onDateSelected: (date) {
                                              setState(() {
                                                _freeCancellationUntil = date;
                                                _cancellationDateError = null;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      if (_cancellationDateError != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2,
                                            left: 12,
                                          ),
                                          child: Text(
                                            _cancellationDateError!,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                            ),
                                          ),
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
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
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
                                              controller:
                                                  _cancellationFeeController,
                                              enabled: _inputEnabled,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                  2,
                                                ),
                                              ],
                                              decoration: InputDecoration(
                                                labelText: null,
                                                prefixIcon: Icon(Icons.percent),
                                                hintText: '0',
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 6,
                                                    ),
                                                filled: true,
                                                fillColor: _inputEnabled
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
                                        ],
                                      ),
                                      if (_cancellationFeeError != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2,
                                            left: 12,
                                          ),
                                          child: Text(
                                            _cancellationFeeError!,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
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
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 80,
                                            height: 32,
                                            child: TextField(
                                              controller:
                                                  _discountPercentageController,
                                              enabled: _inputEnabled,
                                              onChanged: (_) {
                                                if (_discountError != null) {
                                                  setState(() {
                                                    _discountError = null;
                                                  });
                                                }
                                              },
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                  2,
                                                ),
                                              ],
                                              decoration: InputDecoration(
                                                labelText: null,
                                                prefixIcon: Icon(Icons.percent),
                                                hintText: '0',
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 6,
                                                    ),
                                                filled: true,
                                                fillColor: _inputEnabled
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
                                              enabled: _inputEnabled,
                                              onChanged: (_) {
                                                if (_discountError != null) {
                                                  setState(() {
                                                    _discountError = null;
                                                  });
                                                }
                                              },
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                  2,
                                                ),
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
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 6,
                                                    ),
                                                filled: true,
                                                fillColor: _inputEnabled
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
                                        ],
                                      ),
                                      if (_discountError != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2,
                                            left: 12,
                                          ),
                                          child: Text(
                                            _discountError!,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
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
                                    initialPhoto: _selectedPhoto,
                                    enabled: _inputEnabled,
                                    onPhotoSelected: (bytes) {
                                      _selectedPhoto = bytes;
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _tripStatus == "upcoming"
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
                        _tripStatus == "complete"
                            ? Row(
                                children: [
                                  SizedBox(width: 8),
                                  SizedBox(
                                    height: 32,
                                    width: 120,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        masterScreenKey.currentState
                                            ?.navigateTo(
                                              TripReviewsScreen(trip: _trip!),
                                            );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryGreen,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "REVIEWS",
                                        style: TextStyle(
                                          color: AppColors.primaryYellow,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                        SizedBox(width: 8),
                        _isEditing
                            ? _tripStatus == "upcoming"
                                  ? SizedBox(
                                      height: 32,
                                      width: 120,
                                      child: ElevatedButton(
                                        onPressed: _isSaving ? null : _saveTrip,
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
                                  onPressed: _isSaving ? null : _addNewTrip,
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
}
