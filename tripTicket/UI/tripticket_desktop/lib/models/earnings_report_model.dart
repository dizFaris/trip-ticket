import 'package:tripticket_desktop/models/earnings_entry_model.dart';

class EarningsReport {
  final double total;
  final List<EarningsEntry> data;

  EarningsReport({required this.total, required this.data});

  factory EarningsReport.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List<dynamic>;
    return EarningsReport(
      total: (json['total'] as num).toDouble(),
      data: dataList
          .map((e) => EarningsEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'total': total, 'data': data.map((e) => e.toJson()).toList()};
  }
}
