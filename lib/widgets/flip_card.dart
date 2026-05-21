import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/fonts.dart';
import '../theme/skin.dart';

const Duration kFlipDuration = Duration(milliseconds: 700);

/// A rounded card holding one or more independently-flipping digits.
/// Only the digits that actually change animate, so e.g. the tens place of
/// the seconds stays still while the ones place flips each second.
class FlipGroup extends StatelessWidget {
  const FlipGroup({
    super.key,
    required this.value,
    required this.skin,
    required this.font,
    required this.width,
    required this.height,
  });

  final String value;
  final Skin skin;
  final DigitFont font;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final radius = width * 0.15;
    final chars = value.split('');
    final digitWidth = width / chars.length;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: skin.accentColor.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            Row(
              children: [
                for (final c in chars)
                  FlipDigit(
                    char: c,
                    skin: skin,
                    font: font,
                    width: digitWidth,
                    height: height,
                  ),
              ],
            ),
            Center(child: Container(height: 2, color: skin.dividerColor)),
          ],
        ),
      ),
    );
  }
}

class FlipDigit extends StatefulWidget {
  const FlipDigit({
    super.key,
    required this.char,
    required this.skin,
    required this.font,
    required this.width,
    required this.height,
  });

  final String char;
  final Skin skin;
  final DigitFont font;
  final double width;
  final double height;

  @override
  State<FlipDigit> createState() => _FlipDigitState();
}

class _FlipDigitState extends State<FlipDigit>
    with SingleTickerProviderStateMixin {
  late String _current = widget.char;
  late String _next = widget.char;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: kFlipDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _current = _next);
          _controller.reset();
          if (widget.char != _current) {
            _next = widget.char;
            _controller.forward();
          }
        }
      });
  }

  @override
  void didUpdateWidget(covariant FlipDigit old) {
    super.didUpdateWidget(old);
    if (widget.char != _current && !_controller.isAnimating) {
      _next = widget.char;
      _controller.forward();
    } else if (_controller.isAnimating) {
      _next = widget.char;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = widget.height * 0.92;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => _SplitFlap(
          current: _current,
          next: _next,
          skin: widget.skin,
          textStyle: widget.font.build(fontSize, widget.skin.digitColor),
          cardSize: Size(widget.width, widget.height),
          progress: Curves.easeInOut.transform(_controller.value),
        ),
      ),
    );
  }
}

class _SplitFlap extends StatelessWidget {
  const _SplitFlap({
    required this.current,
    required this.next,
    required this.skin,
    required this.textStyle,
    required this.cardSize,
    required this.progress,
  });

  final String current;
  final String next;
  final Skin skin;
  final TextStyle textStyle;
  final Size cardSize;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final flipping = progress > 0 && current != next;
    final p1 = (progress / 0.5).clamp(0.0, 1.0);
    final p2 = ((progress - 0.5) / 0.5).clamp(0.0, 1.0);

    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: _Leaf(
            half: _Half.top,
            digit: flipping ? next : current,
            skin: skin,
            textStyle: textStyle,
            cardSize: cardSize,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _Leaf(
            half: _Half.bottom,
            digit: current,
            skin: skin,
            textStyle: textStyle,
            cardSize: cardSize,
          ),
        ),
        if (flipping && progress < 0.5)
          Align(
            alignment: Alignment.topCenter,
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0040)
                ..rotateX(-math.pi / 2 * p1),
              child: _Leaf(
                half: _Half.top,
                digit: current,
                skin: skin,
                textStyle: textStyle,
                cardSize: cardSize,
                shade: p1,
              ),
            ),
          ),
        if (flipping && progress >= 0.5)
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0040)
                ..rotateX(math.pi / 2 * (1 - p2)),
              child: _Leaf(
                half: _Half.bottom,
                digit: next,
                skin: skin,
                textStyle: textStyle,
                cardSize: cardSize,
                shade: 1 - p2,
              ),
            ),
          ),
      ],
    );
  }
}

enum _Half { top, bottom }

class _Leaf extends StatelessWidget {
  const _Leaf({
    required this.half,
    required this.digit,
    required this.skin,
    required this.textStyle,
    required this.cardSize,
    this.shade = 0,
  });

  final _Half half;
  final String digit;
  final Skin skin;
  final TextStyle textStyle;
  final Size cardSize;
  final double shade;

  @override
  Widget build(BuildContext context) {
    final isTop = half == _Half.top;
    return SizedBox(
      width: cardSize.width,
      height: cardSize.height / 2,
      child: ClipRect(
        child: OverflowBox(
          maxHeight: cardSize.height,
          minHeight: cardSize.height,
          alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
          child: SizedBox(
            width: cardSize.width,
            height: cardSize.height,
            child: Stack(
              children: [
                Positioned.fill(child: ColoredBox(color: skin.cardBackground)),
                Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(digit, style: textStyle),
                  ),
                ),
                if (shade > 0)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: isTop
                              ? Alignment.topCenter
                              : Alignment.bottomCenter,
                          end: isTop
                              ? Alignment.bottomCenter
                              : Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.16 * shade),
                            Colors.black.withValues(alpha: 0.72 * shade),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
