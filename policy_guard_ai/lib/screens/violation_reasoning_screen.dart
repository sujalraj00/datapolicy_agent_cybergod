import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';
import '../models/violation.dart';

class ViolationReasoningScreen extends StatelessWidget {
  final String violationId;

  const ViolationReasoningScreen({super.key, required this.violationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Reasoning')),
      body: Consumer<ApiProvider>(
        builder: (context, apiProvider, child) {
          final violation = apiProvider.violations.firstWhere(
            (v) => v.id == violationId,
            orElse: () => Violation(
              id: '',
              title: 'Unknown Violation',
              description: 'Could not find details for this violation.',
              severity: 'Low',
              status: 'Pending',
            ),
          );

          if (violation.id.isEmpty) {
            return const Center(child: Text('Violation not found.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, violation),
                const SizedBox(height: 20),
                // ── Confidence Score Card ───────────────────────────
                _buildConfidenceCard(violation),
                const SizedBox(height: 20),
                Text(
                  'AI Explanation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildReasoningCard(violation.description),
                const SizedBox(height: 20),
                Text(
                  'Rule Violated',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  violation.ruleViolated ?? 'Matches general anomaly patterns.',
                  style: const TextStyle(fontSize: 16),
                ),
                if (violation.transactionId != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Transaction ID: ${violation.transactionId}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
                const SizedBox(height: 32),
                // ── Human Review Actions ────────────────────────────
                if (violation.status != 'reviewed') ...[
                  Text(
                    'Human Review Action',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your decision will be logged and the AI will learn from it.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  _buildHITLButtons(context, apiProvider, violation),
                ] else ...[
                  _buildReviewedCard(violation),
                ],
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sub-widgets
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, Violation violation) {
    Color severityColor = violation.severity.toLowerCase() == 'high'
        ? Colors.red
        : Colors.orange;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: severityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${violation.severity.toUpperCase()} RISK',
            style: TextStyle(
              color: severityColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          violation.title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildConfidenceCard(Violation violation) {
    Color confidenceColor;
    String confidenceLabel;
    switch (violation.confidenceBand.toLowerCase()) {
      case 'high':
        confidenceColor = Colors.red.shade700;
        confidenceLabel = 'High Confidence';
        break;
      case 'medium':
        confidenceColor = Colors.orange.shade700;
        confidenceLabel = 'Medium Confidence';
        break;
      case 'low':
      default:
        confidenceColor = Colors.grey.shade600;
        confidenceLabel = 'Low Confidence';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: confidenceColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: confidenceColor.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          // Circular confidence indicator
          SizedBox(
            width: 54,
            height: 54,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: violation.confidence,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(confidenceColor),
                ),
                Text(
                  '${(violation.confidence * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: confidenceColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  confidenceLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: confidenceColor,
                    fontSize: 14,
                  ),
                ),
                if (violation.confidenceReasoning != null &&
                    violation.confidenceReasoning!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    violation.confidenceReasoning!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasoningCard(String explanation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.psychology, color: Colors.blue, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              explanation,
              style: const TextStyle(height: 1.5, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHITLButtons(
    BuildContext context,
    ApiProvider provider,
    Violation violation,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () =>
                _reviewViolation(context, provider, violation.id, 'confirm'),
            icon: const Icon(Icons.check_circle, color: Colors.white, size: 20),
            label: const Text('✅  Confirm Violation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _reviewViolation(
              context,
              provider,
              violation.id,
              'false_positive',
            ),
            icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
            label: const Text(
              '❌  Mark False Positive (AI Learns)',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () =>
                _reviewViolation(context, provider, violation.id, 'escalate'),
            icon: const Icon(
              Icons.keyboard_double_arrow_up,
              color: Colors.blueGrey,
              size: 20,
            ),
            label: const Text(
              '⏸  Escalate for Senior Review',
              style: TextStyle(color: Colors.blueGrey),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.blueGrey),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewedCard(Violation violation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.verified, color: Colors.green, size: 40),
          const SizedBox(height: 8),
          Text(
            'Reviewed as: ${(violation.reviewAction ?? violation.label ?? 'reviewed').replaceAll('_', ' ').toUpperCase()}',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (violation.feedbackApplied) ...[
            const SizedBox(height: 6),
            Text(
              '🤖 AI has applied an exclusion rule for this pattern.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.green.shade700),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _reviewViolation(
    BuildContext context,
    ApiProvider provider,
    String id,
    String action,
  ) async {
    final result = await provider.reviewViolation(id, action);

    if (!context.mounted) return;

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to review violation.')),
      );
      return;
    }

    final feedbackApplied = result['feedback_applied'] == true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          feedbackApplied
              ? '✅ AI has learned and applied an exclusion rule!'
              : 'Violation reviewed as: $action',
        ),
        backgroundColor: feedbackApplied
            ? Colors.green.shade700
            : Colors.black87,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
