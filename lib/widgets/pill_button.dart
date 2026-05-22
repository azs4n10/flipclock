import 'package:flutter/material.dart';

import '../theme/skin.dart';

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.skin,
    this.outlined = false,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final Skin skin;
  final bool outlined;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fill = outlined ? Colors.transparent : skin.buttonColor;
    final textColor = outlined ? skin.buttonColor : skin.buttonTextColor;
    return Material(
      color: fill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: outlined
            ? BorderSide(color: skin.buttonColor, width: 2)
            : BorderSide.none,
      ),
      elevation: outlined ? 0 : 2,
      shadowColor: skin.buttonColor.withValues(alpha: 0.4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: textColor, size: 16),
                const SizedBox(width: 7),
              ],
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
