import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tripticket_desktop/app_colors.dart';
import 'package:tripticket_desktop/models/city_model.dart';
import 'package:tripticket_desktop/models/country_model.dart';
import 'package:tripticket_desktop/providers/city_provider.dart';
import 'package:country_flags/country_flags.dart';
import 'package:tripticket_desktop/screens/countries_screen.dart';
import 'package:tripticket_desktop/screens/master_screen.dart';
import 'package:tripticket_desktop/widgets/pagination_controls.dart';

class CitiesScreen extends StatefulWidget {
  final Country country;

  const CitiesScreen({super.key, required this.country});

  @override
  CitiesScreenState createState() => CitiesScreenState();
}

class CitiesScreenState extends State<CitiesScreen> {
  final CityProvider _cityProvider = CityProvider();
  final TextEditingController _ftsController = TextEditingController();
  List<City> _cities = [];
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isLoading = true;
  bool _isModalLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _loadCountryCities();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ftsController.dispose();
    super.dispose();
  }

  Future<void> _loadCountryCities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var filter = {
        if (_ftsController.text.isNotEmpty) 'FTS': _ftsController.text,
      };

      var searchResult = await _cityProvider.getCitiesByCountryId(
        widget.country.id,
        filter: filter,
        page: _currentPage,
        pageSize: 10,
      );

      setState(() {
        _cities = searchResult.result;
        _isLoading = false;
        _totalPages = (searchResult.count / 10).ceil();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _cities = [];
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

  void _goToPreviousPage() {
    setState(() {
      _currentPage--;
      _loadCountryCities();
    });
  }

  void _goToNextPage() {
    setState(() {
      _currentPage++;
      _loadCountryCities();
    });
  }

  Future<void> _hideCity(countryId) async {
    final country = {"IsActive": false};

    try {
      await _cityProvider.update(countryId, country);

      setState(() {
        _currentPage = 0;
        _isLoading = true;
      });

      await _loadCountryCities();

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: Text("Success"),
          content: Text("City successfully removed"),
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

  Future<void> _addNewCity(name) async {
    setState(() {
      _isModalLoading = true;
    });

    final city = {"Name": name, "CountryId": widget.country.id};

    try {
      await _cityProvider.insert(city);

      setState(() {
        _currentPage = 0;
        _isLoading = true;
      });

      await _loadCountryCities();

      setState(() {
        _isLoading = false;
        _isModalLoading = false;
      });

      if (!mounted) return;

      Navigator.of(context).pop();

      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: Text("Success"),
          content: Text("City successfully added"),
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
                    masterScreenKey.currentState?.navigateTo(CountriesScreen()),
              ),
            ),
            SizedBox(width: 12),
            Row(
              children: [
                Text(
                  widget.country.name.isNotEmpty
                      ? 'Cities for ${widget.country.name}'
                      : 'Cities',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 12),
                CountryFlag.fromCountryCode(
                  widget.country.countryCode.isNotEmpty
                      ? widget.country.countryCode
                      : '',
                  height: 24,
                  width: 32,
                  shape: const Circle(),
                ),
              ],
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
                        _loadCountryCities();
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
                          final TextEditingController city =
                              TextEditingController();

                          return AlertDialog(
                            title: Text(
                              "Add New City",
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
                                        controller: city,
                                        decoration: InputDecoration(
                                          labelText: null,
                                          hintText: 'City',
                                          filled: true,
                                          fillColor: AppColors.primaryGray,
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onSubmitted: (_) {
                                          final name = city.text.trim();
                                          _addNewCity(name);
                                        },
                                      ),
                                    ],
                                  ),
                            actions: _isModalLoading
                                ? []
                                : [
                                    TextButton(
                                      onPressed: () async {
                                        final name = city.text.trim();

                                        await _addNewCity(name);
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
                    child: _cities.isEmpty
                        ? const Center(child: Text('No cities found.'))
                        : ListView.builder(
                            itemCount: _cities.length,
                            itemBuilder: (context, index) {
                              final country = _cities[index];
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
                                                'Are you sure you want to delete this city?',
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
                                            _hideCity(country.id);
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
}
