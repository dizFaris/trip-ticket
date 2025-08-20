import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:tripticket_desktop/app_colors.dart';
import 'package:tripticket_desktop/models/trip_model.dart';
import 'package:tripticket_desktop/models/trip_review_model.dart';
import 'package:tripticket_desktop/providers/trip_review_provider.dart';
import 'package:tripticket_desktop/screens/master_screen.dart';
import 'package:tripticket_desktop/screens/trip_screen.dart';

class TripReviewsScreen extends StatefulWidget {
  final Trip trip;

  const TripReviewsScreen({super.key, required this.trip});

  @override
  State<TripReviewsScreen> createState() => _TripReviewsScreenState();
}

class _TripReviewsScreenState extends State<TripReviewsScreen> {
  final TripReviewProvider _tripReviewProvider = TripReviewProvider();
  List<TripReview> _tripReviews = [];
  bool _isLoading = true;
  double _averageRating = 0;

  @override
  void initState() {
    super.initState();
    _getTripReviews();
  }

  Future<void> _getTripReviews() async {
    try {
      var filter = {"TripId": widget.trip.id};
      var reviews = await _tripReviewProvider.get(filter: filter);
      var average = await _tripReviewProvider.getAverageRating(widget.trip.id);
      setState(() {
        _tripReviews = reviews.result;
        _isLoading = false;
        _averageRating = average;
      });
    } catch (e) {
      debugPrint("Error loading trip reviews: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteReview(TripReview review) async {
    bool confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Review"),
        content: const Text("Are you sure you want to delete this review?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm) {
      try {
        await _tripReviewProvider.delete(review.id);
        setState(() {
          _tripReviews.remove(review);
        });
      } catch (e) {
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
                onPressed: () => masterScreenKey.currentState?.navigateTo(
                  TripScreen(tripId: widget.trip.id),
                ),
              ),
            ),
            SizedBox(width: 12),
            Text(
              "Trip Reviews",
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
          ? const Center(child: CircularProgressIndicator())
          : _tripReviews.isEmpty
          ? const Center(child: Text("No reviews yet"))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 👈 align left
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.trip.city.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          CountryFlag.fromCountryCode(
                            widget.trip.city.country!.countryCode,
                            height: 18,
                            width: 24,
                            shape: const Circle(),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.trip.city.country!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            if (_averageRating == 0) {
                              return const Icon(
                                Icons.star_border,
                                color: Colors.amber,
                                size: 24,
                              );
                            } else if (index + 1 <= _averageRating) {
                              return const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 24,
                              );
                            } else if (index < _averageRating) {
                              return const Icon(
                                Icons.star_half,
                                color: Colors.amber,
                                size: 24,
                              );
                            } else {
                              return const Icon(
                                Icons.star_border,
                                color: Colors.amber,
                                size: 24,
                              );
                            }
                          }),
                          const SizedBox(width: 8),
                          Text(
                            _averageRating == 0
                                ? "No reviews yet"
                                : "$_averageRating",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: _tripReviews.map((review) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  review.user.username,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "${review.createdAt.toLocal().day}/${review.createdAt.toLocal().month}/${review.createdAt.toLocal().year}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => _deleteReview(review),
                                      child: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < review.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 18,
                                );
                              }),
                            ),
                            const SizedBox(height: 4),
                            if (review.comment != null &&
                                review.comment!.isNotEmpty)
                              Text(
                                review.comment!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
