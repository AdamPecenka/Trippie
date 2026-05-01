class AccommodationDto {
  const AccommodationDto({
    required this.id,
    required this.placeName,
    this.address,
    this.checkIn,
    this.checkOut,
  });

  final String id;
  final String placeName;
  final String? address;
  final DateTime? checkIn;
  final DateTime? checkOut;

  factory AccommodationDto.fromJson(Map<String, dynamic> json) {
    return AccommodationDto(
      id: json['id'] as String,
      placeName: json['placeName'] as String,
      address: json['address'] as String?,
      checkIn: json['checkIn'] != null
          ? DateTime.parse(json['checkIn'] as String)
          : null,
      checkOut: json['checkOut'] != null
          ? DateTime.parse(json['checkOut'] as String)
          : null,
    );
  }
}