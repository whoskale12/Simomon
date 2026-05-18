import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/transaction_model.dart';
import '../../../theme/app_theme.dart';

class AmountInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isDark;
  final TransactionType transactionType;

  const AmountInputWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.isDark,
    required this.transactionType,
  });

  @override
  State<AmountInputWidget> createState() => _AmountInputWidgetState();
}

class _AmountInputWidgetState extends State<AmountInputWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _focusController;
  late Animation<double> _focusAnim;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _focusAnim = CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _focusController.dispose();
    super.dispose();
  }

  Color get _accentColor => widget.transactionType == TransactionType.expense
      ? AppTheme.coral
      : AppTheme.mint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _focusAnim,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isFocused
                  ? _accentColor.withAlpha(153)
                  : theme.colorScheme.outline.withAlpha(77),
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isFocused
                    ? _accentColor.withAlpha(38)
                    : Colors.black.withAlpha(10),
                blurRadius: _isFocused ? 20 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jumlah',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Rp',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _accentColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Focus(
                      onFocusChange: (hasFocus) {
                        setState(() => _isFocused = hasFocus);
                        if (hasFocus) {
                          _focusController.forward();
                        } else {
                          _focusController.reverse();
                        }
                      },
                      child: TextFormField(
                        controller: widget.controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _ThousandsSeparatorFormatter(),
                        ],
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.outline.withAlpha(102),
                          ),
                          border: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: widget.onChanged,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Masukkan jumlah transaksi';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('.', '');
    if (text.isEmpty) return newValue;

    final formatted = text.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
