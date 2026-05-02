class AirportDto {
  const AirportDto({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.iataCode,
  });

  final String id;
  final String name;
  final String city;
  final String country;
  final String iataCode;

  factory AirportDto.fromJson(Map<String, dynamic> json) => AirportDto(
        id: json['id'] as String,
        name: json['name'] as String,
        city: json['city'] as String,
        country: json['country'] as String,
        iataCode: json['iataCode'] as String,
      );

  String get displayName => '$iataCode — $city';
}

class FlightDto {
  const FlightDto({
    required this.id,
    required this.travelDirection,
    this.flightNumber,
    required this.departureIataCode,
    required this.departureCityName,
    required this.arrivalIataCode,
    required this.arrivalCityName,
    this.departureTime,
    this.arrivalTime,
  });

  final String id;
  final String travelDirection; // OUTBOUND / RETURN
  final String? flightNumber;
  final String departureIataCode;
  final String departureCityName;
  final String arrivalIataCode;
  final String arrivalCityName;
  final DateTime? departureTime;
  final DateTime? arrivalTime;

  factory FlightDto.fromJson(Map<String, dynamic> json) => FlightDto(
        id: json['id'] as String,
        travelDirection: json['travelDirection'] as String,
        flightNumber: json['flightNumber'] as String?,
        departureIataCode: json['departureIataCode'] as String,
        departureCityName: json['departureCityName'] as String,
        arrivalIataCode: json['arrivalIataCode'] as String,
        arrivalCityName: json['arrivalCityName'] as String,
        departureTime: json['departureTime'] != null
            ? DateTime.parse(json['departureTime'] as String)
            : null,
        arrivalTime: json['arrivalTime'] != null
            ? DateTime.parse(json['arrivalTime'] as String)
            : null,
      );

  String get routeLabel =>
      '$departureIataCode → $arrivalIataCode';

  bool get isOutbound => travelDirection == 'OUTBOUND';
}