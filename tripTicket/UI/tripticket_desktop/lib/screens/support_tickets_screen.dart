import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tripticket_desktop/app_colors.dart';
import 'package:tripticket_desktop/models/support_ticket_model.dart';
import 'package:tripticket_desktop/providers/support_ticket_provider.dart';
import 'package:tripticket_desktop/screens/master_screen.dart';
import 'package:tripticket_desktop/screens/support_reply_screen.dart';
import 'package:tripticket_desktop/screens/trips_screen.dart';
import 'package:tripticket_desktop/utils/utils.dart';
import 'package:tripticket_desktop/widgets/date_picker.dart';
import 'package:tripticket_desktop/widgets/pagination_controls.dart';

class SupportTicketsScreen extends StatefulWidget {
  const SupportTicketsScreen({super.key});

  @override
  State<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends State<SupportTicketsScreen> {
  final SupportTicketProvider _supportTicketProvider = SupportTicketProvider();
  final TextEditingController _ftsController = TextEditingController();
  List<SupportTicket> _tickets = [];
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isLoading = true;
  Timer? _debounce;
  int? _expandedTicketId;
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _selectedStatus;
  final List<String> _statuses = ["open", "resolved"];

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _fromDate = null;
    _toDate = null;
    _selectedStatus = null;
    _loadTickets();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ftsController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var filter = {
        if (_ftsController.text.isNotEmpty) 'FTS': _ftsController.text,
        if (_fromDate != null)
          'FromDate': _fromDate!.toIso8601String().substring(0, 10),
        if (_toDate != null)
          'ToDate': _toDate!.toIso8601String().substring(0, 10),
        if (_selectedStatus != null) 'Status': _selectedStatus,
      };

      var searchResult = await _supportTicketProvider.get(
        filter: filter,
        page: _currentPage,
        pageSize: 10,
      );

      setState(() {
        _tickets = searchResult.result;
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
      _loadTickets();
    });
  }

  void _goToNextPage() {
    setState(() {
      _currentPage++;
      _loadTickets();
    });
  }

  _clearFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _selectedStatus = null;
      _ftsController.clear();
      _currentPage = 0;
      _loadTickets();
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
              'Support Tickets',
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
                  height: 32,
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
                        _loadTickets();
                      });
                    },
                  ),
                ),

                SizedBox(width: 8),
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
                    _loadTickets();
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
                    _loadTickets();
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
                    _loadTickets();
                  },
                ),
                SizedBox(width: 8),
                SizedBox(
                  height: 32,
                  width: 32,
                  child: ElevatedButton(
                    onPressed: _loadTickets,
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
                    child: _tickets.isEmpty
                        ? const Center(child: Text('No tickets found.'))
                        : ListView.builder(
                            itemCount: _tickets.length,
                            itemBuilder: (context, index) {
                              final ticket = _tickets[index];
                              final isExpanded = _expandedTicketId == ticket.id;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _expandedTicketId = isExpanded
                                        ? null
                                        : ticket.id;
                                  });
                                },
                                child: Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: ticket.status == 'open'
                                                    ? AppColors.primaryBlue
                                                    : AppColors.primaryBlack,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                ticket.status.toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),

                                            Expanded(
                                              child: Text(
                                                '${ticket.user.username} - ${ticket.subject}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),

                                            Icon(
                                              isExpanded
                                                  ? Icons.keyboard_arrow_up
                                                  : Icons.keyboard_arrow_down,
                                              color: Colors.grey[700],
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                        ),

                                        if (isExpanded) ...[
                                          if (ticket.resolvedAt != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Resolved at: ${formatDate(ticket.resolvedAt!)}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 8),
                                          Text(ticket.message),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                masterScreenKey.currentState
                                                    ?.navigateTo(
                                                      SupportReplyScreen(
                                                        ticket: ticket,
                                                      ),
                                                    );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primaryYellow,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Text(
                                                "Reply",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
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
