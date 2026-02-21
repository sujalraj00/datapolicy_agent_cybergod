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
                const SizedBox(height: 24),
                Text(
                  'AI Explanation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildReasoningCard(violation.description),
                const SizedBox(height: 24),
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
                const SizedBox(height: 40),
                if (violation.status != 'reviewed') ...[
                  Text(
                    'Human Review Action',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _reviewViolation(
                            context,
                            apiProvider,
                            violation.id,
                            'false_positive',
                          ),
                          icon: const Icon(Icons.close, color: Colors.red),
                          label: const Text(
                            'False Pos',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _reviewViolation(
                            context,
                            apiProvider,
                            violation.id,
                            'true_positive',
                          ),
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text('True Pos'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.verified,
                          color: Colors.green,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Reviewed as ${violation.label?.replaceAll('_', ' ').toUpperCase()}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

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

  Future<void> _reviewViolation(
    BuildContext context,
    ApiProvider provider,
    String id,
    String label,
  ) async {
    bool success = await provider.reviewViolation(id, label);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Violation reviewed successfully.')),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to review violation.')),
      );
    }
  }
}
