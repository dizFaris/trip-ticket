import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:tripticket_mobile/app_colors.dart';
import 'package:tripticket_mobile/models/purchase_model.dart';
import 'package:tripticket_mobile/providers/auth_provider.dart';
import 'package:tripticket_mobile/providers/purchase_provider.dart';
import 'package:tripticket_mobile/screens/purchase_details_screen.dart';
import 'package:tripticket_mobile/utils/utils.dart';
import 'package:tripticket_mobile/widgets/pagination_controls.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  final PurchaseProvider _purchasesProvider = PurchaseProvider();
  List<Purchase> _purchases = [];
  bool _isLoading = true;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _getPurchases();
  }

  void _goToPreviousPage() {
    if (_currentPage <= 0) return;

    setState(() {
      _currentPage--;
    });

    _getPurchases();
  }

  void _goToNextPage() {
    if (_currentPage >= _totalPages - 1) return;

    setState(() {
      _currentPage++;
    });

    _getPurchases();
  }

  Future<void> _getPurchases() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var filter = {'UserId': AuthProvider.id!};
      var searchResult = await _purchasesProvider.get(
        filter: filter,
        page: _currentPage,
        pageSize: 10,
      );

      setState(() {
        _purchases = searchResult.result;
        _totalPages = (searchResult.count / 10).ceil();
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
          'Purchase history',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
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
          : _purchases.isEmpty
          ? Center(
              child: Text(
                'No purchases found',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _purchases.length,
                    itemBuilder: (context, index) {
                      final purchase = _purchases[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PurchaseDetailsScreen(purchase: purchase),
                              ),
                            ).then((value) {
                              _getPurchases();
                            });
                          },
                          child: Container(
                            height: 70,
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
                                children: [
                                  const Icon(
                                    Icons.confirmation_num,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          CountryFlag.fromCountryCode(
                                            purchase.trip.countryCode,
                                            height: 12,
                                            width: 18,
                                            shape: const Circle(),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${purchase.trip.city} - ",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            formatDate(purchase.createdAt),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: AppColors.primaryYellow,
                                            ),
                                          ),
                                        ],
                                      ),

                                      Row(
                                        children: [
                                          const Text(
                                            "Tickets purchased: ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            "${purchase.numberOfTickets}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: AppColors.primaryYellow,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: getStatusColor(
                                            purchase.status,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          purchase.status.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "${purchase.totalPayment} €",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: AppColors.primaryYellow,
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
