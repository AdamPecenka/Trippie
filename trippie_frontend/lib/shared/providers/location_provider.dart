import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trippie_frontend/shared/services/location_service.dart';

part 'location_provider.g.dart';

@Riverpod(keepAlive: true)
LocationService locationService(Ref ref) {
  return LocationService();
}

@riverpod
Future<Position?> currentPosition(Ref ref) async {
  final service = ref.watch(locationServiceProvider);
  return service.getCurrentPosition();
}