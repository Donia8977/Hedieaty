import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/controllers/Auth.dart';
import 'package:hedieaty/ui/Sign_in.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:hedieaty/main.dart';
import 'package:hedieaty/ui/FriendEventList.dart';

// class MockFlutterLocalNotificationsPlugin extends Mock
//     implements FlutterLocalNotificationsPlugin {
//   @override
//   Future<void> show(
//       int id,
//       String? title,
//       String? body,
//       NotificationDetails? notificationDetails, {
//         String? payload,
//       }) async {
//     // Return a valid Future<void>
//     return Future.value();
//   }
// }

// class MockFlutterLocalNotificationsPlugin extends Mock
//     implements FlutterLocalNotificationsPlugin {
//   @override
//   Future<void> show(
//       int id,
//       String? title,
//       String? body,
//       NotificationDetails? notificationDetails, {
//         String? payload,
//       }) async {
//     // Return a valid Future<void>
//     return Future<void>.value();
//   }
// }

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {
  @override
  Future<void> show(
      int id,
      String? title,
      String? body,
      NotificationDetails? notificationDetails, {
        String? payload,
      }) {
    return super.noSuchMethod(
      Invocation.method(
        #show,
        [id, title, body, notificationDetails],
        {#payload: payload},
      ),
      returnValue: Future.value(),
      returnValueForMissingStub: Future.value(),
    );
  }
}


class MockMyAuth extends Mock implements MyAuth {}

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  late MockFlutterLocalNotificationsPlugin mockNotifications;

  setUp(() {
    mockNotifications = MockFlutterLocalNotificationsPlugin();

    when(mockNotifications.show(
      0,
      any,
      any,
      any,
      payload: anyNamed('payload'),
    )).thenAnswer((_) async => Future.value());
  });


  //
  // testWidgets('Add Friend and Navigate to Gifts', (WidgetTester tester) async {
  //   // Wrap the app with MaterialApp
  //   await tester.pumpWidget(MaterialApp(home: HomePage(key: Key('homePage'))));
  //
  //   // Step 1: Verify the HomePage is loaded
  //   expect(find.byKey(const Key('homePage')), findsOneWidget);
  //
  //   // Step 2: Open the Add Friend dialog
  //   await tester.tap(find.byIcon(Icons.person_add));
  //   await tester.pumpAndSettle();
  //
  //   // Verify Add Friend dialog appears
  //   expect(find.text('Add Friend'), findsOneWidget);
  //
  //   // Step 3: Enter friend details
  //   await tester.enterText(find.bySemanticsLabel('Name'), 'moamen3');
  //   await tester.enterText(find.bySemanticsLabel('Phone Number'), '01096542213');
  //   await tester.enterText(find.bySemanticsLabel("Friend's Email"), 'moamen3@gmail.com');
  //
  //   // Step 4: Confirm adding the friend
  //   await tester.tap(find.text('Add'));
  //   await tester.pumpAndSettle();
  //
  //   // Verify friend is added and displayed in the list
  //   expect(find.text('moamen3'), findsOneWidget);
  //
  //   // Step 5: Navigate to FriendEventList
  //   await tester.tap(find.byIcon(Icons.arrow_forward).first);
  //   await tester.pumpAndSettle();
  //
  //   // Verify navigation to FriendEventList
  //   expect(find.text('Events for moamen3'), findsOneWidget);
  //
  //   // Step 6: Verify the list of events and tap the forward arrow for a specific event
  //   expect(find.byType(ListView), findsOneWidget);
  //   await tester.tap(find.byIcon(Icons.arrow_forward).first);
  //   await tester.pumpAndSettle();
  //
  //   // Verify navigation to FriendGiftList
  //   expect(find.text('Friend Gifts'), findsOneWidget);
  //
  //   // Step 7: Pledge a gift
  //   expect(find.byType(ListView), findsOneWidget);
  //
  //   // Select the dropdown and choose "Pledged"
  //   await tester.tap(find.byType(DropdownButton).first);
  //   await tester.pumpAndSettle();
  //   await tester.tap(find.text('Pledged').last);
  //   await tester.pumpAndSettle();
  //
  //   // Verify the gift status is updated to "Pledged"
  //   expect(find.text('Pledged'), findsWidgets);
  // });

  // testWidgets('Sign In, Add Friend and Navigate to Gifts', (WidgetTester tester) async {
  //   // Wrap the app with MaterialApp and simulate the sign-in flow
  //   await tester.pumpWidget(MaterialApp(home: Sign_in(key: Key('signInPage'))));

  testWidgets('Sign In navigates to HomePage', (WidgetTester tester) async {

    final mockAuth = MockMyAuth();

    myAuth = mockAuth;
    when(mockAuth.sign_in(any, any)).thenAnswer((_) async => true);

    await tester.pumpWidget(MaterialApp(
      initialRoute: '/sign_in',
      routes: {
        '/home': (context) => HomePage(key: Key('homePage')),
        '/sign_in': (context) => Sign_in(key: Key('signInPage')),
      },
    ));

    expect(find.byKey(const Key('signInPage')), findsOneWidget);

    await tester.enterText(find.bySemanticsLabel('Email'), 'farah3@gmail.com');
    await tester.enterText(find.bySemanticsLabel('Password'), 'farah!123!.');

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('homePage')), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person_add));
    await tester.pumpAndSettle();

    expect(find.text('Add Friend'), findsOneWidget);

    await tester.enterText(find.bySemanticsLabel('Name'), 'moamen3');
    await tester.enterText(find.bySemanticsLabel('Phone Number'), '01096542213');
    await tester.enterText(find.bySemanticsLabel("Friend's Email"), 'moamen3@gmail.com');

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('moamen3'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_forward).first);
    await tester.pumpAndSettle();

    expect(find.text('Events for moamen3'), findsOneWidget);

    expect(find.byType(ListView), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_forward).first);
    await tester.pumpAndSettle();

    expect(find.text('Friend Gifts'), findsOneWidget);

    expect(find.byType(ListView), findsOneWidget);

    await tester.tap(find.byType(DropdownButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pledged').last);
    await tester.pumpAndSettle();

    expect(find.text('Pledged'), findsWidgets);
  });




}
