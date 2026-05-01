class MemberLocation {
  const MemberLocation({
    required this.userId,
    required this.firstname,
    required this.lastname,
    required this.latitude,
    required this.longitude,
    this.isOnline = true,
  });

  final String userId;
  final String firstname;
  final String lastname;
  final double latitude;
  final double longitude;
  final bool isOnline;

  String get initials {
    final f = firstname.isNotEmpty ? firstname[0].toUpperCase() : '';
    final l = lastname.isNotEmpty ? lastname[0].toUpperCase() : '';
    return '$f$l';
  }
}