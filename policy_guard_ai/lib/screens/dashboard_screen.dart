import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApiProvider>().fetchSummary();
      context.read<ApiProvider>().fetchViolations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Compliance Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ApiProvider>().fetchSummary();
              context.read<ApiProvider>().fetchViolations();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Consumer<ApiProvider>(
        builder: (context, apiProvider, child) {
          if (apiProvider.isLoading && apiProvider.summary == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final summary = apiProvider.summary;

          if (summary == null) {
            return Center(
              child: ElevatedButton(
                onPressed: () => context.read<ApiProvider>().fetchSummary(),
                child: const Text('Retry'),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(summary),
                const SizedBox(height: 24),
                Text(
                  'Quick Actions',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildActionButtons(context),
                const SizedBox(height: 24),
                Text(
                  'Recent Violations',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildRecentViolations(apiProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(summary) {
    return Row(
      children: [
        Expanded(
          child: _buildCard('Total', summary.total.toString(), Colors.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCard(
            'High Risk',
            summary.highSeverity.toString(),
            Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCard(
            'Medium Risk',
            summary.mediumSeverity.toString(),
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.search, color: Colors.blue),
          title: const Text('View Scan Results'),
          trailing: const Icon(Icons.chevron_right),
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: () => context.push('/scan-results'),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.fact_check, color: Colors.purple),
          title: const Text('Human Review Queue'),
          trailing: const Icon(Icons.chevron_right),
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: () => context.push('/human-review'),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.receipt_long, color: Colors.green),
          title: const Text('Audit Reports'),
          trailing: const Icon(Icons.chevron_right),
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: () => context.push('/audit-reports'),
        ),
      ],
    );
  }

  Widget _buildRecentViolations(ApiProvider apiProvider) {
    if (apiProvider.violations.isEmpty) {
      if (apiProvider.isLoading)
        return const Center(child: CircularProgressIndicator());
      return const Text('No recent violations.');
    }

    // Limit to top 3 for dashboard
    final recent = apiProvider.violations.take(3).toList();

    return Column(
      children: recent.map((v) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(
              Icons.warning_amber_rounded,
              color: v.severity.toLowerCase() == 'high'
                  ? Colors.red
                  : Colors.orange,
            ),
            title: Text(v.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(v.status),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/violation-reasoning/${v.id}'),
          ),
        );
      }).toList(),
    );
  }
}
