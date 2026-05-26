import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/skin.dart';

/// A silent, workplace-friendly "done" signal: a soft full-screen pulse in the
/// accent colour with a check mark and a short message that fades away. Driven
/// by a real-time Stopwatch so it plays correctly even with OS reduce-motion.
class CompletionFlash extends StatefulWidget {
  const CompletionFlash({
    super.key,
    required this.trigger,
    required this.skin,
    required this.message,
  });

  /// Increment this to play the effect once.
  final int trigger;
  final Skin skin;
  final String message;

  @override
  State<CompletionFlash> createState() => _CompletionFlashState();
}

class _CompletionFlashState extends State<CompletionFlash>
    with SingleTickerProviderStateMixin {
  static const int _durMs = 1900;
  late final Ticker _ticker;
  final Stopwatch _watch = Stopwatch();
  double _t = 0;
  bool _active = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void didUpdateWidget(covariant CompletionFlash old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger && widget.trigger != 0) _play();
  }

  void _play() {
    _watch
      ..reset()
      ..start();
    _active = true;
    if (!_ticker.isActive) _ticker.start();
    setState(() {});
  }

  void _onTick(Duration _) {
    final t = (_watch.elapsedMilliseconds / _durMs).clamp(0.0, 1.0);
    setState(() => _t = t);
    if (t >= 1.0) {
      _ticker.stop();
      _watch
        ..stop()
        ..reset();
      setState(() {
        _active = false;
        _t = 0;
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_active) return const SizedBox.shrink();
    final t = _t;
    final fade = t < 0.12
        ? t / 0.12
        : (t > 0.72 ? (1 - (t - 0.72) / 0.28) : 1.0);
    final pulse = math.sin(t * math.pi * 3).abs(); // a few gentle pulses
    final scale =
        0.8 + 0.22 * Curves.easeOutBack.transform((t / 0.45).clamp(0.0, 1.0));
    final skin = widget.skin;
    return IgnorePointer(
      child: Opacity(
        opacity: fade.clamp(0.0, 1.0),
        child: Container(
          color: skin.accentColor.withValues(alpha: 0.10 + 0.16 * pulse),
          child: Center(
            child: Transform.scale(
              scale: scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: skin.buttonColor, size: 104),
                  const SizedBox(height: 14),
                  Text(
                    widget.message,
                    style: TextStyle(
                      color: skin.primaryTextColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
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
