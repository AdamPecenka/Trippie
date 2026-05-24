// test/widget/trip_members_screen_test.dart
//
// Spustenie: flutter test test/widget/trip_members_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trippie_frontend/features/trip/presentation/trip_members_screen.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';
import 'package:trippie_frontend/features/trip/data/trip_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_enums.dart';
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
  status: TripStatus.planning,  // nie active → onTap na členov = null
  startDate: DateTime(2026, 2, 24),
  endDate: DateTime(2026, 2, 28),
  destination: 'Barcelona',
);

TripMemberDto _manager() => TripMemberDto(
      userId: 'manager-1',
      firstname: 'Veronika',
      lastname: 'Tilešová',
      email: 'v@test.com',
      tripRole: 'TRIP_MANAGER',
      joinedAt: DateTime(2026, 2, 24),
    );

TripMemberDto _member({
  String userId = 'member-1',
  String firstname = 'Adam',
  String lastname = 'Pečenka',
  String email = 'adam@test.com',
}) =>
    TripMemberDto(
      userId: userId,
      firstname: firstname,
      lastname: lastname,
      email: email,
      tripRole: 'TRIP_MEMBER',
      joinedAt: DateTime(2026, 2, 24),
    );

// ── Helper ────────────────────────────────────────────────────────────────────

Widget buildMembers({
  List<TripMemberDto> members = const [],
  List<TripDto> trips = const [],
}) {
  final allMembers = members;
  return ProviderScope(
    overrides: [
      tripsProvider.overrideWith(
        () => _FakeTripsNotifier(trips.isEmpty ? [_fakeTrip] : trips),
      ),
      tripMembersProvider(_tripId).overrideWith((ref) async => allMembers),
      // memberAvatarProvider — vráti null pre všetkých → zobrazí iniciály
      ...allMembers.map(
        (m) => memberAvatarProvider(m.userId).overrideWith((ref) async => null),
      ),
    ],
    child: const MaterialApp(
      home: TripMembersScreen(tripId: _tripId),
    ),
  );
}

// ── Testy ─────────────────────────────────────────────────────────────────────

void main() {
  group('UI-07 | TripMembersScreen', () {
    testWidgets(
      'UI-07a: zobrazí nadpis "Members" a tlačidlo "Invite"',
      (tester) async {
        await tester.pumpWidget(buildMembers(members: [_manager()]));
        await tester.pumpAndSettle();

        expect(find.text('Members'), findsOneWidget);
        expect(find.text('Invite'), findsOneWidget);
      },
    );

    testWidgets(
      'UI-07b: zobrazí sekciu "Trip Manager" a badge "Manager"',
      (tester) async {
        await tester.pumpWidget(buildMembers(members: [_manager()]));
        await tester.pumpAndSettle();

        expect(find.text('Trip Manager'), findsOneWidget);
        expect(find.text('Manager'), findsOneWidget);
      },
    );

    testWidgets(
      'UI-07c: zobrazí sekciu "Members" pre bežných členov',
      (tester) async {
        await tester.pumpWidget(
          buildMembers(members: [_manager(), _member()]),
        );
        await tester.pumpAndSettle();

        // "Members" sa objaví 2x: nadpis obrazovky + sekcia
        expect(find.text('Members'), findsAtLeastNWidgets(2));
      },
    );

    testWidgets(
      'UI-07d: zobrazí meno a email každého člena',
      (tester) async {
        await tester.pumpWidget(
          buildMembers(members: [_manager(), _member()]),
        );
        await tester.pumpAndSettle();

        expect(find.text('Veronika Tilešová'), findsOneWidget);
        expect(find.text('v@test.com'), findsOneWidget);
        expect(find.text('Adam Pečenka'), findsOneWidget);
        expect(find.text('adam@test.com'), findsOneWidget);
      },
    );

    testWidgets(
      'UI-07e: zobrazí iniciály keď nie je dostupný avatar',
      (tester) async {
        // memberAvatarProvider vracia null → _initialsWidget() sa zobrazí
        await tester.pumpWidget(buildMembers(members: [_manager()]));
        await tester.pumpAndSettle();

        // Manager má iniciály "VT" (Veronika Tilešová)
        expect(find.text('VT'), findsOneWidget);
      },
    );

    testWidgets(
      'UI-07f: badge "Manager" sa nezobrazí pre bežného člena',
      (tester) async {
        await tester.pumpWidget(buildMembers(members: [_member()]));
        await tester.pumpAndSettle();

        expect(find.text('Manager'), findsNothing);
      },
    );
  });
}