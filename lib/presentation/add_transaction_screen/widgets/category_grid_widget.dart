import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

/// Safe, predefined category model — no dynamic icon parsing
class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class CategoryGridWidget extends StatefulWidget {
  final List<CategoryModel> categories;
  final CategoryModel? selectedCategory;
  final ValueChanged<CategoryModel> onCategorySelected;
  final bool isDark;

  const CategoryGridWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.isDark,
  });

  @override
  State<CategoryGridWidget> createState() => _CategoryGridWidgetState();
}

class _CategoryGridWidgetState extends State<CategoryGridWidget> {
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _scaleAnims = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initAnimations();
  }

  void _initAnimations() {
    for (final c in _controllers) {
      c.dispose();
    }
    _controllers.clear();
    _scaleAnims.clear();

    for (int i = 0; i < widget.categories.length; i++) {
      final ctrl = AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 350),
      );
      final anim = CurvedAnimation(parent: ctrl, curve: Curves.easeOutBack);
      _controllers.add(ctrl);
      _scaleAnims.add(anim);
      Future.delayed(Duration(milliseconds: i * 40), () {
        if (mounted) ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: widget.categories.length,
      itemBuilder: (ctx, i) {
        if (i >= _scaleAnims.length || i >= widget.categories.length) {
          return const SizedBox.shrink();
        }
        final cat = widget.categories[i];
        final isSelected = widget.selectedCategory?.id == cat.id;
        // Fallback color/icon for safety
        final catColor = cat.color;
        final catIcon = cat.icon;

        return ScaleTransition(
          scale: _scaleAnims[i],
          child: GestureDetector(
            onTap: () {
              debugPrint('Selected category: ${cat.name}');
              try {
                widget.onCategorySelected(cat);
                HapticFeedback.selectionClick();
              } catch (e) {
                debugPrint('Category selection error: $e');
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? catColor.withAlpha(38)
                    : (widget.isDark
                          ? AppTheme.surfaceVariantDark
                          : AppTheme.surfaceVariantLight),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? catColor.withAlpha(128)
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: catColor.withAlpha(51),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? catColor.withAlpha(51)
                          : catColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(catIcon, color: catColor, size: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat.name,
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? catColor
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
