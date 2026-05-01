class MemberLastLocationDto {
  const MemberLastLocationDto({
    required this.userId,
    required this.firstname,
    required this.lastname,
    this.latitude,
    this.longitude,
  });

  final String userId;
  final String firstname;
  final String lastname;
  final double? latitude;
  final double? longitude;

  factory MemberLastLocationDto.fromJson(Map<String, dynamic> json) {
    return MemberLastLocationDto(
      userId: json['userId'] as String,
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}