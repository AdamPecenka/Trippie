import 'package:trippie_frontend/features/trip/data/trip_enums.dart';

class TripDto {
  const TripDto({
    required this.id,
    required this.name,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  final String id;
  final String name;
  final TripStatus status;
  final DateTime startDate;
  final DateTime endDate;

  factory TripDto.fromJson(Map<String, dynamic> json) {
    return TripDto(
      id: json['id'] as String,
      name: json['name'] as String,
      status: TripStatusX.fromString(json['tripStatus'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }
}