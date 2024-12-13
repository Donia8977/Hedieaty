import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/ui/Sign_up.dart';

void main() {

  setUpAll(() async {

    await Firebase.initializeApp();
  });
  group('Sign_up Page Tests', () {
    testWidgets('Sign_up page elements are displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Sign_up(),
        ),
      );


      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets('Navigates back to sign-in page on "Sign in" button tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Sign_up(),
          routes: {
            '/sign_in': (context) => Scaffold(body: Center(child: Text('Sign In Page'))),
          },
        ),
      );

      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Sign In Page'), findsOneWidget);

    });
  });
}

