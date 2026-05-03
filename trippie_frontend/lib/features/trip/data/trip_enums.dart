enum TripStatus { planning, active, finished }

extension TripStatusX on TripStatus {
  static TripStatus fromString(String value) {
    return switch (value.toUpperCase()) {
      'ACTIVE'   => TripStatus.active,
      'FINISHED' => TripStatus.finished,
      _          => TripStatus.planning
    };
  }

  String get label => switch (this) {
    TripStatus.planning => 'PLANNING',
    TripStatus.active   => 'ACTIVE',
    TripStatus.finished => 'FINISHED',
  };
}