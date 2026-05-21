import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/skin.dart';

class FlipCard extends StatefulWidget {
  const FlipCard({
    super.key,
    required this.value,
    required this.skin,
    required this.width,
    required this.height,
  });

  final String value;
  final Skin skin;
  final double width;
  final double height;

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late String _current = widget.value;
  late String _next = widget.value;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _current = _next);
          _controller.reset();
          if (widget.value != _current) {
            _next = widget.value;
            _controller.forward();
          }
        }
      });
  }

  @override
  void didUpdateWidget(covariant FlipCard old) {
    super.didUpdateWidget(old);
    if (widget.value != _current && !_controller.isAnimating) {
      _next = widget.value;
      _controller.forward();
    } else if (_controller.isAnimating) {
      _next = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.width * 0.15;
    final fontSize = widget.height * 0.95;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => _SplitFlap(
          current: _current,
          next: _next,
          skin: widget.skin,
          fontSize: fontSize,
          radius: radius,
          cardSize: Size(widget.width, widget.height),
          progress: _controller.value,
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
    required this.fontSize,
    required this.radius,
    required this.cardSize,
    required this.progress,
  });

  final String current;
  final String next;
  final Skin skin;
  final double fontSize;
  final double radius;
  final Size cardSize;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final flipping = progress > 0 && current != next;
    final p1 = (progress / 0.5).clamp(0.0, 1.0); // phase 1 progress
    final p2 = ((progress - 0.5) / 0.5).clamp(0.0, 1.0); // phase 2 progress

    return Stack(
      children: [
        // Static top: the upcoming digit's top half (revealed once top leaf folds)
        Align(
          alignment: Alignment.topCenter,
          child: _Leaf(
            half: _Half.top,
            digit: flipping ? next : current,
            skin: skin,
            fontSize: fontSize,
            radius: radius,
            cardSize: cardSize,
          ),
        ),
        // Static bottom: the current digit's bottom half (stays until leaf lands)
        Align(
          alignment: Alignment.bottomCenter,
          child: _Leaf(
            half: _Half.bottom,
            digit: current,
            skin: skin,
            fontSize: fontSize,
            radius: radius,
            cardSize: cardSize,
          ),
        ),
        // Phase 1: current top half folds down around the center divider
        if (flipping && progress < 0.5)
          Align(
            alignment: Alignment.topCenter,
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..rotateX(-math.pi / 2 * p1),
              child: _Leaf(
                half: _Half.top,
                digit: current,
                skin: skin,
                fontSize: fontSize,
                radius: radius,
                cardSize: cardSize,
                shade: p1,
              ),
            ),
          ),
        // Phase 2: next bottom half folds down into place
        if (flipping && progress >= 0.5)
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..rotateX(math.pi / 2 * (1 - p2)),
              child: _Leaf(
                half: _Half.bottom,
                digit: next,
                skin: skin,
                fontSize: fontSize,
                radius: radius,
                cardSize: cardSize,
                shade: 1 - p2,
              ),
            ),
          ),
        // Center divider line
        Center(child: Container(height: 2, color: skin.dividerColor)),
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
    required this.fontSize,
    required this.radius,
    required this.cardSize,
    this.shade = 0,
  });

  final _Half half;
  final String digit;
  final Skin skin;
  final double fontSize;
  final double radius;
  final Size cardSize;

  /// 0 = no shadow, 1 = darkest. Fakes the lighting while folding.
  final double shade;

  @override
  Widget build(BuildContext context) {
    final isTop = half == _Half.top;
    final borderRadius = isTop
        ? BorderRadius.vertical(top: Radius.circular(radius))
        : BorderRadius.vertical(bottom: Radius.circular(radius));

    // A half-height box that shows the corresponding half of a full-size,
    // center-aligned digit. The shared edge sits exactly on the divider.
    return SizedBox(
      width: cardSize.width,
      height: cardSize.height / 2,
      child: ClipRRect(
        borderRadius: borderRadius,
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
                  Positioned.fill(
                    child: ColoredBox(color: skin.cardBackground),
                  ),
                  Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        digit,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w800,
                          color: skin.digitColor,
                          height: 1.0,
                          letterSpacing: -2,
                        ),
                      ),
                    ),
                  ),
                  if (shade > 0)
                    Positioned.fill(
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: 0.18 * shade),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
