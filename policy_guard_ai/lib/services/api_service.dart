import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/summary.dart';
import '../models/violation.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator by default if not specified in .env
  static final String baseUrl = dotenv.get(
    'API_BASE_URL',
    fallback: 'http://10.0.2.2:3000',
  );

  Future<SummaryDashboard?> getSummary() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/violations/summary'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SummaryDashboard.fromJson(data);
      }
    } catch (e) {
      print('Error fetching summary: $e');
    }
    return null;
  }

  /// Triggers a background scan. Returns the scan_log_id on success, or null.
  Future<String?> triggerScan() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/scan'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({}),
      );
      // Backend returns 200 or 202 for async scan
      if (response.statusCode == 200 || response.statusCode == 202) {
        final data = jsonDecode(response.body);
        return data['scan_log_id'];
      }
    } catch (e) {
      print('Error triggering scan: $e');
    }
    return null;
  }

  /// Polls scan status every [intervalSeconds] seconds until done.
  /// Returns true if status == 'success', false otherwise (failed/timeout).
  Future<bool> pollUntilComplete(
    String logId, {
    int intervalSeconds = 5,
    int timeoutMinutes = 10,
  }) async {
    final deadline = DateTime.now().add(Duration(minutes: timeoutMinutes));
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(Duration(seconds: intervalSeconds));
      final status = await checkScanStatus(logId);
      if (status == 'success') return true;
      if (status == 'failed') return false;
      // status == 'running' or null → keep polling
    }
    return false; // timed out
  }

  Future<String?> checkScanStatus(String logId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/scan/logs/$logId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['log']?['status'];
      }
    } catch (e) {
      print('Error checking scan status: $e');
    }
    return null;
  }

  /// Upload a transaction CSV file. Returns true on success.
  Future<bool> uploadTransactionDataset(String filePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/transactions/upload'),
      );
      request.files.add(await http.MultipartFile.fromPath('dataset', filePath));
      final response = await request.send();
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error uploading dataset: $e');
    }
    return false;
  }

  /// Upload a policy document (PDF/TXT/CSV). Returns true on success.
  Future<bool> uploadPolicy(
    String filePath,
    String policyName,
    String description,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/policy/upload'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('policy_pdf', filePath),
      );
      request.fields['policy_name'] = policyName;
      request.fields['description'] = description;
      final response = await request.send();
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error uploading policy: $e');
    }
    return false;
  }

  /// Fetch violations, optionally filtered by confidence band ("high", "medium", "low").
  Future<List<Violation>> getViolations({String? confidenceFilter}) async {
    try {
      String url = '$baseUrl/violations';
      if (confidenceFilter != null) {
        url += '?confidence=$confidenceFilter';
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((json) => Violation.fromJson(json)).toList();
        } else if (data['violations'] is List) {
          return (data['violations'] as List)
              .map((json) => Violation.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching violations: $e');
    }
    return [];
  }

  /// v2 HITL Review endpoint.
  /// [action] must be one of: "confirm", "false_positive", "escalate".
  /// Returns a map with `success`, `feedback_applied`, and `message` keys.
  Future<Map<String, dynamic>?> reviewViolation(
    String id,
    String action, {
    String? note,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/violations/$id/review'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "action": action,
          if (note != null && note.isNotEmpty) "note": note,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error reviewing violation: $e');
    }
    return null;
  }

  /// Returns the worker queue status counters.
  Future<Map<String, dynamic>?> getQueueStatus() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/scan/queue'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['queue'] as Map<String, dynamic>?;
      }
    } catch (e) {
      print('Error fetching queue status: $e');
    }
    return null;
  }

  /// Returns the URL to open the PDF audit report.
  /// Optionally pass ISO-8601 date strings: "YYYY-MM-DD".
  String getReportUrl({String? start, String? end}) {
    final params = <String, String>{};
    if (start != null) params['start'] = start;
    if (end != null) params['end'] = end;
    final uri = Uri.parse(
      '$baseUrl/scan/report',
    ).replace(queryParameters: params.isEmpty ? null : params);
    return uri.toString();
  }
}
