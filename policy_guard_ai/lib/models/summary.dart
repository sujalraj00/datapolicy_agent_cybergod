class SummaryDashboard {
  final int total;
  final int highSeverity;
  final int mediumSeverity;
  final int lowSeverity;

  SummaryDashboard({
    required this.total,
    required this.highSeverity,
    required this.mediumSeverity,
    required this.lowSeverity,
  });

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  factory SummaryDashboard.fromJson(Map<String, dynamic> json) {
    // Handling dynamic structure based on typical backend response
    var summary = json['summary'] ?? json;
    return SummaryDashboard(
      total: _parseInt(summary['total']),
      highSeverity: _parseInt(
        summary['high_severity'] ?? summary['highSeverity'],
      ),
      mediumSeverity: _parseInt(
        summary['medium_severity'] ?? summary['mediumSeverity'],
      ),
      lowSeverity: _parseInt(summary['low_severity'] ?? summary['lowSeverity']),
    );
  }
}
