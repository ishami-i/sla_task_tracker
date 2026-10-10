import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sla_task_tracker/main.dart';
import 'package:sla_task_tracker/screens/dashboard_page.dart';

void main() {
  testWidgets('sign-in form validates required fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('valid sign-in opens the dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'john@example.com',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'password',
    );
    await tester.tap(find.text('Sign In'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Good morning,'), findsOneWidget);
  });

  testWidgets('dashboard burger menu opens navigation drawer',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardPage(userName: 'john'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsNWidgets(2));
    expect(find.text('Tasks'), findsNWidgets(2));
    expect(find.text('Sign out'), findsOneWidget);
  });
}
