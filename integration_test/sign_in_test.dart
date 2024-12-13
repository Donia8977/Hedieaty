import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/ui/Sign_in.dart';

void main() async{
  TestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  group('Sign_in Page Tests', () {
    testWidgets('Sign_in page elements are displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Sign_in(),
        ),
      );

      expect(find.text('Welcome to Hedieatak'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('Navigates to sign-up page on "Sign up" button tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Sign_in(),
          routes: {
            '/sign_up': (context) => Scaffold(body: Center(child: Text('Sign Up Page'))),
          },
        ),
      );

      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      expect(find.text('Sign Up Page'), findsOneWidget);
    });
  });
}
