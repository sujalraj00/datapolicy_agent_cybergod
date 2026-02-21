class Violation {
  final String id;
  final String title;
  final String description;
  final String severity; // High, Medium, Low
  final String status; // Pending, Reviewed
  final String? label; // true_positive, false_positive
  final String? ruleViolated;

  Violation({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    this.label,
    this.ruleViolated,
  });

  factory Violation.fromJson(Map<String, dynamic> json) {
    return Violation(
      id: json['id']?.toString() ?? '',
      title: json['rule_name'] ?? json['title'] ?? 'Title',
      description: json['explanation'] ?? json['description'] ?? 'Description',
      severity: json['severity'] ?? 'Medium',
      status: json['status'] ?? 'Pending',
      label: json['label'],
      ruleViolated:
          json['rule_name'] ?? json['rule_violated'] ?? json['ruleViolated'],
    );
  }
}
