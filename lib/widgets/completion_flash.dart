import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/skin.dart';

/// A silent, workplace-friendly "done" signal: a soft full-screen wash in the
/// accent colour with a check mark and a short message. It animates in, then
/// stays until the user taps to dismiss. Driven by a real-time Stopwatch so the
/// entrance plays correctly even with OS reduce-motion.
class CompletionFlash extends StatefulWidget {
  const CompletionFlash({
    super.key,
    required this.trigger,
    required this.skin,
    required this.message,
  });

  /// Increment this to show the effect.
  final int trigger;
  final Skin skin;
  final String message;

  @override
  State<CompletionFlash> createState() => _CompletionFlashState();
}

class _CompletionFlashState extends State<CompletionFlash>
    with SingleTickerProviderStateMixin {
  static const int _enterMs = 500;
  late final Ticker _ticker;
  final Stopwatch _watch = Stopwatch();
  double _enter = 0; // 0..1 entrance progress
  bool _active = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void didUpdateWidget(covariant CompletionFlash old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger && widget.trigger != 0) _show();
  }

  void _show() {
    _watch
      ..reset()
      ..start();
    _active = true;
    _enter = 0;
    if (!_ticker.isActive) _ticker.start();
    setState(() {});
  }

  void _onTick(Duration _) {
    final e = (_watch.elapsedMilliseconds / _enterMs).clamp(0.0, 1.0);
    setState(() => _enter = e);
    if (e >= 1.0) {
      // Hold (no auto-dismiss) until the user taps; stop ticking to save work.
      _ticker.stop();
      _watch.stop();
    }
  }

  void _dismiss() {
    if (!_active) return;
    _ticker.stop();
    _watch
      ..stop()
      ..reset();
    setState(() {
      _active = false;
      _enter = 0;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_active) return const SizedBox.shrink();
    final e = Curves.easeOut.transform(_enter);
    final scale = 0.8 + 0.2 * Curves.easeOutBack.transform(_enter);
    final skin = widget.skin;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _dismiss,
      child: Opacity(
        opacity: e,
        child: DecoratedBox(
          // Strong scrim in the theme background colour so the cards behind
          // fade out and the check mark / message read clearly. A faint accent
          // tint keeps it on-brand.
          decoration: BoxDecoration(
            color: skin.background.withValues(alpha: 0.93),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: skin.accentColor.withValues(alpha: 0.10),
            ),
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
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'tap to dismiss',
                    style: TextStyle(
                      color: skin.subTextColor,
                      fontSize: 13,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }
}
