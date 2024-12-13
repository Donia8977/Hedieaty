// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:hedieaty/main.dart';
// import 'package:hedieaty/ui/Sign_in.dart';
// import 'package:hedieaty/ui/Sign_up.dart';
// import 'test_helpers.dart';
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

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:hedieaty/main.dart'; // Import your main app file
// import 'package:hedieaty/ui/EventListPage.dart';
// import 'package:mockito/mockito.dart';
// import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
// import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
//
// void main() {
//   // Mock Firebase Auth and Firestore
//   final mockAuth = MockFirebaseAuth();
//   final mockFirestore = MockFirestoreInstance();
//
//   setUp(() async {
//     // Ensure Firebase is initialized
//     TestWidgetsFlutterBinding.ensureInitialized();
//   });
//
//   group('HomePage Integration Tests', () {
//     testWidgets('displays "Create Your Own Event/List" button',
//             (WidgetTester tester) async {
//           await tester.pumpWidget(
//             MaterialApp(
//               home: HomePage(),
//             ),
//           );
//
//           // Verify the button is displayed
//           expect(find.text('Create Your Own Event/List'), findsOneWidget);
//         });
//
//     testWidgets('displays animation when no friends are present',
//             (WidgetTester tester) async {
//           await tester.pumpWidget(
//             MaterialApp(
//               home: HomePage(),
//             ),
//           );
//
//           // Verify the Lottie animation is displayed
//           expect(find.byType(Lottie), findsOneWidget);
//
//           // Verify the text for no friends is displayed
//           expect(
//               find.text("No friends found. Add a friend to get started!"),
//               findsOneWidget);
//         });
//
//     testWidgets('navigates to EventListPage on button tap',
//             (WidgetTester tester) async {
//           await tester.pumpWidget(
//             MaterialApp(
//               home: HomePage(),
//               routes: {
//                 '/eventList': (context) => EventListPage(),
//               },
//             ),
//           );
//
//           // Tap the "Create Your Own Event/List" button
//           await tester.tap(find.text('Create Your Own Event/List'));
//           await tester.pumpAndSettle();
//
//           // Verify navigation to EventListPage
//           expect(find.byType(EventListPage), findsOneWidget);
//         });
//
//     testWidgets('FloatingActionButton opens friend add dialog',
//             (WidgetTester tester) async {
//           await tester.pumpWidget(
//             MaterialApp(
//               home: HomePage(),
//             ),
//           );
//
//           // Tap the FloatingActionButton
//           await tester.tap(find.byType(FloatingActionButton));
//           await tester.pumpAndSettle();
//
//           // Verify the dialog is displayed
//           expect(find.text('Add Friend'), findsOneWidget);
//
//           // Verify options in the dialog
//           expect(find.text('Add Manually'), findsOneWidget);
//           expect(find.text('Select from Contacts'), findsOneWidget);
//         });
//   });
// }


// import 'package:flutter_test/flutter_test.dart';
// import 'package:integration_test/integration_test.dart';
// import 'package:hedieaty/main.dart' as app;
// import 'package:flutter/material.dart';
//
// void main() {
//   IntegrationTestWidgetsFlutterBinding.ensureInitialized();
//
//   group('Hedieaty App Integration Tests', () {
//     testWidgets('Verify Home Page Loads', (WidgetTester tester) async {
//       // Start the app
//       app.main();
//       await tester.pumpAndSettle();
//
//       // Verify the title
//       expect(find.text("Hedieaty"), findsOneWidget);
//
//       // Verify the loading spinner appears initially
//       expect(find.byType(CircularProgressIndicator), findsNothing);
//     });
//
//     testWidgets('Navigate to Profile Page and Back', (WidgetTester tester) async {
//       // Start the app
//       app.main();
//       await tester.pumpAndSettle();
//
//       // Open the popup menu and navigate to Profile
//       await tester.tap(find.byIcon(Icons.menu));
//       await tester.pumpAndSettle();
//       await tester.tap(find.text('Profile'));
//       await tester.pumpAndSettle();
//
//       // Verify profile page loaded
//       expect(find.text('Profile Page'), findsOneWidget);
//
//       // Navigate back
//       await tester.tap(find.byIcon(Icons.arrow_back));
//       await tester.pumpAndSettle();
//
//       // Verify home page is visible again
//       expect(find.text("Hedieaty"), findsOneWidget);
//     });
//
//     testWidgets('Add a friend manually', (WidgetTester tester) async {
//       // Start the app
//       app.main();
//       await tester.pumpAndSettle();
//
//       // Tap the Floating Action Button to add a friend
//       await tester.tap(find.byIcon(Icons.person_add));
//       await tester.pumpAndSettle();
//
//       // Select "Add Manually"
//       await tester.tap(find.text("Add Manually"));
//       await tester.pumpAndSettle();
//
//       // Fill in the friend details
//       await tester.enterText(find.bySemanticsLabel("Name"), "John Doe");
//       await tester.enterText(find.bySemanticsLabel("Phone Number"), "1234567890");
//       await tester.tap(find.text("Add"));
//       await tester.pumpAndSettle();
//
//       // Verify the friend appears in the list
//       expect(find.text("John Doe"), findsOneWidget);
//     });
//
//     testWidgets('Search for a friend', (WidgetTester tester) async {
//       // Start the app
//       app.main();
//       await tester.pumpAndSettle();
//
//       // Tap the search icon
//       await tester.tap(find.byIcon(Icons.search));
//       await tester.pumpAndSettle();
//
//       // Enter the search query
//       await tester.enterText(find.byType(TextField), "John");
//       await tester.pumpAndSettle();
//
//       // Verify the filtered list contains the friend
//       expect(find.text("John Doe"), findsOneWidget);
//     });
//   });
// }

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hedieaty/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Hedieaty Integration Tests', () {
    testWidgets('Verify Home Page Loads', (WidgetTester tester) async {

      app.main();
      await tester.pumpAndSettle();

      expect(find.text("Hedieaty"), findsOneWidget);


      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Navigate to Profile Page and Back', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Profile Page'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text("Hedieaty"), findsOneWidget);
    });

    testWidgets('Add a friend manually', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.person_add));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Add Manually"));
      await tester.pumpAndSettle();

      await tester.enterText(find.bySemanticsLabel("Name"), "John Doe");
      await tester.enterText(find.bySemanticsLabel("Phone Number"), "1234567890");
      await tester.tap(find.text("Add"));
      await tester.pumpAndSettle();

      expect(find.text("John Doe"), findsOneWidget);
    });
  });
}
