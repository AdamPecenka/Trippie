// test/widget/trip_hub_screen_test.dart
//
// Spustenie: flutter test test/widget/trip_hub_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trippie_frontend/features/trip/presentation/trip_hub_screen.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';
import 'package:trippie_frontend/features/trip/data/flight_repository.dart';
import 'package:trippie_frontend/features/trip/data/trip_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_enums.dart';
import 'package:trippie_frontend/features/trip/data/flight_dto.dart';
import 'package:trippie_frontend/features/trip/data/accommodation_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_member_dto.dart';

// ── Fake notifier pre tripsProvider ──────────────────────────────────────────

class _FakeTripsNotifier extends TripsNotifier {
  final List<TripDto> trips;
  _FakeTripsNotifier(this.trips);

  @override
  Future<List<TripDto>> build() async => trips;
}

// ── Fake dáta ─────────────────────────────────────────────────────────────────

const _tripId = 'trip-1';

final _fakeTrip = TripDto(
  id: _tripId,
  name: 'Barcelona 2026',
  status: TripStatus.planning,
  startDate: DateTime(2026, 2, 24),
  endDate: DateTime(2026, 2, 28),
  destination: 'Barcelona',
);

AirportDto _airport(String iata, String city) => AirportDto(
      id: iata,
      iataCode: iata,
      name: '$city Airport',
      city: city,
      country: 'Spain',
    );

FlightDto _flight(String direction) => FlightDto(
      id: 'f-$direction',
      travelDirection: direction,
      departure: _airport('BTS', 'Bratislava'),
      arrival: _airport('BCN', 'Barcelona'),
    );

TripMemberDto _member({String role = 'TRIP_MEMBER'}) => TripMemberDto(
      userId: 'user-1',
      firstname: 'Jana',
      lastname: 'Nová',
      email: 'jana@test.com',
      tripRole: role,
      joinedAt: DateTime(2026, 2, 24),
    );

// ── Helper ────────────────────────────────────────────────────────────────────

Widget buildHub({
  List<TripDto> trips = const [],
  List<FlightDto> flights = const [],
  AccommodationDto? accommodation,
  List<TripMemberDto> members = const [],
}) {
  return ProviderScope(
    overrides: [
      tripsProvider.overrideWith(() => _FakeTripsNotifier(trips)),
      tripFlightsProvider(_tripId).overrideWith((ref) async => flights),
      tripAccommodationProvider(_tripId)
          .overrideWith((ref) async => accommodation),
      tripMembersProvider(_tripId).overrideWith((ref) async => members),
    ],
    child: const MaterialApp(
      home: TripHubScreen(tripId: _tripId),
    ),
  );
}

// ── Testy ─────────────────────────────────────────────────────────────────────

void main() {
  group('UI-06 | TripHubScreen', () {
    testWidgets(
      'UI-06a: zobrazí sekcie BOOKINGS, CREW, PLANS',
      (tester) async {
        await tester.pumpWidget(buildHub(trips: [_fakeTrip]));
        await tester.pumpAndSettle();

        expect(find.text('BOOKINGS'), findsOneWidget);
        expect(find.text('CREW'), findsOneWidget);
        expect(find.text('PLANS'), findsOneWidget);
      },
    );

    testWidgets(
      'UI-06b: zobrazí všetky module karty',
      (tester) async {
        await tester.pumpWidget(buildHub(trips: [_fakeTrip]));
        await tester.pumpAndSettle();

        expect(find.text('Flights'), findsOneWidget);
        expect(find.text('Accommodation'), findsOneWidget);
        expect(find.text('Members'), findsOneWidget);
        expect(find.text('Activities'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.text('Map'),
          200.0,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();

        expect(find.text('Map'), findsOneWidget);
      },
    );

    testWidgets(
      'UI-06c: zobrazí názov tripu v hlavičke',
      (tester) async {
        await tester.pumpWidget(buildHub(trips: [_fakeTrip]));
        await tester.pumpAndSettle();

        expect(find.text('Barcelona 2026'), findsOneWidget);
      },
    );

    testWidgets(
      'UI-06d: Flights karta zobrazí "Both flights confirmed" keď existujú obidva smery',
      (tester) async {
        await tester.pumpWidget(buildHub(
          trips: [_fakeTrip],
          flights: [_flight('OUTBOUND'), _flight('RETURN')],
        ));
        await tester.pumpAndSettle();

        expect(find.text('Both flights confirmed'), findsOneWidget);
      },
    );

    testWidgets(
      'UI-06e: Flights karta zobrazí "Add your flights" keď nie sú žiadne lety',
      (tester) async {
        await tester.pumpWidget(buildHub(
          trips: [_fakeTrip],
          flights: [],
        ));
        await tester.pumpAndSettle();

        expect(find.text('Add your flights'), findsOneWidget);
      },
    );

    testWidgets(
      'UI-06f: Accommodation karta zobrazí názov ubytovanie keď existuje',
      (tester) async {
        final fakeAccommodation = AccommodationDto(
          id: 'acc-1',
          placeName: 'La Hostel Barcelona',
          placeId: 'place-1',
          checkIn: DateTime(2026, 2, 24, 14),
          checkOut: DateTime(2026, 3, 8, 12),
        );

        await tester.pumpWidget(buildHub(
          trips: [_fakeTrip],
          accommodation: fakeAccommodation,
        ));
        await tester.pumpAndSettle();

        expect(find.text('La Hostel Barcelona'), findsOneWidget);
      },
    );

    testWidgets(
      'UI-06g: Members karta zobrazí "Solo — invite your friends!" pre 1 člena',
      (tester) async {
        await tester.pumpWidget(buildHub(
          trips: [_fakeTrip],
          members: [_member()],
        ));
        await tester.pumpAndSettle();

        expect(find.text('Solo — invite your friends!'), findsOneWidget);
      },
    );

    testWidgets(
      'UI-06h: Members karta zobrazí počet členov keď je ich viac',
      (tester) async {
        await tester.pumpWidget(buildHub(
          trips: [_fakeTrip],
          members: [
            _member(),
            TripMemberDto(
              userId: 'user-2',
              firstname: 'Adam',
              lastname: 'Pečenka',
              email: 'adam@test.com',
              tripRole: 'TRIP_MEMBER',
              joinedAt: DateTime(2026, 2, 24),
            ),
          ],
        ));
        await tester.pumpAndSettle();

        expect(find.text('2 members'), findsOneWidget);
      },
    );
  });
}