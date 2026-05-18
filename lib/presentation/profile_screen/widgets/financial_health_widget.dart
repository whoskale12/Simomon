import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class FinancialHealthWidget extends StatefulWidget {
  final int score;
  final String status;
  final bool isDark;
  final String aiInsight;

  const FinancialHealthWidget({
    super.key,
    required this.score,
    required this.status,
    required this.isDark,
    required this.aiInsight,
  });

  @override
  State<FinancialHealthWidget> createState() => _FinancialHealthWidgetState();
}

class _FinancialHealthWidgetState extends State<FinancialHealthWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _scoreColor {
    if (widget.score >= 80) return AppTheme.mint;
    if (widget.score >= 65) return AppTheme.primary;
    if (widget.score >= 45) return AppTheme.yellow;
    return AppTheme.coral;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: widget.isDark
                ? Colors.black.withAlpha(77)
                : AppTheme.primary.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Skor Kesehatan Finansial',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _scoreColor.withAlpha(31),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  widget.status,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _scoreColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Animated arc
              AnimatedBuilder(
                animation: _scoreAnim,
                builder: (context, _) {
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: CustomPaint(
                      painter: _ScoreArcPainter(
                        score: widget.score * _scoreAnim.value,
                        color: _scoreColor,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(widget.score * _scoreAnim.value).toInt()}',
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: _scoreColor,
                                fontFeatures: [
                                  const FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            Text(
                              '/100',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kancil bilang...',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.aiInsight,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildScoreBar(theme, 'Stabilitas', 0.75),
                    const SizedBox(height: 6),
                    _buildScoreBar(
                      theme,
                      'Tabungan',
                      widget.score >= 65 ? 0.6 : 0.3,
                    ),
                    const SizedBox(height: 6),
                    _buildScoreBar(
                      theme,
                      'Konsistensi',
                      widget.score >= 80 ? 0.85 : 0.5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar(ThemeData theme, String label, double ratio) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 10,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: AnimatedBuilder(
              animation: _scoreAnim,
              builder: (context, _) {
                return LinearProgressIndicator(
                  value: ratio * _scoreAnim.value,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(_scoreColor),
                  minHeight: 6,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreArcPainter extends CustomPainter {
  final double score;
  final Color color;
  final Color backgroundColor;

  _ScoreArcPainter({
    required this.score,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final strokeWidth = 8.0;

    // Background arc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      math.pi * 1.5,
      false,
      bgPaint,
    );

    // Score arc
    final scorePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 100) * math.pi * 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      sweepAngle,
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(_ScoreArcPainter oldDelegate) =>
      oldDelegate.score != score;
}
