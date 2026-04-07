import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:try_out/views/auth/login_page.dart';

void main() {
  testWidgets('Login page renders Google auth actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginPage(),
      ),
    );

    expect(find.text('Masuk dengan Google'), findsOneWidget);
    expect(find.text('Login dengan Google'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
