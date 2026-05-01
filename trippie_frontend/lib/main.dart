import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippie_frontend/app/app.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';
import 'package:trippie_frontend/shared/services/location_sharing_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    HttpOverrides.global = _DevHttpOverrides();
  }

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
  late final LocationSharingService _locationSharing;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _locationSharing = LocationSharingService(ref);
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
      _locationSharing.sendLastLocation();
    }

    if (state == AppLifecycleState.resumed) {
      _locationSharing.reconnectIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      final wasLoggedIn = previous?.when(
            data: (data) => data != null,
            loading: () => false,
            error: (_, __) => false,
          ) ??
          false;

      final isNowLoggedOut = next.when(
        data: (data) => data == null,
        loading: () => false,
        error: (_, __) => false,
      );

      if (wasLoggedIn && isNowLoggedOut) {
        _locationSharing.resetOnLogout();
      }
    });

    ref.listen(tripsProvider, (previous, next) {
      next.whenData((trips) {
        final wasLoading = previous == null || previous.isLoading;
        if (!wasLoading) return;
        _locationSharing.initHub(trips);
      });
    });

    return const App();
  }
}

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}