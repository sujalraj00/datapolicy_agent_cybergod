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

    setState(() {
      _policyFileName = fileName;
      _uploading = true;
    });

    final apiProvider = context.read<ApiProvider>();
    final success = await apiProvider.uploadPolicy(filePath);

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
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 64,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Dataset Ready!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Now upload a compliance policy document so PolicyGuard AI knows which rules to enforce.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // Policy upload card
              GestureDetector(
                onTap: _uploading ? null : () => _pickAndUploadPolicy(context),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _policyFileName != null
                        ? Colors.green.withOpacity(0.05)
                        : Colors.white,
                    border: Border.all(
                      color: _policyFileName != null
                          ? Colors.green
                          : primary.withOpacity(0.2),
                      width: _policyFileName != null ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (_policyFileName == null)
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
                          color: _policyFileName != null
                              ? Colors.green.withOpacity(0.1)
                              : primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _policyFileName != null
                              ? Icons.check_circle_rounded
                              : Icons.description_rounded,
                          size: 28,
                          color: _policyFileName != null
                              ? Colors.green
                              : primary,
                        ),
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
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _policyFileName != null
                                  ? '✓ $_policyFileName'
                                  : 'PDF, TXT, or CSV',
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
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      else
                        Icon(
                          Icons.chevron_right_rounded,
                          color: _policyFileName != null
                              ? Colors.green
                              : Colors.black38,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Info Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  border: Border.all(color: Colors.blue.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 24,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'AI will extract rules from your policy and flag violations automatically.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // CTA Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (_policyFileName != null && !_uploading)
                      BoxShadow(
                        color: primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _policyFileName != null && !_uploading
                      ? () => context.go('/dashboard/empty')
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
