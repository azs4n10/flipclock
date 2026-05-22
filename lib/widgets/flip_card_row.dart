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
    this.maxCardWidth = 240,
    this.staticTail,
    this.staticTailLabel,
  });

  final List<String> values;
  final List<String>? labels;
  final Skin skin;
  final DigitFont font;
  final double aspectRatio;
  final double maxCardWidth;

  /// An extra trailing value rendered as a non-flipping card (e.g. the
  /// fast-changing centiseconds on the stopwatch), placed next to the others.
  final String? staticTail;
  final String? staticTailLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        final count = values.length + (staticTail != null ? 1 : 0);
        // Gap between panels ~= 1/12 of the available width, then 0.7x.
        final gap = count > 1 ? available / 12 * 0.7 : 0.0;
        final totalSpacing = gap * (count - 1);
        final cardWidth =
            ((available - totalSpacing) / count).clamp(0, maxCardWidth);
        final cardHeight = cardWidth / aspectRatio;
        final hasLabels = labels != null || staticTailLabel != null;

        final cards = <Widget>[
          for (int i = 0; i < values.length; i++)
            FlipGroup(
              value: values[i],
              skin: skin,
              font: font,
              width: cardWidth.toDouble(),
              height: cardHeight,
            ),
          if (staticTail != null)
            StaticFlipCard(
              value: staticTail!,
              skin: skin,
              font: font,
              width: cardWidth.toDouble(),
              height: cardHeight,
              centerBias: font.centerBias,
            ),
        ];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < cards.length; i++) ...[
                  cards[i],
                  if (i != cards.length - 1) SizedBox(width: gap),
                ],
              ],
            ),
            if (hasLabels) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < cards.length; i++) ...[
                    SizedBox(
                      width: cardWidth.toDouble(),
                      child: Text(
                        i < (labels?.length ?? 0)
                            ? labels![i]
                            : (i == values.length ? (staticTailLabel ?? '') : ''),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: skin.subTextColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (i != cards.length - 1) SizedBox(width: gap),
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
