import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:trippie_frontend/core/config/app_config.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
import 'package:trippie_frontend/features/map/data/member_locations_provider.dart';
import 'package:trippie_frontend/features/trip/data/trip_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';
import 'package:trippie_frontend/shared/providers/location_provider.dart';
import 'package:trippie_frontend/shared/providers/trip_hub_provider.dart';
import 'package:trippie_frontend/features/trip/data/trip_enums.dart';


class LocationSharingService {
  LocationSharingService(this._ref);

  final WidgetRef _ref;
  Timer? _locationTimer;
  bool _hubInitialized = false;

  Future<void> initHub(List<TripDto> trips) async {
    if (_hubInitialized) return;

    final activeTrips = trips.where((t) => t.status == TripStatus.active).toList();
    if (activeTrips.isEmpty) return;

    final hub = _ref.read(tripHubProvider);

    try {
      await hub.connect();
    } catch (e) {
      debugPrint('[E] hub: connect failed — $e');
      return;
    }

    final currentUserId = _ref
        .read(authProvider)
        .when(
          data: (data) => data?.id,
          loading: () => null,
          error: (_, __) => null,
        );

    for (final trip in activeTrips) {
      await hub.joinRoom(trip.id);
      _ref.read(activeTripMembersProvider(trip.id));
      _ref.read(activeTripActivitiesProvider(trip.id));
      _ref.read(activeTripAccommodationProvider(trip.id));

      try {
        final lastLocations = await _ref
            .read(tripRepositoryProvider)
            .getLastKnownLocations(trip.id);

        for (final loc in lastLocations) {
          if (loc.latitude != null && loc.longitude != null) {
            _ref
                .read(memberLocationsProvider.notifier)
                .update(
                  userId: loc.userId,
                  firstname: loc.firstname,
                  lastname: loc.lastname,
                  latitude: loc.latitude!,
                  longitude: loc.longitude!,
                  isOnline: false,
                );
          }
        }
        debugPrint(
          '[i] seeded ${lastLocations.length} last known locations for trip:${trip.id}',
        );
      } catch (e) {
        debugPrint(
          '[E] failed to seed last known locations for trip:${trip.id} — $e',
        );
      }
    }

    hub.onLocationUpdated((args) {
      if (args == null || args.isEmpty) return;
      final payload = args[0] as Map<String, dynamic>;
      final userId = payload['userId'] as String;
      final latitude = (payload['latitude'] as num).toDouble();
      final longitude = (payload['longitude'] as num).toDouble();

      String firstname = '';
      String lastname = '';
      for (final trip in activeTrips) {
        final members = _ref
            .read(activeTripMembersProvider(trip.id))
            .when(
              data: (data) => data,
              loading: () => null,
              error: (_, __) => null,
            );
        final match = members?.where((m) => m.userId == userId).firstOrNull;
        if (match != null) {
          firstname = match.firstname;
          lastname = match.lastname;
          break;
        }
      }

      _ref
          .read(memberLocationsProvider.notifier)
          .update(
            userId: userId,
            firstname: firstname,
            lastname: lastname,
            latitude: latitude,
            longitude: longitude,
          );
    });

    hub.onLocationOffline((args) {
      if (args == null || args.isEmpty) return;
      final payload = args[0] as Map<String, dynamic>;
      final userId = payload['userId'] as String;
      if (userId == currentUserId) return;
      _ref.read(memberLocationsProvider.notifier).markOffline(userId);
    });

    _startSharing(activeTrips.map((t) => t.id).toList());

    _hubInitialized = true;
    debugPrint('[+] hub: initialized for ${activeTrips.length} active trip(s)');
  }

  void _startSharing(List<String> tripIds) {
    _locationTimer?.cancel();
    _pushLocation(tripIds);
    _locationTimer = Timer.periodic(
      const Duration(seconds: AppConfig.locationSharingIntervalSeconds),
      (_) => _pushLocation(tripIds),
    );
  }

  Future<void> _pushLocation(List<String> tripIds) async {
    final hub = _ref.read(tripHubProvider);

    if (hub.connection.state != HubConnectionState.Connected) {
      debugPrint(
        '[i] hub: not connected (state: ${hub.connection.state}), skipping push',
      );
      return;
    }

    final position = await _ref
        .read(locationServiceProvider)
        .getCurrentPosition();
    if (position == null) {
      debugPrint('[!] location: no permission, skipping push');
      return;
    }

    for (final tripId in tripIds) {
      try {
        await hub.connection.invoke(
          'location:update',
          args: [tripId, position.latitude, position.longitude],
        );
        debugPrint(
          '[~] location pushed | trip:$tripId lat:${position.latitude} lng:${position.longitude}',
        );
      } catch (e) {
        debugPrint('[E] location push failed | trip:$tripId — $e');
      }
    }
  }

  Future<void> sendLastLocation() async {
    try {
      final position = await _ref
          .read(locationServiceProvider)
          .getCurrentPosition();
      if (position == null) return;

      final trips = _ref
          .read(tripsProvider)
          .when(
            data: (data) => data,
            loading: () => null,
            error: (_, __) => null,
          );
      if (trips == null || trips.isEmpty) return;

      final activeTrips = trips.where((t) => t.status == TripStatus.active).toList();
      if (activeTrips.isEmpty) return;

      final apiService = _ref.read(apiServiceProvider);

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

  Future<void> reconnectIfNeeded() async {
    final hub = _ref.read(tripHubProvider);

    if (hub.connection.state == HubConnectionState.Connected) {
      debugPrint('[i] hub: already connected on resume');
      return;
    }

    debugPrint('[i] hub: reconnecting on resume');

    final trips = _ref
        .read(tripsProvider)
        .when(
          data: (data) => data,
          loading: () => null,
          error: (_, __) => null,
        );
    if (trips == null) return;

    final activeTrips = trips.where((t) => t.status == TripStatus.active).toList();
    if (activeTrips.isEmpty) return;

    try {
      await hub.connect();
      for (final trip in activeTrips) {
        await hub.joinRoom(trip.id);
      }
      debugPrint('[+] hub: reconnected and rejoined rooms on resume');
    } catch (e) {
      debugPrint('[E] hub: failed to reconnect on resume — $e');
    }
  }

  void resetOnLogout() {
    _hubInitialized = false;
    _locationTimer?.cancel();
    _locationTimer = null;
    debugPrint('[-] location sharing: reset on logout');
  }
}