import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trippie_frontend/shared/services/trip_hub_service.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';

part 'trip_hub_provider.g.dart';

@Riverpod(keepAlive: true)
TripHubService tripHub(Ref ref) {
  final authService = ref.watch(authServiceProvider);
  return TripHubService(authService);
}