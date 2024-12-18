//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:hedieaty/models/Friend.dart';
// import 'package:hedieaty/ui/EventListPage.dart';
// import 'package:hedieaty/ui/Sign_in.dart';
// import 'package:hedieaty/ui/Sign_up.dart';
// import 'package:integration_test/integration_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:hedieaty/main.dart' ;
// import 'package:firebase_auth/firebase_auth.dart';
//
// class MockFirebaseAuth extends Mock implements FirebaseAuth {}
//
// class MockUserCredential extends Mock implements UserCredential {}
//
// class MockUser extends Mock implements User {}
//
// void main() async {
//   IntegrationTestWidgetsFlutterBinding.ensureInitialized();
//
//   await Firebase.initializeApp();
//
//   final mockFirebaseAuth = MockFirebaseAuth();
//   final mockUserCredential = MockUserCredential();
//   final mockUser = MockUser();
//
//   group('Sign-In to Sign-Up to HomePage Integration Test', () {
//     setUp(() {
//
//       when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
//         email: any(named: 'email'),
//         password: any(named: 'password'),
//       )).thenAnswer((_) async => mockUserCredential);
//
//       when(() => mockFirebaseAuth.signInWithEmailAndPassword(
//         email: any(named: 'email'),
//         password: any(named: 'password'),
//       )).thenAnswer((_) async => mockUserCredential);
//
//       when(() => mockUserCredential.user).thenReturn(mockUser);
//       when(() => mockUser.uid).thenReturn('mockUid');
//       when(() => mockUser.email).thenReturn('test_user@example.com');
//
//       when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
//
//     });
//
//     testWidgets(
//         'Navigate from Sign-In to Sign-Up and verify empty friend list state',
//             (WidgetTester tester) async {
//
//           // Launch the app
//           await tester.pumpWidget(
//             MaterialApp(
//               debugShowCheckedModeBanner: false,
//               title: 'Hedieaty',
//               initialRoute: '/sign_in',
//               routes: {
//                 '/home': (context) => HomePage(),
//                 '/sign_in': (context) => Sign_in(),
//                 '/sign_up': (context) => Sign_up(),
//               },
//             ),
//           );
//
//           await tester.pumpAndSettle();
//
//           expect(find.text('Welcome to Hedieatak'), findsOneWidget);
//           expect(find.text('Sign in'), findsOneWidget);
//
//           await tester.tap(find.text('Sign up'));
//           await tester.pumpAndSettle();
//
//           expect(find.text("Let's Create an account"), findsOneWidget);
//
//           final testEmail =
//               'test_user_${DateTime.now().millisecondsSinceEpoch}@example.com';
//
//           await tester.enterText(find.bySemanticsLabel('UserName'), 'test_user');
//           await tester.enterText(find.bySemanticsLabel('Email'), testEmail);
//           await tester.enterText(find.bySemanticsLabel('Password'), 'password123');
//
//           await tester.tap(find.text('Sign up'));
//           await tester.pumpAndSettle();
//
//           expect(find.byType(HomePage), findsOneWidget);
//           expect(find.text('No friends found. Add a friend to get started!'),
//               findsOneWidget);
//
//          // expect(find.text('Hedieaty'), findsOneWidget);
//           expect(find.text('Create Your Own Event/List'), findsOneWidget);
//         });
//
//     testWidgets('HomePage: Add Friend manually', (WidgetTester tester) async {
//
//       await tester.pumpWidget(
//         MaterialApp(
//           debugShowCheckedModeBanner: false,
//           home: HomePage(),
//         ),
//       );
//
//       await tester.pumpAndSettle();
//
//      // expect(find.text('Hedieaty'), findsOneWidget);
//       expect(find.byType(HomePage), findsOneWidget);
//
//       await tester.tap(find.byType(FloatingActionButton));
//       await tester.pumpAndSettle();
//
//       expect(find.text('Add Friend'), findsOneWidget);
//
//       await tester.enterText(find.bySemanticsLabel('Name'), 'John Doe');
//       await tester.enterText(find.bySemanticsLabel('Phone Number'), '1234567890');
//       await tester.enterText(find.bySemanticsLabel("Friend's Email"), 'johndoe@gmail.com');
//
//
//       await tester.tap(find.text('Add'));
//       await tester.pumpAndSettle();
//
//       expect(find.text('John Doe'), findsOneWidget);
//       expect(find.text('No Upcoming Events'), findsOneWidget);
//     });
//
//     testWidgets('HomePage: Verify friend list displays correctly',
//             (WidgetTester tester) async {
//           final mockFriends = [
//             Friend(
//               friendId: 'friend1',
//               name: 'Jane Doe',
//               profilePic: 'images/male_iocn.png',
//               upcomingEvents: 2,
//               userId: 'mockUid',
//               gender: 'female',
//             ),
//             Friend(
//               friendId: 'friend2',
//               name: 'John Smith',
//               profilePic: 'images/3430601_avatar_female_normal_woman_icon.png',
//               upcomingEvents: 0,
//               userId: 'mockUid',
//               gender: 'male',
//             ),
//           ];
//
//           await tester.pumpWidget(MockHomePage(mockFriends: mockFriends));
//           await tester.pumpAndSettle();
//
//           // Verify the friends list displays correctly
//           expect(find.text('Jane Doe'), findsOneWidget);
//           expect(find.text('John Smith'), findsOneWidget);
//           expect(find.text('Upcoming Events: 2'), findsOneWidget);
//           expect(find.text('No Upcoming Events'), findsOneWidget);
//         });
//   });
// }
//
// class MockHomePage extends StatelessWidget {
//   final List<Friend> mockFriends;
//
//   MockHomePage({required this.mockFriends});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text('Hedieaty')),
//         body: mockFriends.isEmpty
//             ? Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text('No friends found. Add a friend to get started!'),
//             ],
//           ),
//         )
//             : ListView.builder(
//           itemCount: mockFriends.length,
//           itemBuilder: (context, index) {
//             final friend = mockFriends[index];
//             return ListTile(
//               title: Text(friend.name),
//               subtitle: Text(friend.upcomingEvents > 0
//                   ? "Upcoming Events: ${friend.upcomingEvents}"
//                   : "No Upcoming Events"),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//


