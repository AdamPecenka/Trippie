import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippie_frontend/app/app.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';
import 'package:trippie_frontend/shared/providers/location_provider.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    debugPrint('[E] Flutter error: ${details.exceptionAsString()}');
    debugPrint('[E] Stack: ${details.stack}');
  };

  runApp(ProviderScope(child: _AppWithLifecycle()));
}

class _AppWithLifecycle extends ConsumerStatefulWidget {
  const _AppWithLifecycle();

  @override
  ConsumerState<_AppWithLifecycle> createState() => _AppWithLifecycleState();
}

class _AppWithLifecycleState extends ConsumerState<_AppWithLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _sendLastLocation();
    }
  }

  Future<void> _sendLastLocation() async {
    try {
      final locationService = ref.read(locationServiceProvider);
      final position = await locationService.getCurrentPosition();
      if (position == null) {
        return;
      }

      final trips = ref
          .read(tripsProvider)
          .when(
            data: (data) => data,
            loading: () => null,
            error: (_, __) => null,
          );
      if (trips == null || trips.isEmpty) {
        return;
      }

      final activeTrips = trips.where((t) => t.tripStatus == 'ACTIVE').toList();
      if (activeTrips.isEmpty) {
        return;
      }

      final apiService = ref.read(apiServiceProvider);

      for (final trip in activeTrips) {
        await apiService.dio.post(
          '/api/location/trips/${trip.id}/me',
          data: {
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
        );
        debugPrint('[i] last location sent for trip: ${trip.id}');
      }
    } catch (e) {
      debugPrint('[E] Failed to send last location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}
