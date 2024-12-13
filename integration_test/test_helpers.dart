import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/main.dart';
import 'package:hedieaty/models/AppUser.dart';

Future<Widget> createTestApp() async {
  final fakeFirestore = FakeFirebaseFirestore();
  final mockUser = MockUser(
    isAnonymous: false,
    email: 'test@example.com',
    displayName: 'Test User',
    uid: 'testUid',
  );
  final mockAuth = MockFirebaseAuth(mockUser: mockUser);

  appUser = AppUser(name: 'App user ', email: 'example@gmail.com');

  return MaterialApp(
    home: HomePage(),
  );
}
