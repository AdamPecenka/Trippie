// test/widget/home_screen_test.dart
//
// Spustenie: flutter test test/widget/home_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
import 'package:trippie_frontend/features/auth/data/auth_dto.dart';
import 'package:trippie_frontend/features/trip/presentation/home_screen.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';
import 'package:trippie_frontend/features/trip/data/trip_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_enums.dart';

// ── Fake notifiery ────────────────────────────────────────────────────────────

class _FakeAuthNotifier extends AuthNotifier {
  final UserDto? user;
  _FakeAuthNotifier(this.user);

  @override
  Future<UserDto?> build() async => user;
}

class _FakeTripsNotifier extends TripsNotifier {
  final List<TripDto> trips;
  _FakeTripsNotifier(this.trips);

  @override
  Future<List<TripDto>> build() async => trips;
}

// ── Fake dáta ─────────────────────────────────────────────────────────────────

final _fakeUser = UserDto.fromJson({
  'id': 'user-1',
  'firstname': 'Veronika',
  'lastname': 'Nová',
  'email': 'v@test.com',
  'phoneNumber': '',
  'theme': 'LIGHT',
});

TripDto _makeTrip({
  String id = 'trip-1',
  String name = 'Barcelona 2026',
  TripStatus status = TripStatus.planning,
}) =>
    TripDto(
      id: id,
      name: name,
      status: status,
      startDate: DateTime(2026, 2, 24),
      endDate: DateTime(2026, 2, 28),
      destination: 'Barcelona',
    );

// ── Helper ────────────────────────────────────────────────────────────────────

Widget buildHome({UserDto? user, List<TripDto> trips = const []}) {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(() => _FakeAuthNotifier(user ?? _fakeUser)),
      tripsProvider.overrideWith(() => _FakeTripsNotifier(trips)),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

// ── Testy ─────────────────────────────────────────────────────────────────────

void main() {
  group('UI-05 | HomeScreen', () {
    testWidgets(
      'UI-05a: zobrazí pozdrav s menom prihláseného používateľa',
      (tester) async {
        await tester.pumpWidget(buildHome());
        await tester.pumpAndSettle();

        expect(find.text('Hello, Veronika 👋'), findsOneWidget);
      },
    );

    testWidgets(
      'UI-05b: zobrazí empty state keď používateľ nemá žiadne tripy',
      (tester) async {
        await tester.pumpWidget(buildHome(trips: []));
        await tester.pumpAndSettle();

        expect(find.text('No trips yet'), findsOneWidget);
        expect(
          find.text(
              "Let's change that.\nCreate a trip and invite your friends."),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'UI-05c: zobrazí sekciu "Your upcoming trips:" pre PLANNING/ACTIVE tripy',
      (tester) async {
        await tester.pumpWidget(
          buildHome(trips: [
            _makeTrip(name: 'Oslo', status: TripStatus.active),
            _makeTrip(id: 'trip-2', name: 'Barcelona', status: TripStatus.planning),
          ]),
        );
        await tester.pumpAndSettle();

        expect(find.text('Your upcoming trips:'), findsOneWidget);
        expect(find.text('Oslo'), findsOneWidget);
        expect(find.text('Barcelona'), findsOneWidget);
      },
    );

    testWidgets(
      'UI-05d: zobrazí sekciu "History of trips:" pre FINISHED tripy',
      (tester) async {
        await tester.pumpWidget(
          buildHome(trips: [
            _makeTrip(name: 'Paris 2025', status: TripStatus.finished),
          ]),
        );
        await tester.pumpAndSettle();

        expect(find.text('History of trips:'), findsOneWidget);
        expect(find.text('Paris 2025'), findsOneWidget);
      },
    );

    testWidgets(
      'UI-05e: ACTIVE tripy sú v "upcoming", FINISHED v "history" súčasne',
      (tester) async {
        await tester.pumpWidget(
          buildHome(trips: [
            _makeTrip(name: 'Active Trip', status: TripStatus.active),
            _makeTrip(id: 'trip-2', name: 'Old Trip', status: TripStatus.finished),
          ]),
        );
        await tester.pumpAndSettle();

        expect(find.text('Your upcoming trips:'), findsOneWidget);
        expect(find.text('History of trips:'), findsOneWidget);
        expect(find.text('Active Trip'), findsOneWidget);
        expect(find.text('Old Trip'), findsOneWidget);
      },
    );

    testWidgets(
      'UI-05f: empty state sa nezobrazí keď tripy existujú',
      (tester) async {
        await tester.pumpWidget(
          buildHome(trips: [_makeTrip()]),
        );
        await tester.pumpAndSettle();

        expect(find.text('No trips yet'), findsNothing);
      },
    );
  });
}