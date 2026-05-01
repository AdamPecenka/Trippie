import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trippie_frontend/app/router.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/map/data/member_location.dart';
import 'package:trippie_frontend/features/map/data/member_locations_provider.dart';
import 'package:trippie_frontend/features/map/presentation/widgets/member_bottom_sheet.dart';
import 'package:trippie_frontend/features/map/presentation/widgets/no_active_trip_banner.dart';
import 'package:trippie_frontend/features/map/presentation/widgets/no_location_view.dart';
import 'package:trippie_frontend/features/map/presentation/widgets/place_bottom_sheet.dart';
import 'package:trippie_frontend/features/map/presentation/widgets/place_search_sheet.dart';
import 'package:trippie_frontend/features/map/presentation/widgets/trip_header.dart';
import 'package:trippie_frontend/features/trip/data/activity_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_dto.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';
import 'package:trippie_frontend/shared/providers/location_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _memberMarkers = {};
  final Map<String, BitmapDescriptor> _markerIconCache = {};
  bool _searchActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locations = ref.read(memberLocationsProvider);
      if (locations.isNotEmpty) {
        _rebuildMemberMarkers(locations);
      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  TripDto? _getActiveTrip(List<TripDto> trips) {
    final active = trips.where((t) => t.tripStatus == 'ACTIVE').toList();
    if (active.isEmpty) return null;
    active.sort((a, b) => b.startDate.compareTo(a.startDate));
    return active.first;
  }

  void _showPlaceBottomSheet(BuildContext context, PlaceDto place) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PlaceBottomSheet(place: place),
    );
  }

  void _showMemberBottomSheet(BuildContext context, MemberLocation member) {
    final position = ref
        .read(currentPositionProvider)
        .when(data: (pos) => pos, loading: () => null, error: (_, __) => null);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          MemberBottomSheet(member: member, currentPosition: position),
    );
  }

  Future<BitmapDescriptor> _buildInitialsMarker(
    String initials, {
    bool isOnline = true,
  }) async {
    const size = 96.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2,
      Paint()
        ..color = isOnline ? const Color(0xFF6B5FA6) : const Color(0xFF9E9E9E),
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  Future<void> _rebuildMemberMarkers(
    Map<String, MemberLocation> locations,
  ) async {
    final updated = <Marker>{};

    for (final loc in locations.values) {
      final cacheKey = '${loc.userId}_${loc.isOnline}';
      if (!_markerIconCache.containsKey(cacheKey)) {
        _markerIconCache[cacheKey] = await _buildInitialsMarker(
          loc.initials,
          isOnline: loc.isOnline,
        );
      }
      updated.add(
        Marker(
          markerId: MarkerId('member_${loc.userId}'),
          position: LatLng(loc.latitude, loc.longitude),
          icon: _markerIconCache[cacheKey]!,
          onTap: () => _showMemberBottomSheet(context, loc),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _memberMarkers = updated;
      });
    }
  }

  Future<void> _openSearch() async {
    final position = ref
        .read(currentPositionProvider)
        .when(data: (pos) => pos, loading: () => null, error: (_, __) => null);

    final PlaceDto? place = await showModalBottomSheet<PlaceDto>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: PlaceSearchSheet(currentPosition: position),
      ),
    );

    if (place == null) return;

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(place.latitude, place.longitude),
          zoom: 16,
        ),
      ),
    );

    if (mounted) {
      _showPlaceBottomSheet(context, place);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(tripsProvider);
    final positionAsync = ref.watch(currentPositionProvider);

    ref.listen(memberLocationsProvider, (_, next) {
      _rebuildMemberMarkers(next);
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: tripsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error: $e')),
        data: (trips) {
          final activeTrip = _getActiveTrip(trips);
          final activitiesAsync = activeTrip != null
              ? ref.watch(activeTripActivitiesProvider(activeTrip.id))
              : null;

          return positionAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, __) => NoLocationView(),
            data: (position) {
              if (position == null) {
                return NoLocationView();
              }

              final initialPosition = LatLng(
                position.latitude,
                position.longitude,
              );

              final markers = <Marker>{};

              if (activitiesAsync != null) {
                activitiesAsync.whenData((activities) {
                  for (final activity in activities) {
                    if (activity.place != null) {
                      markers.add(
                        Marker(
                          markerId: MarkerId(activity.id),
                          position: LatLng(
                            activity.place!.latitude,
                            activity.place!.longitude,
                          ),
                          onTap: () =>
                              _showPlaceBottomSheet(context, activity.place!),
                        ),
                      );
                    }
                  }
                });
              }

              markers.addAll(_memberMarkers);

              return Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: initialPosition,
                      zoom: 14,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                    markers: markers,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                  ),
                  if (activeTrip != null)
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 16,
                      right: 16,
                      child: TripHeader(
                        trip: activeTrip,
                        onBack: () => context.go(AppRoutes.home),
                      ),
                    ),
                  if (activeTrip == null)
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 16,
                      right: 16,
                      child: NoActiveTripBanner(),
                    ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 88,
                    right: 16,
                    child: FloatingActionButton.small(
                      onPressed: () async {
                        final pos = await ref
                            .read(locationServiceProvider)
                            .getCurrentPosition();
                        if (pos != null && _mapController != null) {
                          _mapController!.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(pos.latitude, pos.longitude),
                                zoom: 15,
                              ),
                            ),
                          );
                        }
                      },
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkCardBackground
                          : AppColors.cardBackground,
                      child: Icon(
                        Icons.my_location,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: MediaQuery.of(context).viewPadding.bottom + 112,
                    right: 16,
                    child: FloatingActionButton(
                      heroTag: 'search',
                      onPressed: _openSearch,
                      backgroundColor: AppColors.buttonPrimary,
                      foregroundColor: AppColors.buttonPrimaryText,
                      child: const Icon(Icons.search),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
