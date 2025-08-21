import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tripticket_desktop/app_colors.dart';
import 'package:tripticket_desktop/models/transaction_model.dart';
import 'package:tripticket_desktop/providers/transaction_provider.dart';
import 'package:tripticket_desktop/screens/master_screen.dart';
import 'package:tripticket_desktop/screens/trips_screen.dart';
import 'package:tripticket_desktop/utils/utils.dart';
import 'package:tripticket_desktop/widgets/date_picker.dart';
import 'package:tripticket_desktop/widgets/pagination_controls.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _selectedStatus;
  String? _selectedType;
  final List<String> _statuses = ["failed", "complete"];
  final List<String> _types = ["payment", "refund"];
  final TextEditingController _minPrice = TextEditingController();
  final TextEditingController _maxPrice = TextEditingController();
  final TextEditingController _purchaseId = TextEditingController();
  final TransactionProvider _transactionProvider = TransactionProvider();
  Timer? _debounce;
  bool _isLoading = true;
  int _currentPage = 0;
  int _totalPages = 0;
  List<Transaction> _transactions = [];

  final _headers = [
    {'label': 'ID', 'flex': 1},
    {'label': 'Purchase ID', 'flex': 1},
    {'label': 'Type', 'flex': 1},
    {'label': 'Amount', 'flex': 1},
    {'label': 'Method', 'flex': 1},
    {'label': 'Date', 'flex': 1},
    {'label': 'Stripe transaction ID', 'flex': 2},
    {'label': 'Status', 'flex': 1},
  ];

  @override
  void initState() {
    super.initState();

    _currentPage = 0;
    _fromDate = null;
    _toDate = null;
    _selectedStatus = null;

    _getTransactions();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _minPrice.dispose();
    _maxPrice.dispose();
    _purchaseId.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _selectedStatus = null;
      _selectedType = null;
      _minPrice.text = '';
      _maxPrice.text = '';
      _purchaseId.text = '';
      _currentPage = 0;
    });
    _getTransactions();
  }

  Future<void> _getTransactions() async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() {
        _isLoading = true;
      });

      try {
        var filter = {
          if (_selectedStatus != null) 'Status': _selectedStatus,
          if (_selectedType != null) 'Type': _selectedType,
          if (_minPrice.text.isNotEmpty) 'MinAmount': _minPrice.text,
          if (_maxPrice.text.isNotEmpty) 'MaxAmount': _maxPrice.text,
          if (_purchaseId.text.isNotEmpty) 'FTS': _purchaseId.text,
          if (_fromDate != null)
            'FromDate': _fromDate!.toIso8601String().substring(0, 10),
          if (_toDate != null)
            'ToDate': _toDate!.toIso8601String().substring(0, 10),
        };

        var searchResult = await _transactionProvider.get(
          filter: filter,
          page: _currentPage,
          pageSize: 15,
        );

        setState(() {
          _transactions = searchResult.result;
          _isLoading = false;
          _totalPages = (searchResult.count / 15).ceil();
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _transactions = [];
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
    });
  }

  void _goToPreviousPage() {
    if (_isLoading) return;
    setState(() {
      _currentPage--;
      _getTransactions();
    });
  }

  void _goToNextPage() {
    if (_isLoading) return;
    setState(() {
      _currentPage++;
      _getTransactions();
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
              "Transactions Overview",
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
                  placeHolder: 'Date from',
                  firstDate: DateTime(2025),
                  lastDate: _toDate ?? DateTime(2100),
                  onDateSelected: (date) {
                    setState(() {
                      _fromDate = date;
                    });
                    _getTransactions();
                  },
                ),
                SizedBox(width: 8),
                DatePickerButton(
                  initialDate: _toDate,
                  allowPastDates: true,
                  placeHolder: 'Date to',
                  firstDate: _fromDate ?? DateTime(2025),
                  onDateSelected: (date) {
                    setState(() {
                      _toDate = date;
                    });
                    _getTransactions();
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
                    _getTransactions();
                  },
                ),
                SizedBox(width: 8),
                _dropdown<String>(
                  label: 'Type',
                  value: _selectedType,
                  items: _types,
                  onChanged: (val) {
                    setState(() {
                      _selectedType = val;
                    });
                    _getTransactions();
                  },
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  height: 32,
                  child: TextField(
                    controller: _minPrice,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                    decoration: InputDecoration(
                      labelText: null,
                      hintText: 'Min price',
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
                      _getTransactions();
                    },
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  height: 32,
                  child: TextField(
                    controller: _maxPrice,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                    decoration: InputDecoration(
                      labelText: null,
                      hintText: 'Max price',
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
                      _getTransactions();
                    },
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 200,
                  height: 32,
                  child: TextFormField(
                    controller: _purchaseId,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      labelText: null,
                      hintText: 'ID',
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
                      _getTransactions();
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
                    onPressed: _getTransactions,
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
                    child: _transactions.isEmpty
                        ? const Center(child: Text('No transactions found.'))
                        : ListView.builder(
                            itemCount: _transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = _transactions[index];

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
                                        transaction.id.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        transaction.purchaseId.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        transaction.type,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "${transaction.amount.toStringAsFixed(2)}€",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        transaction.paymentMethod,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        transaction.transactionDate
                                            .toString()
                                            .substring(0, 10),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        transaction.stripeTransactionId,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 100,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: getStatusColor(
                                              transaction.status,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            transaction.status.toUpperCase(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
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
