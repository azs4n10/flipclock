import 'dart:async';

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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            if (appState.showDate) ...[
              Text(
                dateText,
                style: TextStyle(
                  fontSize: 32,
                  color: skin.primaryTextColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 28),
            ],
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.92, end: 1.0).animate(animation),
                  child: child,
                ),
              ),
              child:
                  MediaQuery.of(context).orientation == Orientation.portrait
                      ? Column(
                          key: const ValueKey('portrait'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (int i = 0; i < values.length; i++) ...[
                              if (i != 0) const SizedBox(height: 14),
                              FlipCardRow(
                                  values: [values[i]],
                                  skin: skin,
                                  font: appState.font,
                                  maxCardWidth: 150),
                            ],
                          ],
                        )
                      : FlipCardRow(
                          key: const ValueKey('landscape'),
                          values: values,
                          skin: skin,
                          font: appState.font),
            ),
            const SizedBox(height: 28),
            Text(
              appState.signature,
              style: TextStyle(
                fontSize: 14,
                color: skin.subTextColor,
                letterSpacing: 2.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
