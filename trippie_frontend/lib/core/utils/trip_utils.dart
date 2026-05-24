// lib/core/utils/trip_utils.dart
//
// Čistá logika pre filtrovanie a triedenie tripov.
// Extrahované z HomeScreen._TripList pre testovateľnosť.

import 'package:trippie_frontend/features/trip/data/trip_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_enums.dart';

class TripUtils {
  TripUtils._();

  /// Vráti tripy ktoré nie sú ukončené (PLANNING alebo ACTIVE),
  /// zoradené: ACTIVE tripy vždy prvé, potom podľa startDate vzostupne.
  static List<TripDto> upcomingTrips(List<TripDto> trips) {
    return trips
        .where((t) => t.status != TripStatus.finished)
        .toList()
      ..sort((a, b) {
        if (a.status == TripStatus.active && b.status != TripStatus.active) {
          return -1;
        }
        if (a.status != TripStatus.active && b.status == TripStatus.active) {
          return 1;
        }
        return a.startDate.compareTo(b.startDate);
      });
  }

  /// Vráti iba ukončené tripy (FINISHED),
  /// zoradené podľa startDate zostupne (najnovšie prvé).
  static List<TripDto> historyTrips(List<TripDto> trips) {
    return trips
        .where((t) => t.status == TripStatus.finished)
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }
}