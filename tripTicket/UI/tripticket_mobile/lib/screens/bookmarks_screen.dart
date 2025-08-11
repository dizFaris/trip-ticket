import 'dart:convert';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:tripticket_mobile/app_colors.dart';
import 'package:tripticket_mobile/models/bookmark_model.dart';
import 'package:tripticket_mobile/providers/auth_provider.dart';
import 'package:tripticket_mobile/providers/bookmarks_provider.dart';
import 'package:tripticket_mobile/screens/trip_details_screen.dart';
import 'package:tripticket_mobile/utils/utils.dart';
import 'package:tripticket_mobile/widgets/pagination_controls.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final BookmarkProvider _bookmarksProvider = BookmarkProvider();
  List<Bookmark> _bookmarks = [];
  bool _isLoading = true;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _getBookmarks();
  }

  void _goToPreviousPage() {
    if (_currentPage <= 0) return;

    setState(() {
      _currentPage--;
    });

    _getBookmarks();
  }

  void _goToNextPage() {
    if (_currentPage >= _totalPages - 1) return;

    setState(() {
      _currentPage++;
    });

    _getBookmarks();
  }

  Future<void> _getBookmarks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var filter = {'UserId': AuthProvider.id!};

      var searchResult = await _bookmarksProvider.get(
        filter: filter,
        page: _currentPage,
        pageSize: 6,
      );

      setState(() {
        _bookmarks = searchResult.result;
        _totalPages = (searchResult.count / 6).ceil();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'Bookmarks',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
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
            )
          : _bookmarks.isEmpty
          ? Center(
              child: Text(
                'No results found',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookmarks.length,
                    itemBuilder: (context, index) {
                      final bookmark = _bookmarks[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TripDetailsScreen(tripId: bookmark.trip.id),
                              ),
                            ).then((value) {
                              _getBookmarks();
                            });
                          },
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(26),
                                  blurRadius: 3,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        bookmark.trip.city.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          CountryFlag.fromCountryCode(
                                            bookmark
                                                .trip
                                                .city
                                                .country!
                                                .countryCode,
                                            height: 12,
                                            width: 18,
                                            shape: const Circle(),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            bookmark.trip.city.country!.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        formatDate(bookmark.trip.departureDate),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            "Price: ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            "${bookmark.trip.ticketPrice} €",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: AppColors.primaryYellow,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: getStatusColor(
                                                bookmark.trip.tripStatus,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              bookmark.trip.tripStatus
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          bookmark.trip.availableTickets > 0
                                              ? Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.confirmation_num,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      "${bookmark.trip.availableTickets} left",
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : bookmark.trip.tripStatus ==
                                                    "upcoming"
                                              ? Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: const Text(
                                                    "SOLD OUT",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                        ],
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        height: 90,
                                        width: 90,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          image: bookmark.trip.photo != null
                                              ? DecorationImage(
                                                  image: MemoryImage(
                                                    base64Decode(
                                                      bookmark.trip.photo!,
                                                    ),
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                              : const DecorationImage(
                                                  image: AssetImage(
                                                    'assets/images/main_background.jpg',
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
                SizedBox(height: 8),
              ],
            ),
    );
  }
}
