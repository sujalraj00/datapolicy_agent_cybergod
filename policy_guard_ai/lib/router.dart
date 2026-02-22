import 'package:go_router/go_router.dart';
import 'screens/welcome_screen.dart';
import 'screens/onboarding_connect_source_screen.dart';
import 'screens/onboarding_summary_screen.dart';
import 'screens/dashboard_empty_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/scan_results_screen.dart';
import 'screens/violation_reasoning_screen.dart';
import 'screens/human_review_screen.dart';
import 'screens/audit_reports_screen.dart';
import 'screens/monitoring_config_screen.dart';
import 'screens/upload_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
    GoRoute(
      path: '/onboarding/connect',
      builder: (context, state) => const OnboardingConnectSourceScreen(),
    ),
    GoRoute(
      path: '/onboarding/summary',
      builder: (context, state) => const OnboardingSummaryScreen(),
    ),
    GoRoute(
      path: '/dashboard/empty',
      builder: (context, state) => const DashboardEmptyScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/scan-results',
      builder: (context, state) => const ScanResultsScreen(),
    ),
    GoRoute(
      path: '/violation-reasoning/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ViolationReasoningScreen(violationId: id);
      },
    ),
    GoRoute(
      path: '/human-review',
      builder: (context, state) => const HumanReviewScreen(),
    ),
    GoRoute(
      path: '/audit-reports',
      builder: (context, state) => const AuditReportsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const MonitoringConfigScreen(),
    ),
    GoRoute(path: '/upload', builder: (context, state) => const UploadScreen()),
  ],
);
