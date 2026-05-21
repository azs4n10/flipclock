import 'package:flutter/material.dart';

import '../theme/fonts.dart';
import '../theme/skin.dart';
import 'flip_card.dart';

class FlipCardRow extends StatelessWidget {
  const FlipCardRow({
    super.key,
    required this.values,
    required this.skin,
    required this.font,
    this.labels,
    this.aspectRatio = 0.85,
    this.spacing = 10,
    this.maxCardWidth = 240,
  });

  final List<String> values;
  final List<String>? labels;
  final Skin skin;
  final DigitFont font;
  final double aspectRatio;
  final double spacing;
  final double maxCardWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        final totalSpacing = spacing * (values.length - 1);
        final cardWidth =
            ((available - totalSpacing) / values.length).clamp(0, maxCardWidth);
        final cardHeight = cardWidth / aspectRatio;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < values.length; i++) ...[
                  FlipGroup(
                    value: values[i],
                    skin: skin,
                    font: font,
                    width: cardWidth.toDouble(),
                    height: cardHeight,
                  ),
                  if (i != values.length - 1) SizedBox(width: spacing),
                ],
              ],
            ),
            if (labels != null) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < labels!.length; i++) ...[
                    SizedBox(
                      width: cardWidth.toDouble(),
                      child: Text(
                        labels![i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: skin.subTextColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (i != labels!.length - 1) SizedBox(width: spacing),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
