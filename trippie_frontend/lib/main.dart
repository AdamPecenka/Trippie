import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippie_frontend/app/app.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
import 'package:trippie_frontend/features/trip/data/activity_repository.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';
import 'package:trippie_frontend/shared/providers/connectivity_provider.dart';
import 'package:trippie_frontend/shared/services/location_sharing_service.dart';
import 'package:trippie_frontend/shared/services/offline_queue_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trippie_frontend/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
    ref.read(isOnlineProvider); // kick off connectivity stream
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

  Future<void> _syncOfflineQueue() async {
    final queue = OfflineQueueService();
    final pending = await queue.getAll();
    if (pending.isEmpty) return;

    debugPrint('[i] syncing ${pending.length} offline activities');
    final repo = ref.read(activityRepositoryProvider);

    for (final activity in pending) {
      try {
        switch (activity.operation) {
          case OfflineOperation.create:
            await repo.createActivity(
              activity.tripId,
              CreateActivityRequestDto(
                name: activity.name,
                placeId: activity.placeId,
                activityDate: activity.activityDate,
                startTime: activity.startTime,
                endTime: activity.endTime,
                notes: activity.notes,
              ),
            );
            break;
          case OfflineOperation.update:
            await repo.patchActivity(
              activity.tripId,
              activity.activityId!,
              CreateActivityRequestDto(
                name: activity.name,
                placeId: activity.placeId,
                activityDate: activity.activityDate,
                startTime: activity.startTime,
                endTime: activity.endTime,
                notes: activity.notes,
              ),
            );
            break;
          case OfflineOperation.delete:
            await repo.deleteActivity(
              activity.tripId,
              activity.activityId!,
            );
            break;
        }
        await queue.remove(activity.localId);
        ref.invalidate(tripActivitiesProvider(activity.tripId));
        debugPrint('[+] offline synced: ${activity.operation.name} ${activity.localId}');
      } on OfflineQueuedException {
        // still offline, repo re-queued it — stop draining
        debugPrint('[i] still offline during sync, stopping');
        break;
      } catch (e) {
        // 4xx or other server error — discard
        await queue.remove(activity.localId);
        debugPrint('[!] conflict discarded: ${activity.localId} — $e');
      }
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

    // auto-sync when connectivity restored
    ref.listen(isOnlineProvider, (previous, next) {
      if (previous == false && next == true) {
        debugPrint('[i] connectivity restored, syncing offline queue');
        _syncOfflineQueue();
      }
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