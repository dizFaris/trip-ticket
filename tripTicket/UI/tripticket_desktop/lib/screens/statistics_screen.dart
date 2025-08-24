import 'package:flutter/material.dart';
import 'package:tripticket_desktop/app_colors.dart';
import 'package:tripticket_desktop/models/earnings_report_model.dart';
import 'package:tripticket_desktop/providers/statistics_provider.dart';
import 'package:tripticket_desktop/screens/master_screen.dart';
import 'package:tripticket_desktop/screens/pdf_view_screen.dart';
import 'package:tripticket_desktop/screens/trips_screen.dart';
import 'package:tripticket_desktop/utils/utils.dart';
import 'package:tripticket_desktop/widgets/chart.dart';
import 'package:tripticket_desktop/widgets/date_picker.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StatisticsProvider _statisticsProvider = StatisticsProvider();
  int _selectedIndex = 0;
  DateTime? _dailyStatisticDate;
  double? _total;
  bool _isLoading = false;
  int? _selectedYear;
  int? _selectedMonth;
  EarningsReport? _earningsReport;

  final List<int> _years = List.generate(50, (index) => 2023 + index);
  final List<int> _months = List.generate(12, (index) => index + 1);

  final List<DropdownMenuItem<int>> _statisticOptions = const [
    DropdownMenuItem(
      value: 0,
      child: Text('Daily Statistic', style: TextStyle(fontSize: 16)),
    ),
    DropdownMenuItem(
      value: 1,
      child: Text('Monthly Statistic', style: TextStyle(fontSize: 16)),
    ),
    DropdownMenuItem(
      value: 2,
      child: Text('Yearly Statistic', style: TextStyle(fontSize: 16)),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _selectedYear = null;
    _selectedMonth = null;
  }

  Future<void> _getDailyStatistic(DateTime date) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dailyTotal = await _statisticsProvider.getDailyEarnings(date);
      setState(() {
        _total = dailyTotal;
      });
    } catch (e) {
      setState(() {
        _total = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getMonthlyStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final report = await _statisticsProvider.getMonthlyEarnings(
        _selectedYear!,
        _selectedMonth!,
      );

      setState(() {
        _earningsReport = report;
      });
    } catch (e) {
      setState(() {
        _earningsReport = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getYearlyStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final report = await _statisticsProvider.getYearlyEarnings(
        _selectedYear!,
      );

      setState(() {
        _earningsReport = report;
      });
    } catch (e) {
      setState(() {
        _earningsReport = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getDailyReportPdf() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final (bytes, fileName) = await _statisticsProvider.getDailyEarningsPdf(
        _dailyStatisticDate!,
      );

      setState(() {
        _isLoading = false;
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

  Future<void> _getMonthlyReportPdf() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final (bytes, fileName) = await _statisticsProvider.getMonthlyEarningsPdf(
        _selectedYear!,
        _selectedMonth!,
      );

      setState(() {
        _isLoading = false;
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

  Future<void> _getYearlyReportPdf() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final (bytes, fileName) = await _statisticsProvider.getYearlyEarningsPdf(
        _selectedYear!,
      );

      setState(() {
        _isLoading = false;
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

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    bool? enabled,
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
          fillColor: (enabled ?? true)
              ? AppColors.primaryGray
              : Colors.blueGrey[300],
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
        onChanged: (enabled ?? true) ? onChanged : null,
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
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () =>
                    masterScreenKey.currentState?.navigateTo(TripsScreen()),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Statistics",
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
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Select option",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 200,
                    child: DropdownButtonFormField<int>(
                      value: _selectedIndex,
                      items: _statisticOptions,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedIndex = val;
                            _dailyStatisticDate = null;
                            _selectedYear = null;
                            _selectedMonth = null;
                            _total = null;
                            _earningsReport = null;
                          });
                        }
                      },
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
                        hintText: 'Statistic Type',
                        hintStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
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
                ],
              ),

              const SizedBox(height: 12),
              Divider(),
              const SizedBox(height: 12),

              Builder(
                builder: (context) {
                  switch (_selectedIndex) {
                    case 0:
                      return _buildDailyStatistic();
                    case 1:
                      return _buildMonthlyStatistic();
                    case 2:
                      return _buildYearlyStatistic();
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyStatistic() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DatePickerButton(
          initialDate: _dailyStatisticDate,
          firstDate: DateTime(2025),
          allowPastDates: true,
          placeHolder: 'Select date',
          onDateSelected: (date) {
            setState(() {
              _dailyStatisticDate = date;
            });
            _getDailyStatistic(date);
          },
        ),
        SizedBox(height: 8),

        if (_isLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGreen,
                ),
              ),
            ),
          )
        else if (_total != null)
          _buildTotalEarningsCard(total: _total!, onClick: _getDailyReportPdf)
        else if (_dailyStatisticDate == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "Select a date to see the daily report.",
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "No data found for this day.",
              style: TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildMonthlyStatistic() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _dropdown<int>(
              label: 'Year',
              value: _selectedYear,
              items: _years,
              onChanged: (val) {
                setState(() {
                  _selectedYear = val;
                  _selectedMonth = null;
                });
              },
            ),
            const SizedBox(width: 8),
            _dropdown<int>(
              label: 'Month',
              value: _selectedMonth,
              items: _months,
              enabled: _selectedYear != null,
              onChanged: (val) {
                if (_selectedYear == null) return;
                setState(() {
                  _selectedMonth = val;
                });
                _getMonthlyStatistics();
              },
            ),
          ],
        ),
        SizedBox(height: 8),

        if (_isLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGreen,
                ),
              ),
            ),
          )
        else if (_selectedYear != null &&
            _selectedMonth != null &&
            _earningsReport!.data.isNotEmpty)
          Column(
            children: [
              if (_earningsReport?.total != null)
                _buildTotalEarningsCard(
                  total: _earningsReport!.total,
                  onClick: _getMonthlyReportPdf,
                ),
              SizedBox(height: 8),
              SimpleBarChart(data: _earningsReport!.data),
            ],
          )
        else if (_selectedYear == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "Select a year to see the monthly report.",
              style: TextStyle(color: Colors.grey),
            ),
          )
        else if (_selectedMonth == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "Select a month to see the report.",
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "No data found for this month.",
              style: TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildYearlyStatistic() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dropdown<int>(
          label: 'Year',
          value: _selectedYear,
          items: _years,
          onChanged: (val) {
            setState(() {
              _selectedYear = val;
            });
            _getYearlyStatistics();
          },
        ),
        SizedBox(height: 8),

        if (_isLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGreen,
                ),
              ),
            ),
          )
        else if (_selectedYear != null && _earningsReport!.data.isNotEmpty)
          Column(
            children: [
              if (_earningsReport?.total != null)
                _buildTotalEarningsCard(
                  total: _earningsReport!.total,
                  onClick: _getYearlyReportPdf,
                ),
              SizedBox(height: 8),
              SimpleBarChart(data: _earningsReport!.data),
            ],
          )
        else if (_selectedYear == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "Select a year to see the yearly report.",
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "No data found for this year.",
              style: TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildTotalEarningsCard({
    required double total,
    VoidCallback? onClick,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Text(
            'Total Earnings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(width: 8),
          Text(
            '${total.toStringAsFixed(2)} €',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(width: 16),
          SizedBox(
            height: 32,
            width: 32,
            child: ElevatedButton(
              onPressed: onClick,
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
    );
  }
}
