import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../services/user_profile_service.dart';
import '../../../services/transaction_service.dart';

class AchievementsWidget extends StatefulWidget {
  final bool isDark;
  final TransactionService txService;
  final UserProfileService profileService;

  const AchievementsWidget({
    super.key,
    required this.isDark,
    required this.txService,
    required this.profileService,
  });

  @override
  State<AchievementsWidget> createState() => _AchievementsWidgetState();
}

class _AchievementsWidgetState extends State<AchievementsWidget> {
  @override
  void initState() {
    super.initState();
    _checkAchievements();
  }

  Future<void> _checkAchievements() async {
    final txService = widget.txService;
    final income = txService.monthlyIncome;
    final expense = txService.monthlyExpenses;

    await widget.profileService.checkAndUnlockAchievements(
      transactionDays: txService.uniqueTransactionDays,
      balancePositive30Days: txService.balance > 0,
      expenseLowerThanIncome: income > 0 && expense < income,
    );
  }

  List<Map<String, dynamic>> get _badges {
    final p = widget.profileService;
    return [
      {
        'icon': Icons.emoji_events_rounded,
        'label': 'Pencatat Rajin',
        'desc': '7 hari catat',
        'color': AppTheme.yellow,
        'unlocked': p.achievementPencatatRajin,
      },
      {
        'icon': Icons.savings_rounded,
        'label': 'Penabung Hebat',
        'desc': 'Saldo positif',
        'color': AppTheme.mint,
        'unlocked': p.achievementPenabungHebat,
      },
      {
        'icon': Icons.trending_down_rounded,
        'label': 'Hemat Master',
        'desc': 'Hemat bulan ini',
        'color': AppTheme.coral,
        'unlocked': p.achievementHematMaster,
      },
      {
        'icon': Icons.smart_toy_rounded,
        'label': 'Kancil Fan',
        'desc': 'Buka 5x',
        'color': AppTheme.primary,
        'unlocked': p.achievementKancilFan,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.isDark
                ? Colors.black.withAlpha(64)
                : AppTheme.primary.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _badges.map((badge) {
          final unlocked = badge['unlocked'] as bool;
          final color = badge['color'] as Color;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: unlocked
                      ? color.withAlpha(38)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: unlocked ? color.withAlpha(102) : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: unlocked
                      ? [
                          BoxShadow(
                            color: color.withAlpha(64),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  badge['icon'] as IconData,
                  color: unlocked ? color : theme.colorScheme.outline,
                  size: 24,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                badge['label'] as String,
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: unlocked
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                badge['desc'] as String,
                style: GoogleFonts.nunito(
                  fontSize: 9,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (unlocked) ...[
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withAlpha(31),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '✓ Unlocked',
                    style: GoogleFonts.nunito(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }
}
