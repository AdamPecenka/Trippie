import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trippie_frontend/app/router.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/map/presentation/widgets/no_active_trip_banner.dart';
import 'package:trippie_frontend/features/map/presentation/widgets/no_location_view.dart';
import 'package:trippie_frontend/features/map/presentation/widgets/place_bottom_sheet.dart';
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

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(tripsProvider);
    final positionAsync = ref.watch(currentPositionProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: tripsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error: $e')),
        data: (trips) {
          final activeTrip = _getActiveTrip(trips);
          final activitiesAsync = activeTrip != null
              ? ref.watch(tripActivitiesProvider(activeTrip.id))
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
                ],
              );
            },
          );
        },
      ),
    );
  }
}
