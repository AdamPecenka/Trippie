enum TripStatus {
  planning,
  active,
  finished;

  String get label {
    switch (this) {
      case TripStatus.planning:
        return 'PLANNING';
      case TripStatus.active:
        return 'ACTIVE';
      case TripStatus.finished:
        return 'FINISHED';
    }
  }
}

enum TripRole {
  tripManager,
  tripMember,
}

enum TransportType {
  flight,
  car,
}