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
    this.staticTailScale = 1.0,
  });

  final List<String> values;
  final List<String>? labels;
  final Skin skin;
  final DigitFont font;
  final double aspectRatio;
  final double maxCardWidth;

  /// An extra trailing value rendered as a non-flipping card (e.g. the
  /// fast-changing centiseconds on the stopwatch). [staticTailScale] shrinks it
  /// relative to the main cards.
  final String? staticTail;
  final String? staticTailLabel;
  final double staticTailScale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        final hasTail = staticTail != null;
        final cardCount = values.length + (hasTail ? 1 : 0);
        final gap = cardCount > 1 ? available / 12 * 0.7 : 0.0;
        final totalSpacing = gap * (cardCount - 1);
        // The tail counts as a fraction of a card width when sizing.
        final units = values.length + (hasTail ? staticTailScale : 0.0);
        final cardWidth =
            ((available - totalSpacing) / units).clamp(0.0, maxCardWidth);
        final cardHeight = cardWidth / aspectRatio;
        final tailWidth = cardWidth * staticTailScale;
        final tailHeight = cardHeight * staticTailScale;
        final hasLabels = labels != null || staticTailLabel != null;

        Widget labelCell(String text, double width) => SizedBox(
              width: width,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: skin.subTextColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  fontSize: 12,
                ),
              ),
            );

        final cardRow = <Widget>[];
        final labelRow = <Widget>[];
        for (int i = 0; i < values.length; i++) {
          cardRow.add(FlipGroup(
            value: values[i],
            skin: skin,
            font: font,
            width: cardWidth,
            height: cardHeight,
          ));
          labelRow.add(labelCell(
              i < (labels?.length ?? 0) ? labels![i] : '', cardWidth));
        }
        if (hasTail) {
          cardRow.add(StaticFlipCard(
            value: staticTail!,
            skin: skin,
            font: font,
            width: tailWidth,
            height: tailHeight,
            centerBias: font.centerBias,
          ));
          labelRow.add(labelCell(staticTailLabel ?? '', tailWidth));
        }

        List<Widget> withGaps(List<Widget> items) => [
              for (int i = 0; i < items.length; i++) ...[
                items[i],
                if (i != items.length - 1) SizedBox(width: gap),
              ],
            ];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: withGaps(cardRow),
            ),
            if (hasLabels) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: withGaps(labelRow),
              ),
            ],
          ],
        );
      },
    );
  }
}
