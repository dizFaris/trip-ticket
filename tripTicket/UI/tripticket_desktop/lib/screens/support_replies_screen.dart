import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tripticket_desktop/app_colors.dart';
import 'package:tripticket_desktop/models/support_reply_model.dart';
import 'package:tripticket_desktop/providers/support_reply_provider.dart';
import 'package:tripticket_desktop/screens/master_screen.dart';
import 'package:tripticket_desktop/screens/trips_screen.dart';
import 'package:tripticket_desktop/utils/utils.dart';
import 'package:tripticket_desktop/widgets/date_picker.dart';
import 'package:tripticket_desktop/widgets/pagination_controls.dart';

class SupportRepliesScreen extends StatefulWidget {
  const SupportRepliesScreen({super.key});

  @override
  State<SupportRepliesScreen> createState() => _SupportRepliesScreenState();
}

class _SupportRepliesScreenState extends State<SupportRepliesScreen> {
  final SupportReplyProvider _supportReplyProvider = SupportReplyProvider();
  final TextEditingController _ftsController = TextEditingController();
  List<SupportReply> _replies = [];
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isLoading = true;
  Timer? _debounce;
  int? _expandedReplyId;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _fromDate = null;
    _toDate = null;
    _loadReplies();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ftsController.dispose();
    super.dispose();
  }

  Future<void> _loadReplies() async {
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
      };

      var searchResult = await _supportReplyProvider.get(
        filter: filter,
        page: _currentPage,
        pageSize: 10,
      );

      setState(() {
        _replies = searchResult.result;
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
      _loadReplies();
    });
  }

  void _goToNextPage() {
    setState(() {
      _currentPage++;
      _loadReplies();
    });
  }

  _clearFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _ftsController.clear();
      _currentPage = 0;
      _loadReplies();
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
              'Support Replies',
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
                        _loadReplies();
                      });
                    },
                  ),
                ),

                SizedBox(width: 8),
                DatePickerButton(
                  initialDate: _fromDate,
                  allowPastDates: true,
                  placeHolder: 'Date from',
                  lastDate: _toDate ?? DateTime(2100),
                  onDateSelected: (date) {
                    setState(() {
                      _fromDate = date;
                    });
                    _loadReplies();
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
                    _loadReplies();
                  },
                ),
                SizedBox(width: 8),
                SizedBox(
                  height: 32,
                  width: 32,
                  child: ElevatedButton(
                    onPressed: _loadReplies,
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
                    child: _replies.isEmpty
                        ? const Center(child: Text('No replies found.'))
                        : ListView.builder(
                            itemCount: _replies.length,
                            itemBuilder: (context, index) {
                              final reply = _replies[index];
                              final isExpanded = _expandedReplyId == reply.id;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _expandedReplyId = isExpanded
                                        ? null
                                        : reply.id;
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
                                            Expanded(
                                              child: Text(
                                                '${reply.ticket!.user.username} - ${reply.ticket!.subject}',
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
                                          if (reply.ticket!.resolvedAt !=
                                              null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Resolved at: ${formatDate(reply.ticket!.resolvedAt!)}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                          ],
                                          Text(
                                            "Your Reply: ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(reply.ticket!.message),
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
