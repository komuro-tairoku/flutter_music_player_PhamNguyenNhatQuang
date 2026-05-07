import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.background;
    final textPrimary =
        isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surface;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_rounded, color: textPrimary, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          // ── Appearance ───────────────────────────────────────────
          _SectionLabel(label: 'Appearance'),
          _SettingCard(
            isDark: isDark,
            surface: surfaceColor,
            child: SwitchListTile.adaptive(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text(
                'Dark mode',
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              subtitle: const Text(
                'Switch between light and dark theme',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
              secondary: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.dark_mode_rounded,
                    color: AppColors.primary, size: 18),
              ),
              value: isDark,
              onChanged: (_) =>
                  context.read<ThemeProvider>().toggleTheme(),
              activeColor: AppColors.primary,
            ),
          ),

          const SizedBox(height: 24),

          // ── About ────────────────────────────────────────────────
          _SectionLabel(label: 'About'),
          _SettingCard(
            isDark: isDark,
            surface: surfaceColor,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.music_note_rounded,
                    color: AppColors.primary, size: 18),
              ),
              title: Text(
                AppStrings.appName,
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              subtitle: const Text(
                'Version 1.0.0',
                style: TextStyle(
                    color: AppColors.textTertiary, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final Color surface;

  const _SettingCard({
    required this.child,
    required this.isDark,
    required this.surface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
