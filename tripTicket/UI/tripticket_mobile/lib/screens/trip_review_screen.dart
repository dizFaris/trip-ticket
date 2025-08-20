import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:tripticket_mobile/app_colors.dart';
import 'package:tripticket_mobile/models/trip_model.dart';
import 'package:tripticket_mobile/providers/auth_provider.dart';
import 'package:tripticket_mobile/providers/trip_review_provider.dart';

class TripReviewScreen extends StatefulWidget {
  final Trip trip;

  const TripReviewScreen({super.key, required this.trip});

  @override
  State<TripReviewScreen> createState() => _TripReviewScreenState();
}

class _TripReviewScreenState extends State<TripReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final TripReviewProvider _tripReviewProvider = TripReviewProvider();
  bool _isLoading = false;
  int _rating = 0;
  String? _ratingError;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      setState(() {
        _ratingError = "Please select a rating";
      });
      return;
    } else {
      setState(() {
        _ratingError = null;
      });
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final review = {
        "TripId": widget.trip.id,
        "UserId": AuthProvider.id,
        "Rating": _rating,
        "Comment": _commentController.text,
      };

      await _tripReviewProvider.insert(review);

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Success"),
          content: const Text("Review successfully submitted"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Ok"),
            ),
          ],
        ),
      );

      setState(() {
        _commentController.text = '';
        _rating = 0;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
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

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildStar(int index) {
    return IconButton(
      onPressed: () {
        setState(() {
          _rating = index + 1;
          _ratingError = null;
        });
      },
      icon: Icon(
        index < _rating ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 36,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Add Review',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: _isLoading
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
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Text(
                      "Rate this trip:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
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
                          Row(
                            children: [
                              CountryFlag.fromCountryCode(
                                widget.trip.city.country!.countryCode,
                                height: 18,
                                width: 24,
                                shape: const Circle(),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                widget.trip.city.country!.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(5, (index) => _buildStar(index)),
                    ),
                    if (_ratingError != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 8.0,
                          top: 0,
                          bottom: 8.0,
                        ),
                        child: Text(
                          _ratingError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        labelText: "Comment",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignLabelWithHint: true,
                      ),
                      maxLength: 300,
                      maxLines: 6,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Comment is required";
                        }
                        if (value.length < 10) {
                          return "Comment should be at least 10 characters";
                        }
                        if (value.length > 500) {
                          return "Comment cannot exceed 500 characters";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: SizedBox(
                        width: 220,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              _submitReview();
                            }
                          },
                          icon: const Icon(
                            Icons.rate_review,
                            color: AppColors.primaryYellow,
                            size: 24,
                          ),
                          label: const Text(
                            "Submit Review",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: AppColors.primaryYellow,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
