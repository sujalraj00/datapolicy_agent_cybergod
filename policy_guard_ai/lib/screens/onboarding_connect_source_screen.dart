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
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Connect Data Source')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload your transaction database to start monitoring for compliance violations.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            // CSV Upload Card
            _FileUploadCard(
              icon: Icons.table_chart_outlined,
              title: 'Upload Transaction CSV',
              subtitle: _csvFileName != null
                  ? '✓ $_csvFileName'
                  : 'IBM AML format (timestamp, amount, sender…)',
              isUploaded: _csvFileName != null,
              isLoading: _uploading,
              onTap: _uploading ? null : () => _pickAndUploadCSV(context),
            ),
            const SizedBox(height: 16),
            _FileUploadCard(
              icon: Icons.api_outlined,
              title: 'Connect via API',
              subtitle: 'Coming soon',
              isUploaded: false,
              isLoading: false,
              onTap: null,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _csvFileName != null && !_uploading
                    ? () => context.go('/onboarding/summary')
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
    final primary = Theme.of(context).colorScheme.primary;
    final disabled = onTap == null && !isUploaded;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isUploaded ? Colors.green : Colors.grey.shade300,
            width: isUploaded ? 2 : 1,
          ),
          color: isUploaded ? Colors.green.shade50 : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isUploaded ? Icons.check_circle : icon,
              size: 40,
              color: isUploaded
                  ? Colors.green
                  : disabled
                  ? Colors.grey
                  : primary,
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
                      fontWeight: FontWeight.bold,
                      color: disabled ? Colors.grey : Colors.black87,
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
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                Icons.chevron_right,
                color: disabled ? Colors.grey : Colors.black54,
              ),
          ],
        ),
      ),
    );
  }
}
