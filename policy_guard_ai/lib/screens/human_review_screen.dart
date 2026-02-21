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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              ],
            ),
            const SizedBox(height: 12),
            Text(
              violation.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () =>
                        context.push('/violation-reasoning/${violation.id}'),
                    child: const Text('View AI Reasoning'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _review(
                    context,
                    provider,
                    violation.id,
                    'false_positive',
                  ),
                  tooltip: 'Mark False Positive',
                ),
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () =>
                      _review(context, provider, violation.id, 'true_positive'),
                  tooltip: 'Mark True Positive',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _review(
    BuildContext context,
    ApiProvider provider,
    String id,
    String label,
  ) async {
    bool success = await provider.reviewViolation(id, label);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update violation.')),
      );
    }
  }
}
