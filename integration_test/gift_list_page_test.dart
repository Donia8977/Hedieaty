import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/ui/GiftList.dart';

void main() {
  group('GiftListPage Tests', () {
    testWidgets('Displays loading animation when loading gifts', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GiftListPage(eventId: 'testEventId'),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('Add gift dialog is shown when FAB is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GiftListPage(eventId: 'testEventId'),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Add New Gift'), findsOneWidget);
    });

    testWidgets('Gift status dropdown updates status', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GiftListPage(eventId: 'testEventId'),
        ),
      );

      await tester.pumpAndSettle();

      final dropdownFinder = find.byType(DropdownButton<String>);
      expect(dropdownFinder, findsOneWidget);

      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pledged').last);
      await tester.pumpAndSettle();
      expect(find.text('Pledged'), findsOneWidget);
    });
  });
}
