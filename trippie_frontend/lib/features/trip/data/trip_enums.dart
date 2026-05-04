enum TripStatus { planning, active, finished }

enum TripRole { tripManager, traveler }

enum TravelDirection { outbound, returnFlight }

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

extension TripRoleX on TripRole {
  static TripRole fromString(String value) {
    return switch (value.toUpperCase()) {
      'TRIP_MANAGER' => TripRole.tripManager,
      _              => TripRole.traveler,
    };
  }

  String get label => switch (this) {
    TripRole.tripManager => 'Trip manager',
    TripRole.traveler     => 'Traveler',
  };

  String get apiValue => switch (this) {
    TripRole.tripManager => 'TRIP_MANAGER',
    TripRole.traveler     => 'TRAVELER',
  };
}