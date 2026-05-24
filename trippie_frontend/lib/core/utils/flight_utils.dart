// lib/core/utils/flight_utils.dart
//
// Čistá logika pre validáciu letov a výpočet trvania.
// Extrahované z AddFlightScreen pre testovateľnosť.

class FlightUtils {
  FlightUtils._();

  /// Vráti true ak prílet je pred odletom (time travel error).
  /// Ak niektorý čas chýba, vráti false.
  static bool isTimeTravelError(DateTime? departure, DateTime? arrival) {
    if (departure == null || arrival == null) return false;
    return arrival.isBefore(departure);
  }

  /// Vráti trvanie letu ako [Duration].
  /// Vráti null ak chýba odlet alebo prílet, alebo ak je rozdiel záporný.
  static Duration? flightDuration(DateTime? departure, DateTime? arrival) {
    if (departure == null || arrival == null) return null;
    final d = arrival.difference(departure);
    return d.isNegative ? null : d;
  }
}