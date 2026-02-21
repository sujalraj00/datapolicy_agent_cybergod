import 'package:flutter/material.dart';
import '../models/summary.dart';
import '../models/violation.dart';
import '../services/api_service.dart';

class ApiProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  SummaryDashboard? _summary;
  SummaryDashboard? get summary => _summary;

  List<Violation> _violations = [];
  List<Violation> get violations => _violations;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _scanStatusText = '';
  String get scanStatusText => _scanStatusText;

  Future<void> fetchSummary() async {
    _isLoading = true;
    notifyListeners();

    _summary = await _apiService.getSummary();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchViolations() async {
    _isLoading = true;
    notifyListeners();

    _violations = await _apiService.getViolations();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> triggerScan() async {
    _isLoading = true;
    _scanStatusText = 'Starting scan...';
    notifyListeners();

    String? logId = await _apiService.triggerScan();

    if (logId != null) {
      _scanStatusText = 'Scan is running...';
      notifyListeners();

      bool isComplete = false;
      bool success = false;
      final deadline = DateTime.now().add(const Duration(minutes: 10));

      while (!isComplete && DateTime.now().isBefore(deadline)) {
        await Future.delayed(const Duration(seconds: 5));
        String? status = await _apiService.checkScanStatus(logId);

        if (status == 'success') {
          isComplete = true;
          success = true;
        } else if (status == 'failed' || status == null) {
          isComplete = true;
        }
      }

      if (success) {
        _scanStatusText = 'Fetching results...';
        notifyListeners();
        await fetchSummary();
        await fetchViolations();
      }

      _isLoading = false;
      _scanStatusText = '';
      notifyListeners();
      return success;
    } else {
      _isLoading = false;
      _scanStatusText = '';
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadDataset(String filePath) async {
    _isLoading = true;
    _scanStatusText = 'Uploading dataset...';
    notifyListeners();
    final result = await _apiService.uploadTransactionDataset(filePath);
    _isLoading = false;
    _scanStatusText = '';
    notifyListeners();
    return result;
  }

  Future<bool> uploadPolicy(
    String filePath,
    String policyName,
    String description,
  ) async {
    _isLoading = true;
    _scanStatusText = 'Uploading policy...';
    notifyListeners();
    final result = await _apiService.uploadPolicy(
      filePath,
      policyName,
      description,
    );
    _isLoading = false;
    _scanStatusText = '';
    notifyListeners();
    return result;
  }

  Future<bool> reviewViolation(String id, String label) async {
    bool success = await _apiService.reviewViolation(id, label);
    if (success) {
      // Update local state without re-fetching everything
      final index = _violations.indexWhere((v) => v.id == id);
      if (index != -1) {
        final old = _violations[index];
        _violations[index] = Violation(
          id: old.id,
          title: old.title,
          description: old.description,
          severity: old.severity,
          status: 'reviewed',
          label: label,
          ruleViolated: old.ruleViolated,
        );
        notifyListeners();
      }
      // Depending on the backend we might need to refresh summary
      fetchSummary();
    }
    return success;
  }
}
