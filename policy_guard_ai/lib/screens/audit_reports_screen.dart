import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/api_provider.dart';

class AuditReportsScreen extends StatefulWidget {
  const AuditReportsScreen({super.key});

  @override
  State<AuditReportsScreen> createState() => _AuditReportsScreenState();
}

class _AuditReportsScreenState extends State<AuditReportsScreen> {
  DateTimeRange? _selectedRange;

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
            // ── Date Range Picker ───────────────────────────────────
            _buildDateRangeSelector(context),
            const SizedBox(height: 24),
            // ── Static report cards (for display) ──────────────────
            _buildReportCard(
              context,
              title: 'Full Audit Report',
              subtitle: 'All violations in the selected date range',
              icon: Icons.insert_drive_file,
              color: Colors.blue,
              onDownload: _downloadReport,
            ),
            const SizedBox(height: 12),
            _buildReportCard(
              context,
              title: 'High-Risk Violations',
              subtitle: 'Confirmed laundering cases only',
              icon: Icons.warning_amber_rounded,
              color: Colors.red,
              onDownload: _downloadReport,
            ),
            const SizedBox(height: 12),
            _buildReportCard(
              context,
              title: 'False Positive Log',
              subtitle: 'AI-excluded patterns after human feedback',
              icon: Icons.auto_fix_high,
              color: Colors.green,
              onDownload: _downloadReport,
            ),
            const Spacer(),
            // ── Primary CTA ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _downloadReport,
                icon: const Icon(Icons.download),
                label: const Text(
                  'Download PDF Report',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
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

  Widget _buildDateRangeSelector(BuildContext context) {
    final start = _selectedRange?.start;
    final end = _selectedRange?.end;
    final label = (start != null && end != null)
        ? '${_formatDate(start)}  →  ${_formatDate(end)}'
        : 'All-time (no filter)';

    return InkWell(
      onTap: () => _pickDateRange(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range, color: Colors.blueAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date Range',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedRange != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () => setState(() => _selectedRange = null),
                tooltip: 'Clear filter',
              )
            else
              const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    Color color = Colors.blue,
    required VoidCallback onDownload,
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
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.download_rounded, color: color),
            tooltip: 'Download PDF',
            onPressed: onDownload,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange:
          _selectedRange ??
          DateTimeRange(start: DateTime(now.year, now.month - 1, 1), end: now),
    );
    if (picked != null) {
      setState(() => _selectedRange = picked);
    }
  }

  Future<void> _downloadReport() async {
    final provider = context.read<ApiProvider>();
    final start = _selectedRange?.start;
    final end = _selectedRange?.end;

    final reportUrl = provider.getReportUrl(
      start: start != null ? _formatDate(start) : null,
      end: end != null ? _formatDate(end) : null,
    );

    final uri = Uri.parse(reportUrl);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open report. Is the backend running?'),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
