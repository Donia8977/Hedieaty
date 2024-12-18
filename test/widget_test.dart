// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hedieaty/main.dart';
import 'package:hedieaty/ui/Sign_in.dart';
import 'package:integration_test/integration_test.dart';

void main() async{
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(HomePage());
  //
  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);
  //
  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();
  //
  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });


  // IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  //
  // await Firebase.initializeApp();
  //
  // // late MockFlutterLocalNotificationsPlugin mockNotifications;
  // //
  // // setUp(() {
  // //   mockNotifications = MockFlutterLocalNotificationsPlugin();
  // // });
  //
  //
  // testWidgets("Sign-in page integration test", (WidgetTester tester) async {
  //   // Mock the local notifications plugin
  //   await tester.pumpWidget(
  //     const MaterialApp(
  //       home: Sign_in(), // Test the Sign-in page directly
  //     ),
  //   );
  //
  //   // Wait for the sign-in page to render
  //   await tester.pumpAndSettle();
  //
  //   // Find the email and password fields
  //   final emailField = find.byType(TextFormField).at(0);
  //   final passwordField = find.byType(TextFormField).at(1);
  //
  //   // Enter test user credentials
  //   await tester.enterText(emailField, "moamen3@gmail.com");
  //   await tester.enterText(passwordField, "moamen!123!.");
  //
  //   // Find the sign-in button and tap it
  //   final signInButton = find.text("Sign in");
  //   await tester.tap(signInButton);
  //
  //   // Wait for all animations and asynchronous tasks to complete
  //   await tester.pumpAndSettle();
  //
  //   // Expect navigation to '/home' route or some success condition
  //   //  expect(find.text('Welcome to Hedieatak'), findsNothing);
  //   expect(find.text('Hedieaty'), findsOneWidget);
  //
  //   // Optional: Check for error message if credentials fail
  //   // final errorMessage = find.text("Invalid credentials");
  //   // if (errorMessage
  //   //     .evaluate()
  //   //     .isNotEmpty) {
  //   //   print("Sign-in failed: Invalid credentials.");
  //   // } else {
  //   //   print("Sign-in successful: Navigated to Home Page.");
  //   // }
  //
  //   // Step 3: Add a friend using the floating action button
  //   final addFriendButton = find.byIcon(Icons.person_add);
  //   await tester.tap(addFriendButton);
  //   await tester.pumpAndSettle();
  //
  //   // Fill in the friend's details in the "Add Friend" dialog
  //   final nameField = find.byType(TextField).at(0);
  //   final phoneField = find.byType(TextField).at(1);
  //   final emailFieldFriend = find.byType(TextField).at(2);
  //
  //   await tester.enterText(nameField, 'farah3');
  //   await tester.enterText(phoneField, '01096542245');
  //   await tester.enterText(emailFieldFriend, 'farah3@gmail.com');
  //
  //   final addFriendDialogButton = find.text('Add');
  //   await tester.tap(addFriendDialogButton);
  //   await tester.pumpAndSettle();
  //
  //   // expect(find.text('John Doe'), findsOneWidget);
  //
  //   // Step 3: Verify the friend is added in the ListView
  //   // Find the `ListTile` with "John Doe" in the title
  //   final moamen3Tile = find.widgetWithText(ListTile, 'moamen3');
  //   expect(moamen3Tile, findsOneWidget);
  //
  //   // Step 4: Tap the forward button in the `ListTile`
  //   final forwardButton = find.descendant(
  //     of: moamen3Tile,
  //     matching: find.byIcon(Icons.arrow_forward),
  //   );
  //   await tester.tap(forwardButton);
  //   await tester.pumpAndSettle();
  //
  //   expect(find.text('Events for moamen3'), findsOneWidget);
  //
  //   //coffe spot makan gdid
  //
  //   final coffeSpotTitle = find.widgetWithText(ListTile, 'coffe spot makan gdid');
  //   expect(coffeSpotTitle, findsOneWidget);
  //
  //   // Step 6: Navigate to the Gift List for the event
  //   final forwardEventButton = find.descendant(
  //     of: coffeSpotTitle,
  //     matching: find.byIcon(Icons.arrow_forward),
  //   );
  //   await tester.tap(forwardEventButton);
  //   await tester.pumpAndSettle();
  //
  //
  //
  //
  // });


  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  testWidgets('Add Friend and Navigate to Gifts', (WidgetTester tester) async {
    // Launch the app
    await tester.pumpWidget( HomePage());

    // Step 1: Verify the HomePage is loaded
    expect(find.text('Hedieaty'), findsOneWidget);

    // Step 2: Open the Add Friend dialog
    await tester.tap(find.byIcon(Icons.person_add));
    await tester.pumpAndSettle();

    // Verify Add Friend dialog appears
    expect(find.text('Add Friend'), findsOneWidget);

    // Step 3: Enter friend details
    await tester.enterText(find.bySemanticsLabel('Name'), 'moamen3');
    await tester.enterText(find.bySemanticsLabel('Phone Number'), '01096542213');
    await tester.enterText(find.bySemanticsLabel("Friend's Email"), 'moamen3@gmail.com');

    // Step 4: Confirm adding the friend
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Verify friend is added and displayed in the list
    expect(find.text('moamen3'), findsOneWidget);

    // Step 5: Navigate to FriendEventList
    await tester.tap(find.byIcon(Icons.arrow_forward).first);
    await tester.pumpAndSettle();

    // Verify navigation to FriendEventList
    expect(find.text('Events for moamen3'), findsOneWidget);

    // Step 6: Verify the list of events and tap the forward arrow for a specific event
    expect(find.byType(ListView), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_forward).first);
    await tester.pumpAndSettle();

    // Verify navigation to FriendGiftList
    expect(find.text('Friend Gifts'), findsOneWidget);

    // Step 7: Pledge a gift
    expect(find.byType(ListView), findsOneWidget);

    // Select the dropdown and choose "Pledged"
    await tester.tap(find.byType(DropdownButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pledged').last);
    await tester.pumpAndSettle();

    // Verify the gift status is updated to "Pledged"
    expect(find.text('Pledged'), findsWidgets);
  });





}







