import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hirecraft/main.dart';

void main() {
  testWidgets('HireCraft app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MyApp());

    // Verify that the app loads without errors
    // The splash screen should be the first thing displayed
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App has correct title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify the app title
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.title, 'HireCraft');
  });
}
