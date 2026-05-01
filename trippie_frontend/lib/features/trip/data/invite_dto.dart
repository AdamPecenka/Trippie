class JoinTripDto {
  const JoinTripDto({required this.tripId, required this.tripName});

  final String tripId;
  final String tripName;

  factory JoinTripDto.fromJson(Map<String, dynamic> json) {
    return JoinTripDto(
      tripId: json['tripId'] as String,
      tripName: json['tripName'] as String,
    );
  }
}