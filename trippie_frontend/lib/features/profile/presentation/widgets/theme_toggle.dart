import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
import 'package:trippie_frontend/features/profile/data/user_providers.dart';

class ThemeToggle extends ConsumerStatefulWidget {
  const ThemeToggle({super.key, required this.currentTheme});

  final String currentTheme;

  @override
  ConsumerState<ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends ConsumerState<ThemeToggle> {
  late bool _isLight;

  @override
  void initState() {
    super.initState();
    _isLight = widget.currentTheme == 'LIGHT';
  }

  Future<void> _onToggle(bool isLight) async {
    if (_isLight == isLight) {
      return;
    }

    setState(() => _isLight = isLight);

    try {
      final repo = ref.read(userRepositoryProvider);
      await repo.toggleTheme();
      if (isLight) {
        ref.read(themeProvider.notifier).setLight();
      } else {
        ref.read(themeProvider.notifier).setDark();
      }
    } on Exception catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _isLight = !isLight);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _onToggle(true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _isLight ? const Color(0xFF6B5FA6) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wb_sunny_outlined,
                    size: 18,
                    color: _isLight ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'LIGHT',
                    style: TextStyle(
                      color: _isLight ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _onToggle(false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: !_isLight ? const Color(0xFF6B5FA6) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.nightlight_round,
                    size: 18,
                    color: !_isLight ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'DARK',
                    style: TextStyle(
                      color: !_isLight ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
