import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class SettingsSectionWidget extends StatelessWidget {
  final bool isDark;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final ValueChanged<bool> onDarkModeToggle;
  final ValueChanged<bool> onNotificationsToggle;
  final VoidCallback onExportTap;
  final VoidCallback onAboutTap;
  final VoidCallback onResetTap;

  const SettingsSectionWidget({
    super.key,
    required this.isDark,
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.onDarkModeToggle,
    required this.onNotificationsToggle,
    required this.onExportTap,
    required this.onAboutTap,
    required this.onResetTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(64)
                : AppTheme.primary.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildToggleSetting(
            context,
            icon: Icons.dark_mode_rounded,
            label: 'Mode Gelap',
            description: 'Ubah tampilan ke dark mode',
            color: AppTheme.indigo,
            value: isDarkMode,
            onChanged: onDarkModeToggle,
            isFirst: true,
          ),
          _buildDivider(context),
          _buildToggleSetting(
            context,
            icon: Icons.notifications_rounded,
            label: 'Notifikasi',
            description: 'Pengingat pengeluaran harian',
            color: AppTheme.yellow,
            value: notificationsEnabled,
            onChanged: onNotificationsToggle,
          ),
          _buildDivider(context),
          _buildActionSetting(
            context,
            icon: Icons.download_rounded,
            label: 'Export Data',
            description: 'Unduh riwayat transaksi (CSV)',
            color: AppTheme.mint,
            onTap: onExportTap,
          ),
          _buildDivider(context),
          _buildActionSetting(
            context,
            icon: Icons.info_outline_rounded,
            label: 'Tentang Simomon',
            description: 'Versi 1.0.0 • Made with ❤️',
            color: AppTheme.primary,
            onTap: onAboutTap,
            isLast: true,
          ),
          _buildDivider(context),
          _buildActionSetting(
            context,
            icon: Icons.delete_outline,
            label: 'Reset Data',
            description: 'Hapus semua transaksi',
            color: AppTheme.error,
            onTap: onResetTap,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSetting(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(20) : Radius.zero,
        bottom: isLast ? const Radius.circular(20) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha(31),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppTheme.primary,
              activeTrackColor: AppTheme.primary.withAlpha(77),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSetting(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(20) : Radius.zero,
        bottom: isLast ? const Radius.circular(20) : Radius.zero,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: color.withAlpha(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withAlpha(31),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        description,
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 70,
      endIndent: 16,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
