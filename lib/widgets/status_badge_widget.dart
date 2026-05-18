import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusBadgeWidget extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;

  const StatusBadgeWidget({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(77), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor ?? color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
