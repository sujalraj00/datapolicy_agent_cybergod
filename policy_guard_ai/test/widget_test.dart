import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:policy_guard_ai/main.dart';
import 'package:provider/provider.dart';
import 'package:policy_guard_ai/providers/api_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => ApiProvider())],
        child: const PolicyGuardApp(),
      ),
    );

    // Verify that our app starts.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
