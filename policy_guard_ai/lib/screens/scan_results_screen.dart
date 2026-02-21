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
                Expanded(
                  child: Text(
                    violation.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    violation.severity.toUpperCase(),
                    style: TextStyle(
                      color: severityColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              violation.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600),
            ),
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
                Text(
                  violation.status,
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
}
