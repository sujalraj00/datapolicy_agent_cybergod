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

  Map<String, dynamic>? _queueStatus;
  Map<String, dynamic>? get queueStatus => _queueStatus;

  // ─────────────────────────────────────────────
  // Fetch methods
  // ─────────────────────────────────────────────

  Future<void> fetchSummary() async {
    _isLoading = true;
    notifyListeners();
    _summary = await _apiService.getSummary();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchViolations({String? confidenceFilter}) async {
    _isLoading = true;
    notifyListeners();
    _violations = await _apiService.getViolations(
      confidenceFilter: confidenceFilter,
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchQueueStatus() async {
    _queueStatus = await _apiService.getQueueStatus();
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // Scan
  // ─────────────────────────────────────────────

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

  // ─────────────────────────────────────────────
  // Upload helpers
  // ─────────────────────────────────────────────

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

  // ─────────────────────────────────────────────
  // v2 HITL Review
  // ─────────────────────────────────────────────

  /// [action] must be: "confirm", "false_positive", or "escalate".
  /// Returns a result map with `feedback_applied` bool, or null on failure.
  Future<Map<String, dynamic>?> reviewViolation(
    String id,
    String action, {
    String? note,
  }) async {
    final result = await _apiService.reviewViolation(id, action, note: note);

    if (result != null && result['success'] == true) {
      final feedbackApplied = result['feedback_applied'] == true;
      final index = _violations.indexWhere((v) => v.id == id);
      if (index != -1) {
        _violations[index] = _violations[index].copyWithReview(
          status: 'reviewed',
          label: action == 'confirm' ? 'true_positive' : action,
          reviewAction: action,
          feedbackApplied: feedbackApplied,
        );
        notifyListeners();
      }
      fetchSummary();
    }

    return result;
  }

  // ─────────────────────────────────────────────
  // Report URL helper
  // ─────────────────────────────────────────────

  String getReportUrl({String? start, String? end}) {
    return _apiService.getReportUrl(start: start, end: end);
  }
}
