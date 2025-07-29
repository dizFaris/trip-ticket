class EarningsEntry {
  final String label;
  final double value;

  EarningsEntry({required this.label, required this.value});

  factory EarningsEntry.fromJson(Map<String, dynamic> json) {
    return EarningsEntry(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'label': label, 'value': value};
  }
}
