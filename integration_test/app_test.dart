
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/models/Friend.dart';
import 'package:hedieaty/ui/EventListPage.dart';
import 'package:hedieaty/ui/Sign_in.dart';
import 'package:hedieaty/ui/Sign_up.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hedieaty/main.dart' ;
import 'package:firebase_auth/firebase_auth.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  final mockFirebaseAuth = MockFirebaseAuth();
  final mockUserCredential = MockUserCredential();
  final mockUser = MockUser();

  group('Sign-In to Sign-Up to HomePage Integration Test', () {
    setUp(() {

      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => mockUserCredential);

      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => mockUserCredential);

      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('mockUid');
      when(() => mockUser.email).thenReturn('test_user@example.com');

      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

    });

    testWidgets(
        'Navigate from Sign-In to Sign-Up and verify empty friend list state',
            (WidgetTester tester) async {

          // Launch the app
          await tester.pumpWidget(
            MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Hedieaty',
              initialRoute: '/sign_in',
              routes: {
                '/home': (context) => HomePage(),
                '/sign_in': (context) => Sign_in(),
                '/sign_up': (context) => Sign_up(),
              },
            ),
          );

          await tester.pumpAndSettle();

          expect(find.text('Welcome to Hedieatak'), findsOneWidget);
          expect(find.text('Sign in'), findsOneWidget);

          await tester.tap(find.text('Sign up'));
          await tester.pumpAndSettle();

          expect(find.text("Let's Create an account"), findsOneWidget);

          final testEmail =
              'test_user_${DateTime.now().millisecondsSinceEpoch}@example.com';

          await tester.enterText(find.bySemanticsLabel('UserName'), 'test_user');
          await tester.enterText(find.bySemanticsLabel('Email'), testEmail);
          await tester.enterText(find.bySemanticsLabel('Password'), 'password123');

          await tester.tap(find.text('Sign up'));
          await tester.pumpAndSettle();

          expect(find.byType(HomePage), findsOneWidget);
          expect(find.text('No friends found. Add a friend to get started!'),
              findsOneWidget);

         // expect(find.text('Hedieaty'), findsOneWidget);
          expect(find.text('Create Your Own Event/List'), findsOneWidget);
        });

    testWidgets('HomePage: Add Friend manually', (WidgetTester tester) async {

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

     // expect(find.text('Hedieaty'), findsOneWidget);
      expect(find.byType(HomePage), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Add Friend'), findsOneWidget);

      await tester.enterText(find.bySemanticsLabel('Name'), 'John Doe');
      await tester.enterText(find.bySemanticsLabel('Phone Number'), '1234567890');
      await tester.enterText(find.bySemanticsLabel("Friend's Email"), 'johndoe@gmail.com');


      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('No Upcoming Events'), findsOneWidget);
    });

    testWidgets('HomePage: Verify friend list displays correctly',
            (WidgetTester tester) async {
          final mockFriends = [
            Friend(
              friendId: 'friend1',
              name: 'Jane Doe',
              profilePic: 'images/male_iocn.png',
              upcomingEvents: 2,
              userId: 'mockUid',
              gender: 'female',
            ),
            Friend(
              friendId: 'friend2',
              name: 'John Smith',
              profilePic: 'images/3430601_avatar_female_normal_woman_icon.png',
              upcomingEvents: 0,
              userId: 'mockUid',
              gender: 'male',
            ),
          ];

          await tester.pumpWidget(MockHomePage(mockFriends: mockFriends));
          await tester.pumpAndSettle();

          // Verify the friends list displays correctly
          expect(find.text('Jane Doe'), findsOneWidget);
          expect(find.text('John Smith'), findsOneWidget);
          expect(find.text('Upcoming Events: 2'), findsOneWidget);
          expect(find.text('No Upcoming Events'), findsOneWidget);
        });
  });
}

class MockHomePage extends StatelessWidget {
  final List<Friend> mockFriends;

  MockHomePage({required this.mockFriends});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Hedieaty')),
        body: mockFriends.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('No friends found. Add a friend to get started!'),
            ],
          ),
        )
            : ListView.builder(
          itemCount: mockFriends.length,
          itemBuilder: (context, index) {
            final friend = mockFriends[index];
            return ListTile(
              title: Text(friend.name),
              subtitle: Text(friend.upcomingEvents > 0
                  ? "Upcoming Events: ${friend.upcomingEvents}"
                  : "No Upcoming Events"),
            );
          },
        ),
      ),
    );
  }
}

