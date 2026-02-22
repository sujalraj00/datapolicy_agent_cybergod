import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/api_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  // Dataset state
  String? _datasetFileName;
  bool _datasetUploading = false;
  bool _datasetSuccess = false;

  // Policy state
  String? _policyFileName;
  bool _policyUploading = false;
  bool _policySuccess = false;

  Future<void> _pickAndUploadDataset() async {
    // withData: true ensures bytes are available on web (where path is null).
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: kIsWeb,
    );

    if (result == null) return;

    final file = result.files.single;
    final ext = file.extension?.toLowerCase() ?? '';
    if (ext != 'csv') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ Please select a .csv file.'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final fileName = file.name;
    final filePath = kIsWeb ? null : file.path; // path throws on web
    final bytes = kIsWeb ? file.bytes : null; // bytes used on web

    setState(() {
      _datasetFileName = fileName;
      _datasetUploading = true;
      _datasetSuccess = false;
    });

    final apiProvider = context.read<ApiProvider>();
    final success = await apiProvider.uploadDataset(
      filePath,
      bytes: bytes,
      fileName: fileName,
    );

    setState(() {
      _datasetUploading = false;
      _datasetSuccess = success;
      if (!success) _datasetFileName = null;
    });

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '✅ Dataset "$fileName" uploaded! Old data cleared.'
              : '❌ Dataset upload failed. Check your connection.',
        ),
        backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _pickAndUploadPolicy() async {
    // withData: true ensures bytes are available on web (where path is null).
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: kIsWeb,
    );

    if (result == null) return;

    final file = result.files.single;
    final fileName = file.name;
    final ext = file.extension?.toLowerCase() ?? '';
    final filePath = kIsWeb ? null : file.path; // path throws on web
    final bytes = kIsWeb ? file.bytes : null; // bytes used on web

    if (!['pdf', 'txt', 'csv'].contains(ext)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ Please select a .pdf, .txt, or .csv file.'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _policyFileName = fileName;
      _policyUploading = true;
      _policySuccess = false;
    });

    final apiProvider = context.read<ApiProvider>();
    final success = await apiProvider.uploadPolicy(
      filePath,
      bytes: bytes,
      fileName: fileName,
    );

    setState(() {
      _policyUploading = false;
      _policySuccess = success;
      if (!success) _policyFileName = null;
    });

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '✅ Policy "$fileName" uploaded! Old rules cleared.'
              : '❌ Policy upload failed. Check your connection.',
        ),
        backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final canScan = _datasetSuccess || _policySuccess;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Upload Data',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Fresh State banner ──────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1349EC).withOpacity(0.08),
                    const Color(0xFF1349EC).withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF1349EC).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1349EC).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_delete_outlined,
                      color: Color(0xFF1349EC),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fresh State Mode',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF1349EC),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Each upload automatically clears old data so your dashboard shows results for the latest batch only.',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Dataset Section ─────────────────────────
            Text(
              'Transaction Dataset',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Upload a CSV with transaction records (IBM AML or generic format).',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            _UploadCard(
              icon: Icons.table_chart_outlined,
              title: 'Upload Transaction CSV',
              subtitle: _datasetFileName != null
                  ? '✓ $_datasetFileName'
                  : 'Supports IBM AML & generic CSV formats',
              acceptedFormats: '.csv',
              isUploaded: _datasetSuccess,
              isLoading: _datasetUploading,
              accentColor: Colors.blue.shade600,
              onTap: _datasetUploading ? null : _pickAndUploadDataset,
            ),

            const SizedBox(height: 28),

            // ── Policy Section ──────────────────────────
            Text(
              'Compliance Policy',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Upload a policy document and the AI will extract enforcement rules automatically.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            _UploadCard(
              icon: Icons.description_outlined,
              title: 'Upload Policy Document',
              subtitle: _policyFileName != null
                  ? '✓ $_policyFileName'
                  : 'AML rules, compliance policies…',
              acceptedFormats: '.pdf / .txt / .csv',
              isUploaded: _policySuccess,
              isLoading: _policyUploading,
              accentColor: Colors.purple.shade600,
              onTap: _policyUploading ? null : _pickAndUploadPolicy,
            ),

            const SizedBox(height: 36),

            // ── Run Scan Button ─────────────────────────
            if (canScan)
              Consumer<ApiProvider>(
                builder: (context, apiProvider, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: apiProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.search_rounded),
                      label: Text(
                        apiProvider.isLoading
                            ? (apiProvider.scanStatusText.isNotEmpty
                                  ? apiProvider.scanStatusText
                                  : 'Scanning…')
                            : 'Run Compliance Scan',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: apiProvider.isLoading
                          ? null
                          : () async {
                              final success = await apiProvider.triggerScan();
                              if (!context.mounted) return;
                              if (success) {
                                context.go('/dashboard');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      '❌ Scan failed. Please try again.',
                                    ),
                                    backgroundColor: Colors.red.shade700,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reusable upload card widget
// ─────────────────────────────────────────────
class _UploadCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String acceptedFormats;
  final bool isUploaded;
  final bool isLoading;
  final Color accentColor;
  final VoidCallback? onTap;

  const _UploadCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.acceptedFormats,
    required this.isUploaded,
    required this.isLoading,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUploaded ? Colors.green.shade400 : Colors.grey.shade200,
          width: isUploaded ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isUploaded ? Colors.green : accentColor).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (isUploaded ? Colors.green : accentColor)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isUploaded ? Icons.check_circle_rounded : icon,
                        color: isUploaded ? Colors.green : accentColor,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: isUploaded
                                  ? Colors.green.shade700
                                  : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isLoading)
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: accentColor,
                        ),
                      )
                    else
                      Icon(
                        isUploaded
                            ? Icons.check_rounded
                            : Icons.upload_file_rounded,
                        color: isUploaded ? Colors.green : accentColor,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Accepted: $acceptedFormats',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
