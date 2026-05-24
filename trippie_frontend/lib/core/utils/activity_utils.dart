// test/widget/create_trip_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trippie_frontend/features/trip/presentation/create_trip_screen.dart';

Widget buildCreateTrip() {
  return const ProviderScope(
    child: MaterialApp(home: CreateTripScreen()),
  );
}

Future<ElevatedButton> scrollToButton(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text),
    150.0,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump();
  return tester.widget<ElevatedButton>(
    find.ancestor(
      of: find.text(text),
      matching: find.byType(ElevatedButton),
    ),
  );
}

void main() {
  group('UI-04 | CreateTripScreen', () {
    testWidgets('UI-04a: zobrazí nadpis a podnadpis', (tester) async {
      await tester.pumpWidget(buildCreateTrip());
      await tester.pumpAndSettle();

      expect(find.text('New Trip'), findsOneWidget);
      expect(
        find.text('Just the essentials. Add details later.'),
        findsOneWidget,
      );
    });

    testWidgets('UI-04b: zobrazí povinné labely', (tester) async {
      await tester.pumpWidget(buildCreateTrip());
      await tester.pumpAndSettle();

      expect(find.text('Trip name *'), findsOneWidget);
      expect(find.text('Destination *'), findsOneWidget);
      expect(find.text('Dates *'), findsOneWidget);
    });

    testWidgets('UI-04c: tlačidlo disabled pri prázdnom formulári',
        (tester) async {
      await tester.pumpWidget(buildCreateTrip());
      await tester.pumpAndSettle();

      final button = await scrollToButton(tester, 'Create Trip →');
      expect(button.onPressed, isNull);
    });

    testWidgets(
        'UI-04d: tlačidlo ostáva disabled po zadaní iba názvu',
        (tester) async {
      await tester.pumpWidget(buildCreateTrip());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'e.g. Barcelona 2026'),
        'My Trip',
      );
      await tester.pump();

      final button = await scrollToButton(tester, 'Create Trip →');
      expect(button.onPressed, isNull);
    });

    testWidgets('UI-04e: destination search field je viditeľný',
        (tester) async {
      await tester.pumpWidget(buildCreateTrip());
      await tester.pumpAndSettle();

      // Hľadáme TextField vo vnútri sekcie Destination —
      // nezávisle od konkrétneho hint textu ActivitySearchField
      expect(find.text('Destination *'), findsOneWidget);
      // Aspoň 2 TextFieldy musia existovať (trip name + destination search)
      expect(find.byType(TextField), findsAtLeastNWidgets(2));
    });

    testWidgets('UI-04f: zobrazuje "Select travel dates" defaultne',
        (tester) async {
      await tester.pumpWidget(buildCreateTrip());
      await tester.pumpAndSettle();

      expect(find.text('Select travel dates'), findsOneWidget);
    });

    testWidgets('UI-04g: zadanie názvu tripu sa zobrazí v poli', (tester) async {
      await tester.pumpWidget(buildCreateTrip());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'e.g. Barcelona 2026'),
        'Paris Summer 2026',
      );
      await tester.pump();

      expect(find.text('Paris Summer 2026'), findsOneWidget);
    });
  });
}