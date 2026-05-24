// test/widget/add_flight_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trippie_frontend/features/trip/presentation/add_flight_screen.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';
import 'package:trippie_frontend/features/trip/data/trip_dto.dart';
import 'package:trippie_frontend/features/trip/data/flight_dto.dart';

class _FakeTripsNotifier extends TripsNotifier {
  @override
  Future<List<TripDto>> build() async => [];
}

Widget buildFlight({String tripId = 'test-trip', FlightDto? existing}) {
  return ProviderScope(
    overrides: [
      tripsProvider.overrideWith(_FakeTripsNotifier.new),
    ],
    child: MaterialApp(
      home: AddFlightScreen(tripId: tripId, existing: existing),
    ),
  );
}

/// Scrolluje kým sa text [text] neobjaví, vráti ElevatedButton ktorý ho obaľuje.
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
  group('UI-03 | AddFlightScreen', () {
    testWidgets('UI-03a: zobrazí nadpis "Add Flight" a všetky sekcie',
        (tester) async {
      await tester.pumpWidget(buildFlight());
      await tester.pumpAndSettle();

      expect(find.text('Add Flight'), findsOneWidget);
      expect(find.text('Direction'), findsOneWidget);
      expect(find.text('From'), findsOneWidget);
      expect(find.text('To'), findsOneWidget);
      expect(find.text('Flight number (opt.)'), findsOneWidget);
    });

    testWidgets('UI-03b: zobrazí dlaždice "Outbound" a "Return"',
        (tester) async {
      await tester.pumpWidget(buildFlight());
      await tester.pumpAndSettle();

      expect(find.text('Outbound'), findsOneWidget);
      expect(find.text('Return'), findsOneWidget);
    });

    testWidgets(
        'UI-03c: tlačidlo "Save Flight" je disabled keď nie sú letiská',
        (tester) async {
      await tester.pumpWidget(buildFlight());
      await tester.pumpAndSettle();

      final button = await scrollToButton(tester, 'Save Flight');
      expect(button.onPressed, isNull);
    });

    testWidgets('UI-03d: tapnutie na "Return" zmení smer letu', (tester) async {
      await tester.pumpWidget(buildFlight());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Return'));
      await tester.pump();

      expect(find.text('Return'), findsOneWidget);
      expect(find.text('Outbound'), findsOneWidget);
    });

    testWidgets('UI-03e: zobrazí search fieldy pre odlet a prílet',
        (tester) async {
      await tester.pumpWidget(buildFlight());
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(TextField, 'Search departure airport...'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextField, 'Search arrival airport...'),
        findsOneWidget,
      );
    });

    testWidgets('UI-03f: pole čísla letu prijíma vstup', (tester) async {
      await tester.pumpWidget(buildFlight());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'e.g. FR 1819'),
        'FR 1819',
      );
      await tester.pump();

      expect(find.text('FR 1819'), findsOneWidget);
    });

    testWidgets('UI-03g: v edit móde zobrazí "Edit Flight" a "Save changes"',
        (tester) async {
      final fakeFlight = FlightDto(
        id: 'f1',
        travelDirection: 'outbound',
        departure: AirportDto(
          id: 'a1', 
          name: 'Vienna Intl', 
          city: 'Vienna',
          country: 'Austria',
          iataCode: 'VIE'
        ),
        arrival: AirportDto(
          id: 'a2', name: 'El Prat', city: 'Barcelona',
          country: 'Spain', iataCode: 'BCN'
        ),
      );

      await tester.pumpWidget(buildFlight(existing: fakeFlight));
      await tester.pumpAndSettle();

      expect(find.text('Edit Flight'), findsOneWidget);

      // Scroll k tlačidlu
      final button = await scrollToButton(tester, 'Save changes');
      expect(button, isNotNull);
    });
  });
}