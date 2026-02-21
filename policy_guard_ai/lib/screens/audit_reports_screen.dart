import 'package:flutter/material.dart';

class AuditReportsScreen extends StatelessWidget {
  const AuditReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compliance Audit Reports')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generate reports for internal audits or regulator submission.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 24),
            _buildReportCard(
              context,
              title: 'Monthly Compliance Summary',
              date: 'Feb 2026',
              icon: Icons.calendar_month,
            ),
            const SizedBox(height: 12),
            _buildReportCard(
              context,
              title: 'Q4 2025 Audit Log',
              date: 'Dec 2025',
              icon: Icons.insert_drive_file,
            ),
            const SizedBox(height: 12),
            _buildReportCard(
              context,
              title: 'High-Risk Violations Report',
              date: 'Jan 2026',
              icon: Icons.warning_amber_rounded,
              color: Colors.red,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Report generation started...'),
                    ),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text(
                  'Generate New Report',
                  style: TextStyle(fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required String date,
    required IconData icon,
    Color color = Colors.blue,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.blue),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading report...')),
              );
            },
          ),
        ],
      ),
    );
  }
}
