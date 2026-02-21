import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';

class DashboardEmptyScreen extends StatelessWidget {
  const DashboardEmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.dashboard_customize_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'No Scans Performed Yet',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Trigger a manual compliance scan to uncover potential policy violations in your connected database.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 240,
                child: Consumer<ApiProvider>(
                  builder: (context, apiProvider, child) {
                    return ElevatedButton(
                      onPressed: apiProvider.isLoading
                          ? null
                          : () async {
                              bool success = await apiProvider.triggerScan();
                              if (success && context.mounted) {
                                context.go('/dashboard');
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to trigger scan.'),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: apiProvider.isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                if (apiProvider.scanStatusText.isNotEmpty) ...[
                                  const SizedBox(width: 12),
                                  Text(
                                    apiProvider.scanStatusText,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ],
                            )
                          : const Text('Trigger Scan'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
