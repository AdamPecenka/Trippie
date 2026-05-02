// lib/shared/widgets/bottom_navbar.dart

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippie_frontend/app/router.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/shared/providers/fab_provider.dart';

class BottomNavbar extends ConsumerStatefulWidget {
  const BottomNavbar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends ConsumerState<BottomNavbar> {
  void _onTabTapped(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  void _updateFab() {
    if (!mounted) return;
    // ✅ GoRouterState.of je spoľahlivejší — reaguje aj na pop()
    final location = GoRouterState.of(context).uri.path;

    if (location == AppRoutes.home) {
      ref.read(fabProvider.notifier).setActions([
        FabAction(
          label: 'Create trip',
          onTap: () => context.go(AppRoutes.createTrip),
        ),
        FabAction(
          label: 'Join a trip',
          onTap: () => context.go(AppRoutes.joinTrip),
        ),
      ]);
    } else if (location.startsWith('/home/trip/') &&
        !location.endsWith('/invite') &&
        !location.endsWith('/activity/create') &&
        !location.endsWith('/activity/success')) {
      final tripId = location.split('/')[3];
      ref.read(fabProvider.notifier).setActions([
        FabAction(
          label: 'Add activity',
          onTap: () => context.push(
            AppRoutes.createActivity.replaceFirst(':tripId', tripId),
          ),
        ),
        FabAction(
          label: 'Invite friends',
          onTap: () =>
              context.push(AppRoutes.invite.replaceFirst(':tripId', tripId)),
        ),
      ]);
    } else {
      ref.read(fabProvider.notifier).clear();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GoRouter.of(context).routeInformationProvider.addListener(_updateFab);
      _updateFab();
    });
  }

  @override
  void dispose() {
    GoRouter.of(context).routeInformationProvider.removeListener(_updateFab);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ zachytí pop() ktorý nespustí routeInformationProvider listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateFab();
    });
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: widget.navigationShell,
      floatingActionButton: Consumer(
        builder: (context, ref, _) {
          final fabState = ref.watch(fabProvider);
          if (fabState.actions.isEmpty) return const SizedBox.shrink();
          return _SpeedDialFab(
            actions: fabState.actions,
            isOpen: fabState.isOpen,
            onToggle: () => ref.read(fabProvider.notifier).toggle(),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          MediaQuery.of(context).viewPadding.bottom + 8,
        ),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkNavbarBackground
                : AppColors.navbarBackground,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                isSelected: widget.navigationShell.currentIndex == 0,
                onTap: () => _onTabTapped(0),
              ),
              _NavItem(
                icon: Icons.map_outlined,
                activeIcon: Icons.map,
                label: 'Maps',
                isSelected: widget.navigationShell.currentIndex == 1,
                onTap: () => _onTabTapped(1),
              ),
              _NavItem(
                icon: Icons.favorite_outline,
                activeIcon: Icons.favorite,
                label: 'Favorites',
                isSelected: widget.navigationShell.currentIndex == 2,
                onTap: () => _onTabTapped(2),
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                isSelected: widget.navigationShell.currentIndex == 3,
                onTap: () => _onTabTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? (Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkNavbarSelected
              : AppColors.navbarSelected)
        : (Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkNavbarUnselected
              : AppColors.navbarUnselected);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeedDialFab extends StatelessWidget {
  const _SpeedDialFab({
    required this.actions,
    required this.isOpen,
    required this.onToggle,
  });

  final List<FabAction> actions;
  final bool isOpen;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isOpen) ...[
          IntrinsicWidth(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8, right: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCardBackground
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: actions.mapIndexed((index, action) {
                  final isLast = index == actions.length - 1;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          onToggle();
                          action.onTap();
                        },
                        borderRadius: BorderRadius.vertical(
                          top: index == 0
                              ? const Radius.circular(16)
                              : Radius.zero,
                          bottom: isLast
                              ? const Radius.circular(16)
                              : Radius.zero,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Text(
                            action.label,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                      if (!isLast)
                        const Divider(height: 1, color: AppColors.inputBorder),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
        FloatingActionButton(
          onPressed: onToggle,
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.buttonPrimaryText,
          elevation: 4,
          child: AnimatedRotation(
            turns: isOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}