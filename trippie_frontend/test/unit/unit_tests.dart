// test/unit/unit_tests.dart
//
// Spustenie: flutter test test/unit/unit_tests.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trippie_frontend/core/utils/trip_utils.dart';
import 'package:trippie_frontend/core/utils/flight_utils.dart';
import 'package:trippie_frontend/core/utils/member_utils.dart';
import 'package:trippie_frontend/features/trip/data/trip_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_enums.dart';

class ActivityUtils {
  ActivityUtils._();

  static bool hasInvalidTime(TimeOfDay? start, TimeOfDay? end) {
    if (start == null || end == null) return false;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes <= startMinutes;
  }

  static String toApiDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String toApiTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }
}

// ── Helper pre fake TripDto ───────────────────────────────────────────────────

TripDto _trip({
  required String name,
  required TripStatus status,
  DateTime? startDate,
}) =>
    TripDto(
      id: name,
      name: name,
      status: status,
      startDate: startDate ?? DateTime(2026, 3, 1),
      endDate: DateTime(2026, 3, 7),
      destination: 'Test',
    );

// ── Testy ─────────────────────────────────────────────────────────────────────

void main() {

  // ══════════════════════════════════════════════════════════════════════════
  // UT-01..03 | ActivityUtils
  // ══════════════════════════════════════════════════════════════════════════

  group('UT-01..03 | ActivityUtils', () {

    test(
      'UT-01: hasInvalidTime — vráti true keď endTime je pred startTime',
      () {
        final start = const TimeOfDay(hour: 14, minute: 0);
        final end   = const TimeOfDay(hour: 12, minute: 0);

        expect(ActivityUtils.hasInvalidTime(start, end), isTrue);
      },
    );

    test(
      'UT-01b: hasInvalidTime — vráti true keď endTime == startTime (rovnaký čas)',
      () {
        const time = TimeOfDay(hour: 10, minute: 30);

        expect(ActivityUtils.hasInvalidTime(time, time), isTrue);
      },
    );

    test(
      'UT-01c: hasInvalidTime — vráti false keď endTime je po startTime',
      () {
        final start = const TimeOfDay(hour: 9,  minute: 0);
        final end   = const TimeOfDay(hour: 11, minute: 0);

        expect(ActivityUtils.hasInvalidTime(start, end), isFalse);
      },
    );

    test(
      'UT-01d: hasInvalidTime — vráti false keď niektorý čas je null',
      () {
        expect(
          ActivityUtils.hasInvalidTime(null, const TimeOfDay(hour: 10, minute: 0)),
          isFalse,
        );
        expect(
          ActivityUtils.hasInvalidTime(const TimeOfDay(hour: 10, minute: 0), null),
          isFalse,
        );
        expect(ActivityUtils.hasInvalidTime(null, null), isFalse);
      },
    );

    test(
      'UT-02: toApiDate — správne formátuje DateTime na "YYYY-MM-DD"',
      () {
        expect(
          ActivityUtils.toApiDate(DateTime(2026, 2, 4)),
          equals('2026-02-04'),
        );
        expect(
          ActivityUtils.toApiDate(DateTime(2026, 12, 31)),
          equals('2026-12-31'),
        );
        // Jednociferný mesiac a deň — musí mať nulu
        expect(
          ActivityUtils.toApiDate(DateTime(2026, 1, 5)),
          equals('2026-01-05'),
        );
      },
    );

    test(
      'UT-03: toApiTime — správne formátuje TimeOfDay na "HH:MM:00"',
      () {
        expect(
          ActivityUtils.toApiTime(const TimeOfDay(hour: 9, minute: 5)),
          equals('09:05:00'),
        );
        expect(
          ActivityUtils.toApiTime(const TimeOfDay(hour: 23, minute: 59)),
          equals('23:59:00'),
        );
        // Polnoc
        expect(
          ActivityUtils.toApiTime(const TimeOfDay(hour: 0, minute: 0)),
          equals('00:00:00'),
        );
      },
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // UT-04..06 | TripUtils
  // ══════════════════════════════════════════════════════════════════════════

  group('UT-04..06 | TripUtils', () {

    test(
      'UT-04: upcomingTrips — vráti iba PLANNING a ACTIVE tripy',
      () {
        final trips = [
          _trip(name: 'Planning', status: TripStatus.planning),
          _trip(name: 'Active',   status: TripStatus.active),
          _trip(name: 'Finished', status: TripStatus.finished),
        ];

        final result = TripUtils.upcomingTrips(trips);

        expect(result.length, 2);
        expect(result.any((t) => t.name == 'Finished'), isFalse);
        expect(result.any((t) => t.name == 'Planning'), isTrue);
        expect(result.any((t) => t.name == 'Active'),   isTrue);
      },
    );

    test(
      'UT-05: historyTrips — vráti iba FINISHED tripy, najnovšie prvé',
      () {
        final trips = [
          _trip(name: 'Old',    status: TripStatus.finished, startDate: DateTime(2025, 1, 1)),
          _trip(name: 'Recent', status: TripStatus.finished, startDate: DateTime(2025, 6, 1)),
          _trip(name: 'Active', status: TripStatus.active),
        ];

        final result = TripUtils.historyTrips(trips);

        expect(result.length, 2);
        expect(result.first.name, equals('Recent')); // novší je prvý
        expect(result.last.name,  equals('Old'));
        expect(result.any((t) => t.name == 'Active'), isFalse);
      },
    );

    test(
      'UT-06: upcomingTrips — ACTIVE tripy sú pred PLANNING tripmi',
      () {
        final trips = [
          _trip(name: 'Planning A', status: TripStatus.planning, startDate: DateTime(2026, 1, 1)),
          _trip(name: 'Active',     status: TripStatus.active,   startDate: DateTime(2026, 6, 1)),
          _trip(name: 'Planning B', status: TripStatus.planning, startDate: DateTime(2026, 3, 1)),
        ];

        final result = TripUtils.upcomingTrips(trips);

        // Active musí byť prvý bez ohľadu na dátum
        expect(result.first.name, equals('Active'));
        // PLANNING tripy zoradené podľa dátumu
        expect(result[1].name, equals('Planning A'));
        expect(result[2].name, equals('Planning B'));
      },
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // UT-07..08 | FlightUtils
  // ══════════════════════════════════════════════════════════════════════════

  group('UT-07..08 | FlightUtils', () {

    test(
      'UT-07: isTimeTravelError — vráti true keď prílet je pred odletom',
      () {
        final departure = DateTime(2026, 2, 24, 20, 45);
        final arrival   = DateTime(2026, 2, 24, 18, 0); // skôr ako odlet!

        expect(FlightUtils.isTimeTravelError(departure, arrival), isTrue);
      },
    );

    test(
      'UT-07b: isTimeTravelError — vráti false pri správnom poradí',
      () {
        final departure = DateTime(2026, 2, 24, 20, 45);
        final arrival   = DateTime(2026, 2, 24, 23, 10);

        expect(FlightUtils.isTimeTravelError(departure, arrival), isFalse);
      },
    );

    test(
      'UT-07c: isTimeTravelError — vráti false keď čas chýba',
      () {
        expect(FlightUtils.isTimeTravelError(null, DateTime.now()), isFalse);
        expect(FlightUtils.isTimeTravelError(DateTime.now(), null), isFalse);
      },
    );

    test(
      'UT-08: flightDuration — správne vypočíta trvanie letu',
      () {
        final departure = DateTime(2026, 2, 24, 20, 45);
        final arrival   = DateTime(2026, 2, 24, 23, 10);

        final duration = FlightUtils.flightDuration(departure, arrival);

        expect(duration, isNotNull);
        expect(duration!.inHours,          equals(2));
        expect(duration.inMinutes.remainder(60), equals(25));
      },
    );

    test(
      'UT-08b: flightDuration — vráti null keď je arrival pred departure',
      () {
        final departure = DateTime(2026, 2, 24, 23, 0);
        final arrival   = DateTime(2026, 2, 24, 20, 0);

        expect(FlightUtils.flightDuration(departure, arrival), isNull);
      },
    );

    test(
      'UT-08c: flightDuration — vráti null keď čas chýba',
      () {
        expect(FlightUtils.flightDuration(null, DateTime.now()), isNull);
        expect(FlightUtils.flightDuration(DateTime.now(), null), isNull);
      },
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // UT-09..10 | MemberUtils
  // ══════════════════════════════════════════════════════════════════════════

  group('UT-09..10 | MemberUtils', () {

    test(
      'UT-09: initials — vráti správne iniciály z mena a priezviska',
      () {
        expect(MemberUtils.initials('Veronika', 'Tilešová'), equals('VT'));
        expect(MemberUtils.initials('Adam',     'Pečenka'),  equals('AP'));
        expect(MemberUtils.initials('jana',     'nová'),     equals('JN')); // lowercase → uppercase
      },
    );

    test(
      'UT-10: initials — správne spracuje prázdne meno alebo priezvisko',
      () {
        expect(MemberUtils.initials('', 'Nová'),     equals('N'));
        expect(MemberUtils.initials('Jana', ''),     equals('J'));
        expect(MemberUtils.initials('', ''),         equals(''));
      },
    );
  });
}