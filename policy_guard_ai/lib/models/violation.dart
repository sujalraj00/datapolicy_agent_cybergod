class Violation {
  final String id;
  final String title;
  final String description;
  final String severity; // high, medium, low
  final String status; // pending, reviewed
  final String? label; // true_positive, false_positive
  final String? ruleViolated;
  final String? transactionId;

  // v2 AI fields
  final double confidence; // 0.0 to 1.0
  final String confidenceBand; // "high", "medium", "low"
  final String? confidenceReasoning;
  final String? reviewAction; // "confirm", "false_positive", "escalate"
  final bool feedbackApplied;

  Violation({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    this.label,
    this.ruleViolated,
    this.transactionId,
    this.confidence = 0.5,
    this.confidenceBand = 'medium',
    this.confidenceReasoning,
    this.reviewAction,
    this.feedbackApplied = false,
  });

  factory Violation.fromJson(Map<String, dynamic> json) {
    return Violation(
      id: json['id']?.toString() ?? '',
      title: json['rule_name'] ?? json['title'] ?? 'Unknown Rule',
      description: json['explanation'] ?? json['description'] ?? '',
      severity: json['severity'] ?? 'medium',
      status: json['status'] ?? 'pending',
      label: json['label'],
      ruleViolated:
          json['rule_name'] ?? json['rule_violated'] ?? json['ruleViolated'],
      transactionId: json['transaction_id'],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      confidenceBand: json['confidence_band'] ?? 'medium',
      confidenceReasoning: json['confidence_reasoning'],
      reviewAction: json['review_action'],
      feedbackApplied: json['feedback_applied'] == true,
    );
  }

  /// Returns a copy of this violation with the updated review fields.
  Violation copyWithReview({
    required String status,
    required String label,
    required String reviewAction,
    bool feedbackApplied = false,
  }) {
    return Violation(
      id: id,
      title: title,
      description: description,
      severity: severity,
      status: status,
      label: label,
      ruleViolated: ruleViolated,
      transactionId: transactionId,
      confidence: confidence,
      confidenceBand: confidenceBand,
      confidenceReasoning: confidenceReasoning,
      reviewAction: reviewAction,
      feedbackApplied: feedbackApplied,
    );
  }
}
