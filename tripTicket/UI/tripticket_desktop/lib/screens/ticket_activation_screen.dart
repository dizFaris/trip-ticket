import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tripticket_desktop/app_colors.dart';
import 'package:tripticket_desktop/providers/purchase_provider.dart';
import 'package:tripticket_desktop/screens/master_screen.dart';
import 'package:tripticket_desktop/screens/pdf_view_screen.dart';
import 'package:tripticket_desktop/screens/trips_screen.dart';

class TicketActivationScreen extends StatefulWidget {
  const TicketActivationScreen({super.key});

  @override
  State<TicketActivationScreen> createState() => _TicketActivationScreenState();
}

class _TicketActivationScreenState extends State<TicketActivationScreen> {
  final TextEditingController _purchaseIdController = TextEditingController();
  final PurchaseProvider _purchaseProvider = PurchaseProvider();

  bool _isButtonEnabled = false;
  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;
  int? purchaseId;

  @override
  void initState() {
    super.initState();
    _purchaseIdController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _isButtonEnabled = _purchaseIdController.text.trim().isNotEmpty;
    });
  }

  Future<void> getTicketsPdf() async {
    setState(() {
      _isLoading = true;
      _successMessage = null;
    });

    try {
      final (bytes, fileName) = await _purchaseProvider.getTicketsPdf(
        purchaseId!,
      );

      setState(() {
        _isLoading = false;
        _errorMessage = null;
        purchaseId = null;
      });

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PdfViewerPage(pdfBytes: bytes, fileName: fileName),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _purchaseIdController.removeListener(_onTextChanged);
    _purchaseIdController.dispose();
    super.dispose();
  }

  void _completePurchase(int id) async {
    setState(() {
      _isLoading = true;
      _successMessage = null;
      _errorMessage = null;
    });

    try {
      await _purchaseProvider.completePurchase(id);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _successMessage = "Purchase completed successfully!";
        _purchaseIdController.text = '';
        purchaseId = id;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
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
                    masterScreenKey.currentState?.navigateTo(TripsScreen()),
              ),
            ),
            SizedBox(width: 12),
            Text(
              "Complete purchase",
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter Purchase ID',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: TextFormField(
                      controller: _purchaseIdController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        hintText: 'ID',
                        prefixIcon: Icon(Icons.confirmation_number, size: 20),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: AppColors.primaryGray,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  height: 46,
                  width: 160,
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled
                        ? () {
                            final id = int.tryParse(
                              _purchaseIdController.text.trim(),
                            );
                            if (id != null) {
                              _completePurchase(id);
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      "Activate ticket",
                      style: TextStyle(
                        color: AppColors.primaryYellow,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),

            if (_successMessage != null)
              Row(
                children: [
                  Text(
                    _successMessage!,
                    style: TextStyle(
                      color: Colors.green[800],
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 32,
                    width: 32,
                    child: ElevatedButton(
                      onPressed: getTicketsPdf,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(
                        Icons.description,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.red[800],
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