import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/ui/Sign_in.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hedieaty/main.dart';

// class MockFlutterLocalNotificationsPlugin extends Mock
//     implements FlutterLocalNotificationsPlugin {
// //   @override
// //   Future<void> show(
// //       int id,
// //       String? title,
// //       String? body,
// //       NotificationDetails? notificationDetails, {
// //         String? payload,
// //       }) {
// //     return Future.value();
// //   }
// // }

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
    return Future.value();
  }
}



  void main() async {
    // Initialize the integration test binding
  //   IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  //
  //   await Firebase.initializeApp();
  //
  //   // late MockFlutterLocalNotificationsPlugin mockNotifications;
  //   //
  //   // setUp(() {
  //   //   mockNotifications = MockFlutterLocalNotificationsPlugin();
  //   // });
  //
  //
  //   testWidgets("Sign-in page integration test", (WidgetTester tester) async {
  //     // Mock the local notifications plugin
  //     await tester.pumpWidget(
  //       MaterialApp(
  //         home: HomePage(),
  //       ),
  //     );

  //     await tester.pumpAndSettle();

  //     final emailField = find.byType(TextFormField).at(0);
  //     final passwordField = find.byType(TextFormField).at(1);

  //     await tester.enterText(emailField, "moamen3@gmail.com");
  //     await tester.enterText(passwordField, "moamen!123!.");

  //     final signInButton = find.text("Sign in");
  //     await tester.tap(signInButton);
  //
  //     await tester.pumpAndSettle();

  //   //  expect(find.text('Welcome to Hedieatak'), findsNothing);
  //     expect(find.text('Hedieaty'), findsOneWidget);
  //     // final errorMessage = find.text("Invalid credentials");
  //     // if (errorMessage
  //     //     .evaluate()
  //     //     .isNotEmpty) {
  //     //   print("Sign-in failed: Invalid credentials.");
  //     // } else {
  //     //   print("Sign-in successful: Navigated to Home Page.");
  //     // }

  //     final addFriendButton = find.byIcon(Icons.person_add);
  //     await tester.tap(addFriendButton);
  //     await tester.pumpAndSettle();

  //     final nameField = find.byType(TextField).at(0);
  //     final phoneField = find.byType(TextField).at(1);
  //     final emailFieldFriend = find.byType(TextField).at(2);
  //
  //     await tester.enterText(nameField, 'farah3');
  //     await tester.enterText(phoneField, '01096542245');
  //     await tester.enterText(emailFieldFriend, 'farah3@gmail.com');
  //
  //     final addFriendDialogButton = find.text('Add');
  //     await tester.tap(addFriendDialogButton);
  //     await tester.pumpAndSettle();
  //
  //    // expect(find.text('John Doe'), findsOneWidget);

  //     final moamen3Tile = find.widgetWithText(ListTile, 'moamen3');
  //     expect(moamen3Tile, findsOneWidget);

  //     final forwardButton = find.descendant(
  //       of: moamen3Tile,
  //       matching: find.byIcon(Icons.arrow_forward),
  //     );
  //     await tester.tap(forwardButton);
  //     await tester.pumpAndSettle();
  //
  //     expect(find.text('Events for moamen3'), findsOneWidget);
  //
  //     //coffe spot makan gdid
  //
  //     final coffeSpotTitle = find.widgetWithText(ListTile, 'coffe spot makan gdid');
  //     expect(coffeSpotTitle, findsOneWidget);

  //     final forwardEventButton = find.descendant(
  //       of: coffeSpotTitle,
  //       matching: find.byIcon(Icons.arrow_forward),
  //     );
  //     await tester.tap(forwardEventButton);
  //     await tester.pumpAndSettle();
  //   });
  // }

    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    late MockFlutterLocalNotificationsPlugin mockNotifications;

      setUp(() {
        mockNotifications = MockFlutterLocalNotificationsPlugin();
      });




    testWidgets('Add Friend and Navigate to Gifts', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomePage(key: Key('homePage'))));

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
