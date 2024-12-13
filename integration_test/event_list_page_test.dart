import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/ui/EventListPage.dart';

void main() {
  group('EventListPage Tests', () {
    testWidgets('Displays loading animation when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EventListPage(),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('Displays event list after loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EventListPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Add event dialog is shown when FAB is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EventListPage(),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('Add Event'), findsOneWidget);
    });
  });
}
