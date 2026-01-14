import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:employee_checkin/main.dart';
import 'package:employee_checkin/providers/app_provider.dart';
import 'package:employee_checkin/screens/login_screen.dart';

void main() {
  testWidgets('App shows login screen when not authenticated',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that the login screen is shown
    expect(find.text('Employee Check-In'), findsOneWidget);
    expect(find.text('Sign in to track your attendance'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('Login screen has email and password fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify form fields
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    expect(find.byIcon(Icons.lock_outlined), findsOneWidget);
  });

  testWidgets('Login screen shows demo credentials',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify demo credentials are shown
    expect(find.text('Demo Credentials:'), findsOneWidget);
    expect(find.text('john.smith@company.com'), findsOneWidget);
  });

  testWidgets('Login form validates empty email', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap sign in without entering credentials
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    // Verify validation error
    expect(find.text('Please enter your email'), findsOneWidget);
  });
}
