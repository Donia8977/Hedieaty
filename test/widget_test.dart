// // // This is a basic Flutter widget test.
// // //
// // // To perform an interaction with a widget in your test, use the WidgetTester
// // // utility in the flutter_test package. For example, you can send tap and scroll
// // // gestures. You can also use WidgetTester to find child widgets in the widget
// // // tree, read text, and verify that the values of widget properties are correct.
// //
// // import 'package:flutter/material.dart';
// // import 'package:flutter_test/flutter_test.dart';
// //
// // import 'package:hedieaty/main.dart';
// //
// // void main() {
// //   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
// //     // Build our app and trigger a frame.
// //     await tester.pumpWidget(HomePage());
// //
// //     // Verify that our counter starts at 0.
// //     expect(find.text('0'), findsOneWidget);
// //     expect(find.text('1'), findsNothing);
// //
// //     // Tap the '+' icon and trigger a frame.
// //     await tester.tap(find.byIcon(Icons.add));
// //     await tester.pump();
// //
// //     // Verify that our counter has incremented.
// //     expect(find.text('0'), findsNothing);
// //     expect(find.text('1'), findsOneWidget);
// //   });
// // }
//
//
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:hedieaty/main.dart';
// import 'package:hedieaty/ui/Sign_in.dart';
// import 'package:hedieaty/ui/Sign_up.dart';
// import '../integration_test/test_helpers.dart';
//
//
// void main() {
//   group('Main App Integration Tests', () {
//     testWidgets('Initial screen is Sign_in', (WidgetTester tester) async {
//       // Build the app with the mock setup
//       await tester.pumpWidget(await createTestApp());
//
//       // Verify Sign_in page is displayed
//       expect(find.byType(Sign_in), findsOneWidget);
//       expect(find.text('Welcome to Hedieatak'), findsOneWidget);
//     });
//
//     testWidgets('Navigation to Sign_up page works', (WidgetTester tester) async {
//       await tester.pumpWidget(await createTestApp());
//
//       // Tap "Sign up" button
//       await tester.tap(find.text('Sign up'));
//       await tester.pumpAndSettle();
//
//       // Verify navigation to Sign_up page
//       expect(find.byType(Sign_up), findsOneWidget);
//     });
//
//     testWidgets('HomePage displays loading animation initially', (WidgetTester tester) async {
//       await tester.pumpWidget(await createTestApp());
//
//       // Navigate to HomePage (mock user is logged in)
//       await tester.tap(find.byIcon(Icons.person_add));
//       await tester.pumpAndSettle();
//
//       // Verify loading animation is displayed
//       expect(find.byType(Center), findsOneWidget);
//       expect(find.byType(CircularProgressIndicator), findsNothing); // Adjust based on your animation.
//     });
//
//     testWidgets('Add Friend dialog works', (WidgetTester tester) async {
//       await tester.pumpWidget(await createTestApp());
//
//       // Tap on the FAB to add a friend
//       await tester.tap(find.byType(FloatingActionButton));
//       await tester.pumpAndSettle();
//
//       // Verify dialog is displayed
//       expect(find.text('Add Friend'), findsOneWidget);
//       expect(find.text('Add Manually'), findsOneWidget);
//
//       // Simulate adding a friend
//       await tester.tap(find.text('Add Manually'));
//       await tester.pumpAndSettle();
//
//       // Enter friend details
//       await tester.enterText(find.byType(TextField).first, 'Test Friend');
//       await tester.enterText(find.byType(TextField).last, '1234567890');
//
//       // Confirm friend addition
//       await tester.tap(find.text('Add'));
//       await tester.pumpAndSettle();
//
//       // Verify friend appears in the list
//       expect(find.text('Test Friend'), findsOneWidget);
//     });
//   });
// }
