class PlaceSuggestionDto {
  const PlaceSuggestionDto({
    required this.googlePlaceId,
    required this.displayName,
  });

  final String googlePlaceId;
  final String displayName;

  factory PlaceSuggestionDto.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestionDto(
      googlePlaceId: json['googlePlaceId'] as String,
      displayName: json['displayName'] as String,
    );
  }
}