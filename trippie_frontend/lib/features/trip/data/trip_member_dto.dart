class TripMemberDto {
  const TripMemberDto({
    required this.userId,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.tripRole,
    required this.joinedAt,
  });

  final String userId;
  final String firstname;
  final String lastname;
  final String email;
  final String tripRole;
  final DateTime joinedAt;

  factory TripMemberDto.fromJson(Map<String, dynamic> json) {
    return TripMemberDto(
      userId: json['userId'] as String,
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
      email: json['email'] as String,
      tripRole: json['tripRole'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }
}