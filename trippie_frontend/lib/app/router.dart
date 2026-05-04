// lib/app/router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
import 'package:trippie_frontend/features/auth/presentation/login_screen.dart';
import 'package:trippie_frontend/features/auth/presentation/register_screen.dart';
import 'package:trippie_frontend/features/auth/presentation/splash_screen.dart';
import 'package:trippie_frontend/features/profile/presentation/my_account_screen.dart';
import 'package:trippie_frontend/features/trip/presentation/enter_code_screen.dart';
import 'package:trippie_frontend/features/trip/presentation/home_screen.dart';
import 'package:trippie_frontend/features/trip/presentation/invite_screen.dart';
import 'package:trippie_frontend/features/trip/presentation/join_screen.dart';
import 'package:trippie_frontend/features/trip/presentation/join_success_screen.dart';
import 'package:trippie_frontend/features/trip/presentation/scan_qr_screen.dart';
import 'package:trippie_frontend/features/trip/presentation/trip_detail_screen.dart';
import 'package:trippie_frontend/features/trip/presentation/trip_hub_screen.dart';
import 'package:trippie_frontend/features/trip/presentation/create_trip_screen.dart';
import 'package:trippie_frontend/features/map/presentation/map_screen.dart';
import 'package:trippie_frontend/features/profile/presentation/profile_screen.dart';
import 'package:trippie_frontend/features/profile/presentation/favorites_screen.dart';
import 'package:trippie_frontend/shared/widgets/bottom_navbar.dart';
import 'package:trippie_frontend/features/trip/presentation/add_activity_screen.dart';
import 'package:trippie_frontend/features/trip/presentation/activity_success_screen.dart';
import 'package:trippie_frontend/features/trip/presentation/edit_activity_screen.dart';
import 'package:trippie_frontend/features/trip/presentation/flights_screen.dart';
import 'package:trippie_frontend/features/trip/presentation/add_flight_screen.dart';
import 'package:trippie_frontend/features/trip/presentation/trip_members_screen.dart';
import 'package:trippie_frontend/features/trip/data/activity_dto.dart';

part 'router.g.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';

  static const String home = '/home';
  static const String map = '/map';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String myAccount = '/profile/account';

  static const String createTrip = '/home/create';
  static const String joinTrip = '/home/join';
  static const String tripDetail = '/home/trip/:tripId';
  static const String tripHub = '/home/trip/:tripId/hub';
  static const String tripMembers = '/home/trip/:tripId/members';
  static const String invite = '/home/trip/:tripId/invite';
  static const String createActivity = '/home/trip/:tripId/activity/create';
  static const String scanQr = '/home/join/scan';
  static const String enterCode = '/home/join/code';
  static const String joinSuccess = '/home/join/success/:tripId/:tripName';

  // Top-level routes (no bottom navbar — full-screen flows)
  static const String tripFlights = '/home/trip/:tripId/flights';
  static const String tripAccommodation = '/home/trip/:tripId/accommodation';
}

final appNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(Ref ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: appNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final isOnAuthScreen =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.splash;

      if (authState.isLoading && state.matchedLocation == AppRoutes.splash) {
        return null;
      }
      if (authState.isLoading && isOnAuthScreen) {
        return null;
      }

      final isAuthenticated = authState is AsyncData && authState.value != null;

      if (!isAuthenticated && !isOnAuthScreen) {
        return AppRoutes.login;
      }
      if (isAuthenticated && isOnAuthScreen) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // ── Auth ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.myAccount,
        builder: (context, state) => const MyAccountScreen(),
      ),

      // ── Full-screen trip sub-screens (no bottom navbar) ──────────────────
      GoRoute(
        path: '/home/trip/:tripId/flights',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          return FlightsScreen(tripId: tripId);
        },
      ),
      GoRoute(
        path: '/home/trip/:tripId/flights/add',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          return AddFlightScreen(tripId: tripId);
        },
      ),
      // AddAccommodationScreen navigated imperatively (needs trip dates from provider).

      // ── Main shell (with bottom navbar) ──────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return BottomNavbar(navigationShell: navigationShell);
            },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (context, state) => const CreateTripScreen(),
                  ),
                  GoRoute(
                    path: 'join',
                    builder: (context, state) => const JoinScreen(),
                    routes: [
                      GoRoute(
                        path: 'scan',
                        builder: (context, state) => const ScanQrScreen(),
                      ),
                      GoRoute(
                        path: 'code',
                        builder: (context, state) => const EnterCodeScreen(),
                      ),
                      GoRoute(
                        path: 'success/:tripId/:tripName',
                        builder: (context, state) {
                          final tripId = state.pathParameters['tripId']!;
                          final tripName = Uri.decodeComponent(
                            state.pathParameters['tripName']!,
                          );
                          return JoinSuccessScreen(
                            tripId: tripId,
                            tripName: tripName,
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'trip/:tripId',
                    // Default: activities view
                    builder: (context, state) {
                      final tripId = state.pathParameters['tripId']!;
                      return TripDetailScreen(tripId: tripId);
                    },
                    routes: [
                      // Hub: flights, accommodation, members, map
                      GoRoute(
                        path: 'hub',
                        builder: (context, state) {
                          final tripId = state.pathParameters['tripId']!;
                          return TripHubScreen(tripId: tripId);
                        },
                      ),
                      GoRoute(
                        path: 'members',
                        builder: (context, state) {
                          final tripId = state.pathParameters['tripId']!;
                          return TripMembersScreen(tripId: tripId);
                        },
                      ),
                      GoRoute(
                        path: 'invite',
                        builder: (context, state) {
                          final tripId = state.pathParameters['tripId']!;
                          return InviteScreen(tripId: tripId);
                        },
                      ),
                      GoRoute(
                        path: 'activity/create',
                        builder: (context, state) {
                          final tripId = state.pathParameters['tripId']!;
                          final place = state.extra as PlaceDto?;
                          return AddActivityScreen(
                            tripId: tripId,
                            initialPlace: place,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'activity/success',
                        builder: (context, state) {
                          final tripId = state.pathParameters['tripId']!;
                          return ActivitySuccessScreen(tripId: tripId);
                        },
                      ),
                      GoRoute(
                        path: 'activity/:activityId/edit',
                        builder: (context, state) {
                          final tripId = state.pathParameters['tripId']!;
                          final activityId =
                              state.pathParameters['activityId']!;
                          return EditActivityScreen(
                            tripId: tripId,
                            activityId: activityId,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'map',
                        builder: (context, state) {
                          final tripId = state.pathParameters['tripId']!;
                          final memberId =
                              state.uri.queryParameters['memberId'];
                          return MapScreen(tripId: tripId, memberId: memberId);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.map,
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.favorites,
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
