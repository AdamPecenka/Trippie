// lib/features/profile/data/favorite_dto.dart

class FavoritePlaceDto {
  const FavoritePlaceDto({
    required this.id,
    required this.name,
    this.address,
    this.city,
    this.country,
    this.googlePlaceId,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String name;
  final String? address;
  final String? city;
  final String? country;
  final String? googlePlaceId;
  final double? latitude;
  final double? longitude;

  factory FavoritePlaceDto.fromJson(Map<String, dynamic> json) {
    return FavoritePlaceDto(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      googlePlaceId: json['googlePlaceId'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  String get displayLocation {
    if (city != null && country != null) return '$city, $country';
    if (city != null) return city!;
    if (address != null) return address!;
    return '';
  }
}

class FavoriteDto {
  const FavoriteDto({required this.id, required this.place});

  final String id;
  final FavoritePlaceDto place;

  factory FavoriteDto.fromJson(Map<String, dynamic> json) {
    return FavoriteDto(
      id: json['id'] as String,
      place: FavoritePlaceDto.fromJson(json['place'] as Map<String, dynamic>),
    );
  }
}