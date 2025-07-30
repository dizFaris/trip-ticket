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
  int selectedIndex = 0;
  DateTime? dailyStatisticDate;
  double? total;
  bool isLoading = false;
  int? selectedYear;
  int? selectedMonth;
  EarningsReport? earningsReport;

  final List<int> years = List.generate(50, (index) => 1980 + index);
  final List<int> months = List.generate(12, (index) => index + 1);

  final List<DropdownMenuItem<int>> statisticOptions = const [
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

    selectedYear = null;
    selectedMonth = null;
  }

  Future<void> _getDailyStatistic(DateTime date) async {
    setState(() {
      isLoading = true;
    });

    try {
      final dailyTotal = await _statisticsProvider.getDailyEarnings(date);
      setState(() {
        total = dailyTotal;
      });
    } catch (e) {
      setState(() {
        total = null;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _getMonthlyStatistics() async {
    setState(() {
      isLoading = true;
    });

    try {
      final report = await _statisticsProvider.getMonthlyEarnings(
        selectedYear!,
        selectedMonth!,
      );

      setState(() {
        earningsReport = report;
      });
    } catch (e) {
      setState(() {
        earningsReport = null;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _getYearlyStatistics() async {
    setState(() {
      isLoading = true;
    });

    try {
      final report = await _statisticsProvider.getYearlyEarnings(selectedYear!);

      setState(() {
        earningsReport = report;
      });
    } catch (e) {
      setState(() {
        earningsReport = null;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getDailyReportPdf() async {
    setState(() {
      isLoading = true;
    });

    try {
      final (bytes, fileName) = await _statisticsProvider.getDailyEarningsPdf(
        dailyStatisticDate!,
      );

      setState(() {
        isLoading = false;
      });

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PdfViewerPage(pdfBytes: bytes, fileName: fileName),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getMonthlyReportPdf() async {
    setState(() {
      isLoading = true;
    });

    try {
      final (bytes, fileName) = await _statisticsProvider.getMonthlyEarningsPdf(
        selectedYear!,
        selectedMonth!,
      );

      setState(() {
        isLoading = false;
      });

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PdfViewerPage(pdfBytes: bytes, fileName: fileName),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getYearlyReportPdf() async {
    setState(() {
      isLoading = true;
    });

    try {
      final (bytes, fileName) = await _statisticsProvider.getYearlyEarningsPdf(
        selectedYear!,
      );

      setState(() {
        isLoading = false;
      });

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PdfViewerPage(pdfBytes: bytes, fileName: fileName),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
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
                      value: selectedIndex,
                      items: statisticOptions,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            selectedIndex = val;
                            dailyStatisticDate = null;
                            selectedYear = null;
                            selectedMonth = null;
                            total = null;
                            earningsReport = null;
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
                  switch (selectedIndex) {
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
          initialDate: dailyStatisticDate,
          allowPastDates: true,
          placeHolder: 'Select date',
          onDateSelected: (date) {
            setState(() {
              dailyStatisticDate = date;
            });
            _getDailyStatistic(date);
          },
        ),
        SizedBox(height: 8),

        if (isLoading)
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
        else if (total != null)
          buildTotalEarningsCard(total: total!, onClick: getDailyReportPdf)
        else if (dailyStatisticDate == null)
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
              value: selectedYear,
              items: years,
              onChanged: (val) {
                setState(() {
                  selectedYear = val;
                  selectedMonth = null;
                });
              },
            ),
            const SizedBox(width: 8),
            _dropdown<int>(
              label: 'Month',
              value: selectedMonth,
              items: months,
              enabled: selectedYear != null,
              onChanged: (val) {
                if (selectedYear == null) return;
                setState(() {
                  selectedMonth = val;
                });
                _getMonthlyStatistics();
              },
            ),
          ],
        ),
        SizedBox(height: 8),

        if (isLoading)
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
        else if (selectedYear != null &&
            selectedMonth != null &&
            earningsReport!.data.isNotEmpty)
          Column(
            children: [
              if (earningsReport?.total != null)
                buildTotalEarningsCard(
                  total: earningsReport!.total,
                  onClick: getMonthlyReportPdf,
                ),
              SizedBox(height: 8),
              SimpleBarChart(data: earningsReport!.data),
            ],
          )
        else if (selectedYear == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "Select a year to see the monthly report.",
              style: TextStyle(color: Colors.grey),
            ),
          )
        else if (selectedMonth == null)
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
          value: selectedYear,
          items: years,
          onChanged: (val) {
            setState(() {
              selectedYear = val;
            });
            _getYearlyStatistics();
          },
        ),
        SizedBox(height: 8),

        if (isLoading)
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
        else if (selectedYear != null && earningsReport!.data.isNotEmpty)
          Column(
            children: [
              if (earningsReport?.total != null)
                buildTotalEarningsCard(
                  total: earningsReport!.total,
                  onClick: getYearlyReportPdf,
                ),
              SizedBox(height: 8),
              SimpleBarChart(data: earningsReport!.data),
            ],
          )
        else if (selectedYear == null)
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

  Widget buildTotalEarningsCard({
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
