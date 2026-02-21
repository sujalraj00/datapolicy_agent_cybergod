import 'package:flutter/material.dart';

class MonitoringConfigScreen extends StatefulWidget {
  const MonitoringConfigScreen({super.key});

  @override
  State<MonitoringConfigScreen> createState() => _MonitoringConfigScreenState();
}

class _MonitoringConfigScreenState extends State<MonitoringConfigScreen> {
  bool _realTimeScanning = true;
  bool _autoApproveLowRisk = false;
  bool _notifyHighRisk = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monitoring Configurations')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Scan Settings',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Real-Time Scanning'),
            subtitle: const Text(
              'Automatically scan new transactions as they arrive in the DB.',
            ),
            value: _realTimeScanning,
            onChanged: (val) => setState(() => _realTimeScanning = val),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Automation Rules',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Auto-Approve Low Risk'),
            subtitle: const Text(
              'Automatically mark low risk violations as false positives to reduce noise.',
            ),
            value: _autoApproveLowRisk,
            onChanged: (val) => setState(() => _autoApproveLowRisk = val),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Notifications',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Alert on High Risk'),
            subtitle: const Text(
              'Send push notifications when a high severity violation is detected.',
            ),
            value: _notifyHighRisk,
            onChanged: (val) => setState(() => _notifyHighRisk = val),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings saved successfully.')),
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
