import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tripticket_desktop/app_colors.dart';
import 'package:tripticket_desktop/models/user_model.dart';
import 'package:tripticket_desktop/providers/user_provider.dart';
import 'package:tripticket_desktop/screens/master_screen.dart';
import 'package:tripticket_desktop/screens/trips_screen.dart';
import 'package:tripticket_desktop/widgets/date_picker.dart';
import 'package:tripticket_desktop/widgets/pagination_controls.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  bool? _isActive;
  final TextEditingController _userId = TextEditingController();
  final UserProvider _userProvider = UserProvider();
  Timer? _debounce;
  bool _isLoading = true;
  int _currentPage = 0;
  int _totalPages = 0;
  List<User> _users = [];
  final _headers = [
    {'label': 'ID', 'flex': 1},
    {'label': 'Username', 'flex': 1},
    {'label': 'First name', 'flex': 1},
    {'label': 'Last name', 'flex': 1},
    {'label': 'Email', 'flex': 2},
    {'label': 'Phone', 'flex': 2},
    {'label': 'Birth date', 'flex': 2},
    {'label': 'Created at', 'flex': 2},
    {'label': '', 'flex': 1},
  ];

  @override
  void initState() {
    super.initState();

    _currentPage = 0;
    _fromDate = null;
    _toDate = null;
    _isActive = null;

    _getUsers();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _userId.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _userId.text = '';
      _currentPage = 0;
      _fromDate = null;
      _toDate = null;
      _isActive = null;
    });
    _getUsers();
  }

  Future<void> _getUsers() async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() {
        _isLoading = true;
      });

      try {
        var filter = {
          if (_userId.text.isNotEmpty) 'FTS': _userId.text,
          if (_isActive != null) 'IsActive': _isActive,
          if (_fromDate != null)
            'FromDate': _fromDate!.toIso8601String().substring(0, 10),
          if (_toDate != null)
            'ToDate': _toDate!.toIso8601String().substring(0, 10),
        };

        var searchResult = await _userProvider.get(
          filter: filter,
          page: _currentPage,
          pageSize: 15,
        );

        setState(() {
          _users = searchResult.result;
          _isLoading = false;
          _totalPages = (searchResult.count / 15).ceil();
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _users = [];
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

  Future<void> _toggleUserActiveStatus(int userId, bool isActive) async {
    try {
      await _userProvider.patch(userId, {
        "isActive": isActive,
      }, customPath: "status");

      setState(() {
        _isLoading = true;
      });

      await _getUsers();

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: Text("Success"),
          content: Text(
            "User successfully ${isActive ? "activated" : "deactivated"}.",
          ),
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

  void _goToPreviousPage() {
    if (_isLoading) return;
    setState(() {
      _currentPage--;
      _getUsers();
    });
  }

  void _goToNextPage() {
    if (_isLoading) return;
    setState(() {
      _currentPage++;
      _getUsers();
    });
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
              "Users",
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
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DatePickerButton(
                  initialDate: _fromDate,
                  allowPastDates: true,
                  placeHolder: 'Birth from',
                  lastDate: _toDate ?? DateTime(2100),
                  onDateSelected: (date) {
                    setState(() {
                      _fromDate = date;
                    });
                    _getUsers();
                  },
                ),
                SizedBox(width: 8),
                DatePickerButton(
                  initialDate: _toDate,
                  allowPastDates: true,
                  placeHolder: 'Birth to',
                  firstDate: _fromDate ?? DateTime(1950),
                  onDateSelected: (date) {
                    setState(() {
                      _toDate = date;
                    });
                    _getUsers();
                  },
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 140,
                  child: DropdownButtonFormField<bool>(
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: AppColors.primaryGray,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Status',
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    value: _isActive,
                    items: const [
                      DropdownMenuItem(
                        value: true,
                        child: Text(
                          'Activated',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      DropdownMenuItem(
                        value: false,
                        child: Text(
                          'Deactivated',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _isActive = val!;
                      });
                      _getUsers();
                    },
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    dropdownColor: Colors.white,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 24,
                      color: Colors.black,
                    ),
                    iconSize: 24,
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 250,
                  height: 32,
                  child: TextFormField(
                    controller: _userId,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      labelText: null,
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search, size: 20),
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
                      _getUsers();
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
                    onPressed: _getUsers,
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
              ],
            ),

            SizedBox(height: 8),

            Container(
              padding: EdgeInsets.all(8),
              color: AppColors.primaryGreen,
              child: Row(
                children: _headers.map((header) {
                  return Expanded(
                    flex: header['flex'] as int,
                    child: Text(
                      header['label'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

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
                    child: _users.isEmpty
                        ? const Center(child: Text('No users found.'))
                        : ListView.builder(
                            itemCount: _users.length,
                            itemBuilder: (context, index) {
                              final user = _users[index];

                              return Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        user.id.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(user.firstName),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(user.lastName),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(user.username),
                                    ),
                                    Expanded(flex: 2, child: Text(user.email)),
                                    Expanded(
                                      flex: 2,
                                      child: Text(user.phone ?? ''),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        user.birthDate.toString().substring(
                                          0,
                                          10,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        user.createdAt.toString().substring(
                                          0,
                                          10,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: user.isActive
                                          ? IconButton(
                                              icon: const Icon(
                                                Icons.block,
                                                color: Colors.red,
                                              ),
                                              onPressed: () async {
                                                final confirmed =
                                                    await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        title: const Text(
                                                          'Confirm deativation',
                                                        ),
                                                        content: const Text(
                                                          'Are you sure you want to deactivate this user?',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                  context,
                                                                ).pop(false),
                                                            child: const Text(
                                                              'No',
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                  context,
                                                                ).pop(true),
                                                            child: const Text(
                                                              'Yes',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );

                                                if (confirmed == true) {
                                                  _toggleUserActiveStatus(
                                                    user.id,
                                                    false,
                                                  );
                                                }
                                              },
                                            )
                                          : IconButton(
                                              icon: const Icon(
                                                Icons.update_outlined,
                                                color: AppColors.primaryGreen,
                                              ),
                                              onPressed: () async {
                                                final confirmed =
                                                    await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                            title: const Text(
                                                              'Confirm activate',
                                                            ),
                                                            content: const Text(
                                                              'Are you sure you want to activate this user?',
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop(
                                                                      false,
                                                                    ),
                                                                child:
                                                                    const Text(
                                                                      'No',
                                                                    ),
                                                              ),
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop(true),
                                                                child:
                                                                    const Text(
                                                                      'Yes',
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                    );

                                                if (confirmed == true) {
                                                  _toggleUserActiveStatus(
                                                    user.id,
                                                    true,
                                                  );
                                                }
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              );
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
