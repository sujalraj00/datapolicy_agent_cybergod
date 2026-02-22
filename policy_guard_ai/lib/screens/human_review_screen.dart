import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';
import '../models/violation.dart';

class HumanReviewScreen extends StatelessWidget {
  const HumanReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Human Review Queue')),
      body: Consumer<ApiProvider>(
        builder: (context, apiProvider, child) {
          final pendingViolations = apiProvider.violations
              .where((v) => v.status != 'reviewed')
              .toList();

          if (apiProvider.isLoading && pendingViolations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (pendingViolations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.done_all, size: 80, color: Colors.green.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'All Caught Up!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No pending violations to review.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pendingViolations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final violation = pendingViolations[index];
              return _buildReviewCard(context, apiProvider, violation);
            },
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(
    BuildContext context,
    ApiProvider provider,
    Violation violation,
  ) {
    // Confidence band colour
    Color confidenceColor;
    switch (violation.confidenceBand.toLowerCase()) {
      case 'high':
        confidenceColor = Colors.red.shade700;
        break;
      case 'medium':
        confidenceColor = Colors.orange.shade700;
        break;
      default:
        confidenceColor = Colors.grey.shade600;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────
            Row(
              children: [
                Icon(
                  Icons.report,
                  color: violation.severity.toLowerCase() == 'high'
                      ? Colors.red
                      : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    violation.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                // AI confidence badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: confidenceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: confidenceColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${(violation.confidence * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: confidenceColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // ── Explanation ─────────────────────────────
            Text(
              violation.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            // ── AI reasoning ────────────────────────────
            if (violation.confidenceReasoning != null &&
                violation.confidenceReasoning!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.psychology_outlined,
                    size: 13,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      violation.confidenceReasoning!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueAccent,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            // ── View AI Reasoning button ─────────────────
            TextButton.icon(
              onPressed: () =>
                  context.push('/violation-reasoning/${violation.id}'),
              icon: const Icon(Icons.psychology, size: 16),
              label: const Text('View Full AI Reasoning'),
            ),
            const Divider(height: 20),
            // ── HITL 3-action buttons ────────────────────
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    context: context,
                    provider: provider,
                    violation: violation,
                    action: 'confirm',
                    label: 'Confirm',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _actionButton(
                    context: context,
                    provider: provider,
                    violation: violation,
                    action: 'false_positive',
                    label: 'False +ve',
                    icon: Icons.cancel_outlined,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _actionButton(
                    context: context,
                    provider: provider,
                    violation: violation,
                    action: 'escalate',
                    label: 'Escalate',
                    icon: Icons.keyboard_double_arrow_up,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required ApiProvider provider,
    required Violation violation,
    required String action,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return OutlinedButton.icon(
      onPressed: () => _review(context, provider, violation.id, action),
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _review(
    BuildContext context,
    ApiProvider provider,
    String id,
    String action,
  ) async {
    final result = await provider.reviewViolation(id, action);

    if (!context.mounted) return;

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update violation.')),
      );
      return;
    }

    final feedbackApplied = result['feedback_applied'] == true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          feedbackApplied
              ? '✅ AI has learned and applied an exclusion rule!'
              : 'Violation marked as: $action',
        ),
        backgroundColor: feedbackApplied ? Colors.green.shade700 : null,
      ),
    );
  }
}
