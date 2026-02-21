import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/api_provider.dart';

class OnboardingSummaryScreen extends StatefulWidget {
  const OnboardingSummaryScreen({super.key});

  @override
  State<OnboardingSummaryScreen> createState() =>
      _OnboardingSummaryScreenState();
}

class _OnboardingSummaryScreenState extends State<OnboardingSummaryScreen> {
  String? _policyFileName;
  bool _uploading = false;

  Future<void> _pickAndUploadPolicy(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'csv'],
    );

    if (result == null || result.files.single.path == null) return;

    final filePath = result.files.single.path!;
    final fileName = result.files.single.name;

    // Derive policy name from filename (strip extension)
    final policyName = fileName.replaceAll(
      RegExp(r'\.(pdf|txt|csv)$', caseSensitive: false),
      '',
    );

    setState(() {
      _policyFileName = fileName;
      _uploading = true;
    });

    final apiProvider = context.read<ApiProvider>();
    final success = await apiProvider.uploadPolicy(
      filePath,
      policyName,
      'Uploaded via PolicyGuard AI',
    );

    setState(() => _uploading = false);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ "$fileName" policy uploaded!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() => _policyFileName = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Policy upload failed. Check your connection.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.check_circle, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              Text(
                'Dataset Ready!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Now upload a compliance policy document so PolicyGuard AI knows which rules to enforce.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              // Policy upload
              GestureDetector(
                onTap: _uploading ? null : () => _pickAndUploadPolicy(context),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _policyFileName != null
                          ? Colors.green
                          : Colors.grey.shade300,
                      width: _policyFileName != null ? 2 : 1,
                    ),
                    color: _policyFileName != null
                        ? Colors.green.shade50
                        : null,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _policyFileName != null
                            ? Icons.check_circle
                            : Icons.description_outlined,
                        size: 40,
                        color: _policyFileName != null ? Colors.green : primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Upload Policy Document',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _policyFileName != null
                                  ? '✓ $_policyFileName'
                                  : 'PDF, TXT, or CSV — AML rules, compliance policies…',
                              style: TextStyle(
                                fontSize: 13,
                                color: _policyFileName != null
                                    ? Colors.green.shade700
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_uploading)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        const Icon(Icons.chevron_right, color: Colors.black54),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.analytics, size: 28, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'AI will extract rules from your policy and flag violations automatically.',
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _policyFileName != null && !_uploading
                      ? () => context.go('/dashboard/empty')
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _policyFileName != null
                        ? primary
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _policyFileName != null
                        ? 'Go to Dashboard'
                        : 'Upload a policy to continue',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
