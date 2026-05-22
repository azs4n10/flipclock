import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/fonts.dart';
import '../theme/skin.dart';

const Duration kFlipDuration = Duration(milliseconds: 500);

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
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            Row(
              children: [
                for (int i = 0; i < chars.length; i++)
                  FlipDigit(
                    key: ValueKey('digit_$i'),
                    char: chars[i],
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

/// A card that looks exactly like a [FlipGroup] but never animates — used for
/// fast-changing values (centiseconds) that change too quickly to flip.
class StaticFlipCard extends StatelessWidget {
  const StaticFlipCard({
    super.key,
    required this.value,
    required this.skin,
    required this.font,
    required this.width,
    required this.height,
    required this.centerBias,
  });

  final String value;
  final Skin skin;
  final DigitFont font;
  final double width;
  final double height;
  final double centerBias;

  @override
  Widget build(BuildContext context) {
    final radius = width * 0.15;
    final chars = value.split('');
    final digitWidth = width / chars.length;
    final fontSize = height * 0.92;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: skin.cardBackground)),
            Row(
              children: [
                for (final ch in chars)
                  SizedBox(
                    width: digitWidth,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: digitWidth * 0.08,
                        vertical: height * 0.10,
                      ),
                      child: Center(
                        child: Transform.translate(
                          offset: Offset(0, centerBias * height),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(ch,
                                style: font.build(fontSize, skin.digitColor)),
                          ),
                        ),
                      ),
                    ),
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
  String _next = '';
  bool _flipping = false;
  double _progress = 0;

  // The animation is driven by a real-time Stopwatch rather than the ticker's
  // reported elapsed time: on Flutter web the frame timestamps can run far
  // faster than wall-clock, which made AnimationController finish in ~40ms
  // instead of the intended duration. Stopwatch uses the monotonic clock and
  // is immune to that. The Ticker is used only to request a frame each vsync.
  late final Ticker _ticker;
  final Stopwatch _watch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  void _beginFlip(String to) {
    _next = to;
    _flipping = true;
    _progress = 0;
    _watch
      ..reset()
      ..start();
    if (!_ticker.isActive) _ticker.start();
  }

  void _onTick(Duration _) {
    final ms = _watch.elapsedMilliseconds;
    final p = (ms / kFlipDuration.inMilliseconds).clamp(0.0, 1.0);
    setState(() => _progress = p);
    if (p >= 1.0) {
      _ticker.stop();
      _watch
        ..stop()
        ..reset();
      setState(() {
        _current = _next;
        _flipping = false;
        _progress = 0;
      });
      if (widget.char != _current) _beginFlip(widget.char);
    }
  }

  @override
  void didUpdateWidget(covariant FlipDigit old) {
    super.didUpdateWidget(old);
    if (widget.char != _current) {
      if (_flipping) {
        _next = widget.char; // current flip finishes, then chains to newest
      } else {
        _beginFlip(widget.char);
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = widget.height * 0.92;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _SplitFlap(
        current: _current,
        next: _flipping ? _next : _current,
        skin: widget.skin,
        textStyle: widget.font.build(fontSize, widget.skin.digitColor),
        cardSize: Size(widget.width, widget.height),
        centerBias: widget.font.centerBias,
        progress: _flipping ? Curves.easeInOut.transform(_progress) : 0,
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
    required this.centerBias,
    required this.progress,
  });

  final String current;
  final String next;
  final Skin skin;
  final TextStyle textStyle;
  final Size cardSize;
  final double centerBias;
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
            centerBias: centerBias,
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
            centerBias: centerBias,
          ),
        ),
        if (flipping && progress < 0.5)
          Align(
            alignment: Alignment.topCenter,
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..rotateX(-math.pi / 2 * p1),
              child: _Leaf(
                half: _Half.top,
                digit: current,
                skin: skin,
                textStyle: textStyle,
                cardSize: cardSize,
                centerBias: centerBias,
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
                ..rotateX(math.pi / 2 * (1 - p2)),
              child: _Leaf(
                half: _Half.bottom,
                digit: next,
                skin: skin,
                textStyle: textStyle,
                cardSize: cardSize,
                centerBias: centerBias,
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
    required this.centerBias,
    this.shade = 0,
  });

  final _Half half;
  final String digit;
  final Skin skin;
  final TextStyle textStyle;
  final Size cardSize;
  final double centerBias;
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
                Padding(
                  // Margin so tall/wide glyphs are not clipped by the card edge.
                  padding: EdgeInsets.symmetric(
                    horizontal: cardSize.width * 0.08,
                    vertical: cardSize.height * 0.10,
                  ),
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(0, centerBias * cardSize.height),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(digit, style: textStyle),
                      ),
                    ),
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
