// test/widget/add_activity_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trippie_frontend/features/trip/presentation/add_activity_screen.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';
import 'package:trippie_frontend/features/trip/data/trip_dto.dart';
import 'package:trippie_frontend/features/trip/data/activity_dto.dart';

class _FakeTripsNotifier extends TripsNotifier {
  @override
  Future<List<TripDto>> build() async => [];
}

Widget buildActivity({String tripId = 'test-trip'}) {
  return ProviderScope(
    overrides: [
      tripsProvider.overrideWith(_FakeTripsNotifier.new),
      tripActivitiesProvider(tripId).overrideWith((ref) async => []),
    ],
    child: MaterialApp(
      home: AddActivityScreen(tripId: tripId),
    ),
  );
}

/// Scrolluje ListView kým sa text [text] neobjaví v strome,
/// potom vráti finder na ElevatedButton ktorý ho obsahuje.
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
  group('UI-02 | AddActivityScreen', () {
    testWidgets('UI-02a: zobrazí nadpis a všetky sekcie formulára',
        (tester) async {
      await tester.pumpWidget(buildActivity());
      await tester.pumpAndSettle();

      expect(find.text('Add activity'), findsOneWidget);
      expect(find.text('Pick a place to visit'), findsOneWidget);
      expect(find.text('Activity name'), findsOneWidget);
      expect(find.text('Date & time'), findsOneWidget);
      expect(find.text('Additional notes'), findsOneWidget);
    });

    testWidgets(
        'UI-02b: tlačidlo "Add to trip" je disabled keď je meno prázdne',
        (tester) async {
      await tester.pumpWidget(buildActivity());
      await tester.pumpAndSettle();

      final button = await scrollToButton(tester, 'Add to trip');
      expect(button.onPressed, isNull);
    });

    testWidgets(
        'UI-02c: tlačidlo "Add to trip" sa aktivuje po zadaní mena aktivity',
        (tester) async {
      await tester.pumpWidget(buildActivity());
      await tester.pumpAndSettle();

      // Zadaj meno
      await tester.enterText(
        find.widgetWithText(TextField, 'e.g. Morning Run, Museum visit...'),
        'Sagrada Familia',
      );
      await tester.pump();

      final button = await scrollToButton(tester, 'Add to trip');
      expect(button.onPressed, isNotNull);
    });

    testWidgets(
        'UI-02d: error banner sa nezobrazuje na začiatku',
        (tester) async {
      await tester.pumpWidget(buildActivity());
      await tester.pumpAndSettle();

      expect(find.text('End time must be after start time.'), findsNothing);
    });

    testWidgets('UI-02e: notes field prijíma viacriadkový vstup',
        (tester) async {
      await tester.pumpWidget(buildActivity());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Add any details...'),
        'Booking required.\nOpen 9am–6pm.',
      );
      await tester.pump();

      expect(find.textContaining('Booking required.'), findsOneWidget);
    });

    testWidgets('UI-02f: tlačidlo ostáva disabled po vymazaní mena',
        (tester) async {
      await tester.pumpWidget(buildActivity());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'e.g. Morning Run, Museum visit...'),
        'Museum visit',
      );
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextField, 'Museum visit'),
        '',
      );
      await tester.pump();

      final button = await scrollToButton(tester, 'Add to trip');
      expect(button.onPressed, isNull);
    });
  });
}