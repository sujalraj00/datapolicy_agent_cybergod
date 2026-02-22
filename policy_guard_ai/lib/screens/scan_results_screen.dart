import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';
import '../models/violation.dart';

class ScanResultsScreen extends StatefulWidget {
  const ScanResultsScreen({super.key});

  @override
  State<ScanResultsScreen> createState() => _ScanResultsScreenState();
}

class _ScanResultsScreenState extends State<ScanResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<ApiProvider>().violations.isEmpty) {
        context.read<ApiProvider>().fetchViolations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Violation Scan Results')),
      body: Consumer<ApiProvider>(
        builder: (context, apiProvider, child) {
          if (apiProvider.isLoading && apiProvider.violations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (apiProvider.violations.isEmpty) {
            return const Center(
              child: Text(
                'No violations detected!',
                style: TextStyle(fontSize: 18, color: Colors.green),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: apiProvider.violations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final violation = apiProvider.violations[index];
              return _buildViolationItem(context, violation);
            },
          );
        },
      ),
    );
  }

  Widget _buildViolationItem(BuildContext context, Violation violation) {
    // Severity colour
    Color severityColor;
    switch (violation.severity.toLowerCase()) {
      case 'high':
        severityColor = Colors.red;
        break;
      case 'medium':
        severityColor = Colors.orange;
        break;
      case 'low':
      default:
        severityColor = Colors.blue;
        break;
    }

    // AI Confidence band colour
    Color confidenceColor;
    String confidenceLabel;
    switch (violation.confidenceBand.toLowerCase()) {
      case 'high':
        confidenceColor = Colors.red.shade700;
        confidenceLabel = 'High Conf';
        break;
      case 'medium':
        confidenceColor = Colors.orange.shade700;
        confidenceLabel = 'Med Conf';
        break;
      case 'low':
      default:
        confidenceColor = Colors.grey.shade600;
        confidenceLabel = 'Low Conf';
        break;
    }

    return InkWell(
      onTap: () => context.push('/violation-reasoning/${violation.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title
                Expanded(
                  child: Text(
                    violation.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                // Severity badge
                _buildBadge(violation.severity.toUpperCase(), severityColor),
                const SizedBox(width: 6),
                // AI Confidence badge
                _buildBadge(confidenceLabel, confidenceColor),
              ],
            ),
            const SizedBox(height: 6),
            // Main explanation
            Text(
              violation.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            // AI confidence reasoning (subtitle)
            if (violation.confidenceReasoning != null &&
                violation.confidenceReasoning!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.psychology_outlined,
                    size: 14,
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
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.rule, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    violation.ruleViolated ?? 'General Policy Violation',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ),
                // Status + confidence percentage
                Text(
                  '${(violation.confidence * 100).toStringAsFixed(0)}% · ${violation.status}',
                  style: TextStyle(
                    color: violation.status == 'reviewed'
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
