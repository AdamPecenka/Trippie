class TripDto {
  const TripDto({
    required this.id,
    required this.name,
    required this.tripStatus,
    required this.startDate,
    required this.endDate,
  });

  final String id;
  final String name;
  final String tripStatus;
  final DateTime startDate;
  final DateTime endDate;

  factory TripDto.fromJson(Map<String, dynamic> json) {
    return TripDto(
      id: json['id'] as String,
      name: json['name'] as String,
      tripStatus: json['tripStatus'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }
}