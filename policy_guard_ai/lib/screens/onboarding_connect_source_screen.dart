import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/api_provider.dart';

class OnboardingConnectSourceScreen extends StatefulWidget {
  const OnboardingConnectSourceScreen({super.key});

  @override
  State<OnboardingConnectSourceScreen> createState() =>
      _OnboardingConnectSourceScreenState();
}

class _OnboardingConnectSourceScreenState
    extends State<OnboardingConnectSourceScreen> {
  String? _csvFileName;
  bool _uploading = false;

  Future<void> _pickAndUploadCSV(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.single.path == null) return;

    final filePath = result.files.single.path!;
    final fileName = result.files.single.name;

    setState(() {
      _csvFileName = fileName;
      _uploading = true;
    });

    final apiProvider = context.read<ApiProvider>();
    final success = await apiProvider.uploadDataset(filePath);

    setState(() => _uploading = false);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ "$fileName" uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() => _csvFileName = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Upload failed. Check your connection.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Connect Data Source',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Data Source',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Upload your transaction database or connect via API to start monitoring for compliance violations.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // CSV Upload Card
            _FileUploadCard(
              icon: Icons.table_chart_rounded,
              title: 'Upload Transaction CSV',
              subtitle: _csvFileName != null
                  ? '✓ $_csvFileName'
                  : 'IBM AML format (timestamp, amount…)',
              isUploaded: _csvFileName != null,
              isLoading: _uploading,
              onTap: _uploading ? null : () => _pickAndUploadCSV(context),
            ),
            const SizedBox(height: 16),
            _FileUploadCard(
              icon: Icons.api_rounded,
              title: 'Connect via API',
              subtitle: 'Coming soon for real-time monitoring',
              isUploaded: false,
              isLoading: false,
              onTap: null,
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (_csvFileName != null && !_uploading)
                    BoxShadow(
                      color: primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _csvFileName != null && !_uploading
                    ? () => context.go('/onboarding/summary')
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileUploadCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isUploaded;
  final bool isLoading;
  final VoidCallback? onTap;

  const _FileUploadCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isUploaded,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final disabled = onTap == null && !isUploaded;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isUploaded ? Colors.green.withOpacity(0.05) : Colors.white,
          border: Border.all(
            color: isUploaded
                ? Colors.green
                : (disabled ? Colors.grey.shade200 : primary.withOpacity(0.2)),
            width: isUploaded ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!disabled && !isUploaded)
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUploaded
                    ? Colors.green.withOpacity(0.1)
                    : (disabled
                          ? Colors.grey.shade100
                          : primary.withOpacity(0.1)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUploaded ? Icons.check_circle_rounded : icon,
                size: 28,
                color: isUploaded
                    ? Colors.green
                    : disabled
                    ? Colors.grey.shade400
                    : primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: disabled ? Colors.grey.shade500 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isUploaded
                          ? Colors.green.shade700
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            else if (!disabled)
              Icon(
                Icons.chevron_right_rounded,
                color: isUploaded ? Colors.green : Colors.black38,
              ),
          ],
        ),
      ),
    );
  }
}
