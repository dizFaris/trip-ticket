import 'dart:async';
import 'dart:convert';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tripticket_desktop/app_colors.dart';
import 'package:tripticket_desktop/models/purchase_model.dart';
import 'package:tripticket_desktop/providers/purchase_provider.dart';
import 'package:tripticket_desktop/screens/master_screen.dart';
import 'package:tripticket_desktop/screens/pdf_view_screen.dart';
import 'package:tripticket_desktop/screens/trips_screen.dart';
import 'package:tripticket_desktop/utils/utils.dart';
import 'package:tripticket_desktop/widgets/date_picker.dart';
import 'package:tripticket_desktop/widgets/pagination_controls.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _selectedStatus;
  final List<String> _statuses = [
    "accepted",
    "expired",
    "canceled",
    "complete",
    "failed",
    "pending",
  ];
  final TextEditingController _minTicketCount = TextEditingController();
  final TextEditingController _maxTicketCount = TextEditingController();
  final TextEditingController _minPrice = TextEditingController();
  final TextEditingController _maxPrice = TextEditingController();
  final TextEditingController _purchaseId = TextEditingController();
  final PurchaseProvider _purchaseProvider = PurchaseProvider();
  Timer? _debounce;
  bool _isLoading = true;
  int _currentPage = 0;
  int _totalPages = 0;
  List<Purchase> _purchases = [];
  final _headers = [
    {'label': 'ID', 'flex': 1},
    {'label': 'Created at', 'flex': 2},
    {'label': 'Payment', 'flex': 2},
    {'label': 'Ticket count', 'flex': 1},
    {'label': 'Customer', 'flex': 1},
    {'label': 'Destination', 'flex': 1},
    {'label': 'Status', 'flex': 1},
  ];

  @override
  void initState() {
    super.initState();

    _currentPage = 0;
    _fromDate = null;
    _toDate = null;
    _selectedStatus = null;

    _getPurchases();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _minTicketCount.dispose();
    _maxTicketCount.dispose();
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
      _minTicketCount.text = '';
      _maxTicketCount.text = '';
      _minPrice.text = '';
      _maxPrice.text = '';
      _purchaseId.text = '';
      _currentPage = 0;
    });
    _getPurchases();
  }

  Future<void> _getPurchases() async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      try {
        var filter = {
          if (_selectedStatus != null) 'Status': _selectedStatus,
          if (_minTicketCount.text.isNotEmpty)
            'MinTicketCount': _minTicketCount.text,
          if (_maxTicketCount.text.isNotEmpty)
            'MaxTicketCount': _maxTicketCount.text,
          if (_minPrice.text.isNotEmpty) 'MinPayment': _minPrice.text,
          if (_maxPrice.text.isNotEmpty) 'MaxPayment': _maxPrice.text,
          if (_purchaseId.text.isNotEmpty) 'FTS': _purchaseId.text,
          if (_fromDate != null)
            'FromDate': _fromDate!.toIso8601String().substring(0, 10),
          if (_toDate != null)
            'ToDate': _toDate!.toIso8601String().substring(0, 10),
        };

        var searchResult = await _purchaseProvider.get(
          filter: filter,
          page: _currentPage,
          pageSize: 15,
        );

        if (!mounted) return;
        setState(() {
          _purchases = searchResult.result;
          _isLoading = false;
          _totalPages = (searchResult.count / 15).ceil();
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _purchases = [];
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

  void _cancelPurchase(int id) async {
    try {
      var refundAmount = await _purchaseProvider.cancelPurchase(id);

      var message = refundAmount > 0
          ? "Refunded amount ${refundAmount.toStringAsFixed(2)} €"
          : "No money was refunded";

      if (!mounted) return;
      final result = await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: Text("Success"),
          content: Text("Purchase successfully canceled. $message"),
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
        if (!mounted) return;
        Navigator.pop(context);
      }

      _getPurchases();
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
      _getPurchases();
    });
  }

  void _goToNextPage() {
    if (_isLoading) return;
    setState(() {
      _currentPage++;
      _getPurchases();
    });
  }

  Future<void> _getTicketsPdf(int id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final (bytes, fileName) = await _purchaseProvider.getTicketsPdf(id);

      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pop();

      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (_) =>
                  PdfViewerPage(pdfBytes: bytes, fileName: fileName),
            ),
          )
          .then((value) {
            _getPurchases();
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
              "Purchases Overview",
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
                  lastDate: _toDate ?? DateTime(2100),
                  onDateSelected: (date) {
                    setState(() {
                      _fromDate = date;
                    });
                    _getPurchases();
                  },
                ),
                SizedBox(width: 8),
                DatePickerButton(
                  initialDate: _toDate,
                  allowPastDates: true,
                  placeHolder: 'Date to',
                  firstDate: _fromDate ?? DateTime(1950),
                  onDateSelected: (date) {
                    setState(() {
                      _toDate = date;
                    });
                    _getPurchases();
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
                    _getPurchases();
                  },
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  height: 32,
                  child: TextField(
                    controller: _minTicketCount,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    decoration: InputDecoration(
                      labelText: null,
                      hintText: 'Min count',
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
                      _getPurchases();
                    },
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  height: 32,
                  child: TextField(
                    controller: _maxTicketCount,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    decoration: InputDecoration(
                      labelText: null,
                      hintText: 'Max count',
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
                      _getPurchases();
                    },
                  ),
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
                      LengthLimitingTextInputFormatter(3),
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
                      _getPurchases();
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
                      LengthLimitingTextInputFormatter(3),
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
                      _getPurchases();
                    },
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 140,
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
                      _getPurchases();
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
                    onPressed: _getPurchases,
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
                    child: _purchases.isEmpty
                        ? const Center(child: Text('No purchases found.'))
                        : ListView.builder(
                            itemCount: _purchases.length,
                            itemBuilder: (context, index) {
                              final purchase = _purchases[index];
                              List<int>? purchasePhoto =
                                  (purchase.trip.photo != null &&
                                      purchase.trip.photo!.isNotEmpty)
                                  ? base64Decode(purchase.trip.photo!)
                                  : null;
                              Uint8List? imageData;

                              if (purchasePhoto != null) {
                                imageData = Uint8List.fromList(purchasePhoto);
                              }

                              return InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.0,
                                          ),
                                        ),
                                        child: SizedBox(
                                          width: 600,
                                          height: 420,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12,
                                                    ),
                                                decoration: const BoxDecoration(
                                                  color: AppColors.primaryGreen,
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                        top: Radius.circular(
                                                          12,
                                                        ),
                                                      ),
                                                ),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        'Purchase Details',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      purchase.isPrinted ||
                                                              purchase.status !=
                                                                  "complete"
                                                          ? SizedBox.shrink()
                                                          : SizedBox(
                                                              height: 32,
                                                              width: 32,
                                                              child: ElevatedButton(
                                                                onPressed: () =>
                                                                    _getTicketsPdf(
                                                                      purchase
                                                                          .id,
                                                                    ),
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .primaryYellow,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          8,
                                                                        ),
                                                                  ),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                ),
                                                                child: const Icon(
                                                                  Icons
                                                                      .description,
                                                                  color: Colors
                                                                      .black,
                                                                  size: 20,
                                                                ),
                                                              ),
                                                            ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "Purchase ID: ${purchase.id}",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          SizedBox(height: 8),
                                                          Text(
                                                            "Customer: ${purchase.user.firstName} ${purchase.user.lastName}",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          SizedBox(height: 8),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Status:",
                                                                style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 8,
                                                              ),
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          4,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color: getStatusColor(
                                                                    purchase
                                                                        .status,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        6,
                                                                      ),
                                                                ),
                                                                child: Text(
                                                                  purchase
                                                                      .status
                                                                      .toUpperCase(),
                                                                  style: const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 8),
                                                          Text(
                                                            "Created at: ${DateFormat('dd-MM-yyyy').format(purchase.createdAt)}",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          SizedBox(height: 8),
                                                          Text(
                                                            "Expires at: ${DateFormat('dd-MM-yyyy').format(purchase.trip.expirationDate)}",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          SizedBox(height: 8),
                                                          Text(
                                                            "Destination: ${purchase.trip.city}",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          SizedBox(height: 8),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Country:",
                                                                style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 8,
                                                              ),
                                                              Text(
                                                                purchase
                                                                    .trip
                                                                    .country,
                                                                style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 8,
                                                              ),
                                                              CountryFlag.fromCountryCode(
                                                                purchase
                                                                    .trip
                                                                    .countryCode,
                                                                height: 15,
                                                                width: 20,
                                                                shape:
                                                                    const Circle(),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 8),
                                                          Text(
                                                            "Payment: ${purchase.totalPayment.toStringAsFixed(2)} €",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          SizedBox(height: 8),
                                                          Text(
                                                            "Ticket count: ${purchase.numberOfTickets}",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          SizedBox(height: 8),
                                                          Text(
                                                            purchase.discount !=
                                                                    null
                                                                ? "Discount: ${purchase.discount!.toStringAsFixed(2)} %"
                                                                : "Discount: 0.00%",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Spacer(),
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                height: 28,
                                                                width: 90,
                                                                child: ElevatedButton(
                                                                  onPressed: () {
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop();
                                                                  },
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor:
                                                                        AppColors
                                                                            .primaryYellow,
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            4,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    "CLOSE",
                                                                    style: TextStyle(
                                                                      color: AppColors
                                                                          .primaryBlack,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 8,
                                                              ),
                                                              purchase.status ==
                                                                      'accepted'
                                                                  ? SizedBox(
                                                                      height:
                                                                          28,
                                                                      width:
                                                                          170,
                                                                      child: ElevatedButton(
                                                                        onPressed: () {
                                                                          _cancelPurchase(
                                                                            purchase.id,
                                                                          );
                                                                        },
                                                                        style: ElevatedButton.styleFrom(
                                                                          backgroundColor:
                                                                              AppColors.primaryRed,
                                                                          padding:
                                                                              EdgeInsets.zero,
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                              4,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        child: const Text(
                                                                          "CANCEL AND REFUND",
                                                                          style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : SizedBox.shrink(),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      Spacer(),
                                                      Column(
                                                        children: [
                                                          Container(
                                                            width: 280,
                                                            height: 300,
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                              color: Colors
                                                                  .blueGrey[300],
                                                            ),
                                                            child:
                                                                imageData !=
                                                                    null
                                                                ? Image.memory(
                                                                    imageData,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    filterQuality:
                                                                        FilterQuality
                                                                            .high,
                                                                    width: 250,
                                                                    height: 300,
                                                                  )
                                                                : const Center(
                                                                    child: Icon(
                                                                      Icons
                                                                          .photo,
                                                                    ),
                                                                  ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                hoverColor: Colors.grey[300],
                                child: Container(
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
                                          purchase.id.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          purchase.createdAt
                                              .toString()
                                              .substring(0, 10),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "${purchase.totalPayment.toStringAsFixed(2)}€",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          purchase.numberOfTickets.toString(),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(purchase.user.username),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(purchase.trip.city),
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
                                                purchase.status,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              purchase.status.toUpperCase(),
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
