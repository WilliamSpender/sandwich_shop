import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/main.dart';

void main() {
  group('App', () {
    testWidgets('renders OrderScreen as home', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(OrderScreen), findsOneWidget);
    });
  });

  group('OrderScreen - Quantity', () {
    testWidgets('shows initial quantity and title',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      expect(find.text('0 white footlong sandwich(es): '), findsOneWidget);
      expect(find.text('Sandwich Counter'), findsOneWidget);
    });

    testWidgets('increments quantity when Add is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pump();
      expect(find.text('1 white footlong sandwich(es): 🥪'), findsOneWidget);
    });

    testWidgets('decrements quantity when Remove is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pump();
      expect(find.text('1 white footlong sandwich(es): 🥪'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Remove'));
      await tester.pump();
      expect(find.text('0 white footlong sandwich(es): '), findsOneWidget);
    });

    testWidgets('does not decrement below zero', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      expect(find.text('0 white footlong sandwich(es): '), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Remove'));
      await tester.pump();
      expect(find.text('0 white footlong sandwich(es): '), findsOneWidget);
    });

    testWidgets('does not increment above maxQuantity',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
        await tester.pump();
      }
      expect(find.text('5 white footlong sandwich(es): 🥪🥪🥪🥪🥪'),
          findsOneWidget);
    });
  });

  group('OrderScreen - Controls', () {
    testWidgets('toggles sandwich type with Switch',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      expect(find.textContaining('footlong sandwich'), findsOneWidget);
      await tester.tap(find.text('Add to Cart'));
      await tester.pump();
      expect(find.textContaining('six-inch sandwich'), findsOneWidget);
    });

    testWidgets('updates note with TextField', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.enterText(
          find.byKey(const Key('notes_textfield')), 'Extra mayo');
      await tester.pump();
      expect(find.text('Note: Extra mayo'), findsOneWidget);
    });
  });

  group('StyledButton', () {
    testWidgets('renders with icon and label', (WidgetTester tester) async {
      const testButton = StyledButton(
        onPressed: null,
        icon: Icons.add,
        label: 'Test Add',
        backgroundColor: Colors.blue,
      );
      const testApp = MaterialApp(
        home: Scaffold(body: testButton),
      );
      await tester.pumpWidget(testApp);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Test Add'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });

    group('OrderScreen - Summary', () {
    testWidgets('Add default sandwich',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.tap(find.byKey(const Key('add_cart')));
      await tester.pump();
      expect(find.textContaining('1  Veggie Delight footlong'), findsOneWidget);
    });

    testWidgets('Add multiple sandwiches',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.tap(find.byKey(const Key('add_sandwich')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('add_sandwich')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('add_sandwich')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('add_cart')));
      await tester.pump();
      expect(find.textContaining('4  Veggie Delight footlong'), findsOneWidget);
    });

        testWidgets('Add different sandwiches',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.tap(find.byKey(const Key('sandwich_type')));
      await tester.pump();
      // The text 'Tuna Melt' appears more than once (label + menu item).
      // Tap the menu item instance by selecting the second match.
      await tester.tap(find.text('Tuna Melt').at(1));
      await tester.pump();
      await tester.tap(find.byKey(const Key('add_cart')));
      await tester.pump();
      expect(find.textContaining('1  Tuna Melt'), findsOneWidget);
    });
  });
}
