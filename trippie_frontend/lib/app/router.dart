import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
import 'package:trippie_frontend/features/auth/presentation/login_screen.dart';
import 'package:trippie_frontend/features/auth/presentation/register_screen.dart';
import 'package:trippie_frontend/features/auth/presentation/splash_screen.dart';
import 'package:trippie_frontend/features/trip/presentation/home_screen.dart';
import 'package:trippie_frontend/features/map/presentation/map_screen.dart';
import 'package:trippie_frontend/features/profile/presentation/profile_screen.dart';
import 'package:trippie_frontend/features/profile/presentation/favorites_screen.dart';
import 'package:trippie_frontend/shared/widgets/bottom_navbar.dart';

part 'router.g.dart';

abstract final class AppRoutes {
  static const String splash    = '/';
  static const String login     = '/login';
  static const String register  = '/register';

  static const String home      = '/home';
  static const String map       = '/map';
  static const String favorites = '/favorites';
  static const String profile   = '/profile';

  static const String tripDetail  = '/home/trip/:tripId';
  static const String createTrip  = '/home/create';
  static const String tripMembers = '/home/trip/:tripId/members';
  static const String invite      = '/home/trip/:tripId/invite';
}

@riverpod
GoRouter router(Ref ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final isOnAuthScreen =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.splash;

      // During initial session restore, stay on splash
      if (authState.isLoading && state.matchedLocation == AppRoutes.splash) {
        return null;
      }

      // During login/register call, don't redirect away from auth screens
      if (authState.isLoading && isOnAuthScreen) {
        return null;
      }

      final isAuthenticated =
          authState is AsyncData && authState.value != null;

      if (!isAuthenticated && !isOnAuthScreen) {
        return AppRoutes.login;
      }

      if (isAuthenticated && isOnAuthScreen) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
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

      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
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
                    builder: (context, state) => const Scaffold(
                      body: Center(child: Text('Create Trip')),
                    ),
                  ),
                  GoRoute(
                    path: 'trip/:tripId',
                    builder: (context, state) {
                      final tripId = state.pathParameters['tripId']!;
                      return Scaffold(
                        body: Center(child: Text('Trip $tripId')),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'members',
                        builder: (context, state) {
                          final tripId = state.pathParameters['tripId']!;
                          return Scaffold(
                            body: Center(child: Text('Members $tripId')),
                          );
                        },
                      ),
                      GoRoute(
                        path: 'invite',
                        builder: (context, state) {
                          final tripId = state.pathParameters['tripId']!;
                          return Scaffold(
                            body: Center(child: Text('Invite $tripId')),
                          );
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