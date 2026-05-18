import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class TopCategoriesWidget extends StatefulWidget {
  final List<MapEntry<String, double>> topCategories;
  final double totalExpenses;
  final bool isDark;

  const TopCategoriesWidget({
    super.key,
    required this.topCategories,
    required this.totalExpenses,
    required this.isDark,
  });

  @override
  State<TopCategoriesWidget> createState() => _TopCategoriesWidgetState();
}

class _TopCategoriesWidgetState extends State<TopCategoriesWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.topCategories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'Belum ada pengeluaran tercatat 📝',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final displayCategories = widget.topCategories.take(5).toList();

    return Column(
      children: List.generate(displayCategories.length, (i) {
        final entry = displayCategories[i];
        return _CategoryCardItem(
          category: entry.key,
          amount: entry.value,
          totalExpenses: widget.totalExpenses,
          index: i,
          isDark: widget.isDark,
        );
      }),
    );
  }
}

class _CategoryCardItem extends StatefulWidget {
  final String category;
  final double amount;
  final double totalExpenses;
  final int index;
  final bool isDark;

  const _CategoryCardItem({
    required this.category,
    required this.amount,
    required this.totalExpenses,
    required this.index,
    required this.isDark,
  });

  @override
  State<_CategoryCardItem> createState() => _CategoryCardItemState();
}

class _CategoryCardItemState extends State<_CategoryCardItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _progressAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _fmt(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catColor = AppTheme.categoryColor(widget.category);
    final pct = widget.totalExpenses > 0
        ? (widget.amount / widget.totalExpenses * 100)
        : 0.0;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? AppTheme.surfaceDark
                  : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.isDark
                      ? Colors.black.withAlpha(64)
                      : catColor.withAlpha(20),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: catColor.withAlpha(38), width: 1),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Category icon with gradient bg
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            catColor.withAlpha(51),
                            catColor.withAlpha(20),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        AppTheme.categoryIcon(widget.category),
                        color: catColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.category,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${pct.toStringAsFixed(1)}% dari total pengeluaran',
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rp ${_fmt(widget.amount)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: catColor,
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: AnimatedBuilder(
                          animation: _progressAnim,
                          builder: (context, _) {
                            return LinearProgressIndicator(
                              value: (pct / 100) * _progressAnim.value,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                catColor,
                              ),
                              minHeight: 6,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: catColor.withAlpha(31),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${pct.toStringAsFixed(0)}%',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: catColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
