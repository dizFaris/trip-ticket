import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tripticket_desktop/app_colors.dart';
import 'package:tripticket_desktop/providers/country_provider.dart';
import 'package:tripticket_desktop/models/country_model.dart';
import 'package:country_flags/country_flags.dart';
import 'package:tripticket_desktop/screens/cities_screen.dart';
import 'package:tripticket_desktop/screens/master_screen.dart';
import 'package:tripticket_desktop/screens/trips_screen.dart';
import 'package:tripticket_desktop/widgets/pagination_controls.dart';

class CountriesScreen extends StatefulWidget {
  const CountriesScreen({super.key});

  @override
  CountriesScreenState createState() => CountriesScreenState();
}

class CountriesScreenState extends State<CountriesScreen> {
  final CountryProvider _countryProvider = CountryProvider();
  final TextEditingController _ftsController = TextEditingController();
  List<Country> _countries = [];
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isLoading = true;
  bool _isModalLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _loadCountries();
  }

  @override
  void dispose() {
    _ftsController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var filter = {
        if (_ftsController.text.isNotEmpty) 'FTS': _ftsController.text,
      };

      var searchResult = await _countryProvider.get(
        filter: filter,
        page: _currentPage,
        pageSize: 10,
      );

      setState(() {
        _countries = searchResult.result;
        _isLoading = false;
        _totalPages = (searchResult.count / 10).ceil();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goToPreviousPage() {
    setState(() {
      _currentPage--;
      _loadCountries();
    });
  }

  void _goToNextPage() {
    setState(() {
      _currentPage++;
      _loadCountries();
    });
  }

  Future<void> _hideCountry(countryId) async {
    final country = {"IsActive": false};

    try {
      await _countryProvider.update(countryId, country);

      setState(() {
        _currentPage = 0;
        _isLoading = true;
      });

      await _loadCountries();

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: Text("Success"),
          content: Text("Country successfully removed"),
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

  Future<void> _addNewCountry(String name, String code) async {
    setState(() {
      _isModalLoading = true;
    });

    final country = {"Name": name, "CountryCode": code};

    try {
      await _countryProvider.insert(country);

      if (!mounted) return;

      Navigator.of(context).pop();

      final result = await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: Text("Success"),
          content: Text("Country successfully added"),
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
        setState(() {
          _currentPage = 0;
          _isLoading = true;
        });

        await _loadCountries();

        setState(() {
          _isLoading = false;
          _isModalLoading = false;
        });
      }
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _isModalLoading = false;
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
              'Countries',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: _ftsController,
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
                        _loadCountries();
                      });
                    },
                  ),
                ),

                SizedBox(width: 8),

                SizedBox(
                  height: 38,
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          final TextEditingController countryName =
                              TextEditingController();
                          final TextEditingController countryCode =
                              TextEditingController();

                          return AlertDialog(
                            title: Text(
                              "Add New Country",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: _isModalLoading
                                ? SizedBox(
                                    height: 32,
                                    width: 32,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 4,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: countryName,
                                        decoration: InputDecoration(
                                          labelText: null,
                                          hintText: 'Country name',
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
                                      SizedBox(height: 8),
                                      TextFormField(
                                        controller: countryCode,
                                        decoration: InputDecoration(
                                          hintText: 'Country code',
                                          filled: true,
                                          fillColor: AppColors.primaryGray,
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        maxLength: 2,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'[a-zA-Z]'),
                                          ),
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Country code is required';
                                          }
                                          if (!RegExp(
                                            r'^[a-zA-Z]{2}$',
                                          ).hasMatch(value)) {
                                            return 'Enter exactly 2 letters';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                            actions: _isModalLoading
                                ? []
                                : [
                                    TextButton(
                                      onPressed: () async {
                                        final name = countryName.text.trim();
                                        final code = countryCode.text.trim();

                                        await _addNewCountry(name, code);
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: AppColors.primaryGreen,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      child: const Text("Add"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: AppColors.primaryRed,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      child: const Text("Cancel"),
                                    ),
                                  ],
                          );
                        },
                      );
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

            const SizedBox(height: 16),

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
                    child: _countries.isEmpty
                        ? const Center(child: Text('No countries found.'))
                        : ListView.builder(
                            itemCount: _countries.length,
                            itemBuilder: (context, index) {
                              final country = _countries[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 8.0,
                                  ),
                                  child: Row(
                                    children: [
                                      CountryFlag.fromCountryCode(
                                        country.countryCode,
                                        height: 24,
                                        width: 32,
                                        shape: const Circle(),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          country.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () => _editCountry(country),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                'Confirm Delete',
                                              ),
                                              content: const Text(
                                                'Are you sure you want to delete this country?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                    context,
                                                  ).pop(false),
                                                  child: const Text('No'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                    context,
                                                  ).pop(true),
                                                  child: const Text('Yes'),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirmed == true) {
                                            _hideCountry(country.id);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

            const SizedBox(height: 12),
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

  void _editCountry(Country country) {
    masterScreenKey.currentState?.navigateTo(CitiesScreen(country: country));
  }
}
