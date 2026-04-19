import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippie_frontend/app/router.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
import 'package:trippie_frontend/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:trippie_frontend/features/profile/presentation/widgets/section_label.dart';
import 'package:trippie_frontend/features/profile/presentation/widgets/settings_row.dart';
import 'package:trippie_frontend/features/profile/presentation/widgets/theme_toggle.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref
        .watch(authProvider)
        .when(
          data: (data) => data,
          loading: () => null,
          error: (_, __) => null,
        );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? AppGradients.backgroundDark
              : AppGradients.background,
        ),
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(context).padding.bottom + 100,
            ),
            children: [
              Text(
                'Profile',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),

              // ---------------------------------------------------------------
              // Header card
              // ---------------------------------------------------------------
              ProfileHeaderCard(
                firstName: user?.firstname ?? '',
                lastName: user?.lastname ?? '',
                email: user?.email ?? '',
              ),
              const SizedBox(height: 24),

              // ---------------------------------------------------------------
              // Account section
              // ---------------------------------------------------------------
              SectionLabel(label: 'ACCOUNT'),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    SettingsRow(
                      icon: Icons.person_outline,
                      iconColor: const Color(0xFF7B6FAB),
                      title: 'My Account',
                      subtitle: 'Make changes to your account',
                      onTap: () {
                        context.push(AppRoutes.myAccount);
                      },
                    ),
                    SettingsRow(
                      icon: Icons.shield_outlined,
                      iconColor: const Color(0xFF7B6FAB),
                      title: 'Change password',
                      subtitle: 'Further secure your account for safety',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: const Text('Coming soon')),
                        );
                      },
                    ),
                    SettingsRow(
                      icon: Icons.logout,
                      iconColor: Colors.redAccent,
                      title: 'Log out',
                      subtitle: 'Further secure your account for safety',
                      onTap: () => _onLogoutTapped(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ---------------------------------------------------------------
              // Appearance section
              // ---------------------------------------------------------------
              SectionLabel(label: 'APPEARANCE'),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ThemeToggle(currentTheme: user?.theme ?? 'LIGHT'),
                ),
              ),
              const SizedBox(height: 24),

              // ---------------------------------------------------------------
              // More section
              // ---------------------------------------------------------------
              SectionLabel(label: 'MORE'),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    SettingsRow(
                      icon: Icons.notifications_outlined,
                      iconColor: const Color(0xFF7B6FAB),
                      title: 'Help & Support',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: const Text('Coming soon')),
                        );
                      },
                    ),
                    SettingsRow(
                      icon: Icons.favorite_outline,
                      iconColor: const Color(0xFF7B6FAB),
                      title: 'About App',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: const Text('Coming soon')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onLogoutTapped(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Log out',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authProvider.notifier).logout();
    }
  }
}
