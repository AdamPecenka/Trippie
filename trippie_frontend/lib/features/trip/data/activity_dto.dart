class PlaceDto {
  const PlaceDto({
    required this.id,
    required this.name,
    this.address,
    this.city,
    this.country,
    required this.latitude,
    required this.longitude,
    this.googlePlaceId,
  });

  final String id;
  final String name;
  final String? address;
  final String? city;
  final String? country;
  final double latitude;
  final double longitude;
  final String? googlePlaceId;

  factory PlaceDto.fromJson(Map<String, dynamic> json) {
    return PlaceDto(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      googlePlaceId: json['googlePlaceId'] as String?,
    );
  }
}

class ActivityDto {
  const ActivityDto({
    required this.id,
    this.name,
    this.activityDate,
    this.startTime,
    this.endTime,
    this.notes,
    this.createdBy,
    this.place,
  });

  final String id;
  final String? name;
  final String? activityDate;
  final String? startTime;
  final String? endTime;
  final String? notes;
  final String? createdBy;
  final PlaceDto? place;

  factory ActivityDto.fromJson(Map<String, dynamic> json) {
    return ActivityDto(
      id: json['id'] as String,
      name: json['name'] as String?,
      activityDate: json['activityDate'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      notes: json['notes'] as String?,
      createdBy: json['createdBy'] as String?,
      place: json['place'] != null
          ? PlaceDto.fromJson(json['place'] as Map<String, dynamic>)
          : null,
    );
  }
}