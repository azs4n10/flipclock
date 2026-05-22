import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/flip_card_row.dart';

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scheduleTick();
  }

  void _scheduleTick() {
    final msToNextSecond = 1000 - DateTime.now().millisecond;
    _timer = Timer(Duration(milliseconds: msToNextSecond), () {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _now = DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final skin = appState.skin;
    final hour = appState.use24Hour
        ? _now.hour
        : (_now.hour % 12 == 0 ? 12 : _now.hour % 12);
    final hh = hour.toString().padLeft(2, '0');
    final mm = _now.minute.toString().padLeft(2, '0');
    final ss = _now.second.toString().padLeft(2, '0');
    final values = appState.showSeconds ? [hh, mm, ss] : [hh, mm];
    final dateText = DateFormat('MMM d, yyyy  EEE').format(_now);

    const aspect = 0.85; // card height = width / aspect
    const rowGap = 14.0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            if (appState.showDate) ...[
              Text(
                dateText,
                style: TextStyle(
                  fontSize: 32 * appState.fontScale,
                  color: skin.primaryTextColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),
            ],
            // Fill the leftover space; size the cards so the whole flip fits
            // both the available width AND height (responsive to screen size,
            // seconds on/off, and font scale).
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final portrait = MediaQuery.of(context).orientation ==
                      Orientation.portrait;
                  double maxCW;
                  if (portrait) {
                    final rows = values.length;
                    final hPer =
                        (c.maxHeight - rowGap * (rows - 1)) / rows * 0.98;
                    maxCW = math.min(
                        150 * appState.fontScale, math.min(hPer * aspect, c.maxWidth));
                  } else {
                    maxCW = math.min(
                        240 * appState.fontScale, c.maxHeight * aspect * 0.94);
                  }
                  maxCW = math.max(24.0, maxCW);

                  final flip = portrait
                      ? Column(
                          key: const ValueKey('portrait'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (int i = 0; i < values.length; i++) ...[
                              if (i != 0) const SizedBox(height: rowGap),
                              FlipCardRow(
                                  values: [values[i]],
                                  skin: skin,
                                  font: appState.font,
                                  maxCardWidth: maxCW),
                            ],
                          ],
                        )
                      : FlipCardRow(
                          key: const ValueKey('landscape'),
                          values: values,
                          skin: skin,
                          font: appState.font,
                          maxCardWidth: maxCW);

                  return Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.92, end: 1.0)
                              .animate(animation),
                          child: child,
                        ),
                      ),
                      child: flip,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              appState.signature,
              style: TextStyle(
                fontSize: 18 * appState.fontScale,
                color: skin.subTextColor,
                letterSpacing: 2.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
