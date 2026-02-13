import 'package:flutter/material.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: DesignSpacing.m),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.l,
          vertical: DesignSpacing.s,
        ),
        decoration: BoxDecoration(
          color: isSelected ? DesignColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.xl),
          border: Border.all(
            color: isSelected ? DesignColors.primary : DesignColors.secondary,
            width: 1,
          ),
          boxShadow: isSelected ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : DesignColors.primary,
              ),
              const SizedBox(width: DesignSpacing.s),
            ],
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : DesignColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
