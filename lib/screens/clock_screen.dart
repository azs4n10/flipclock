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
    final skin = context.watch<AppState>().skin;
    final hh = _now.hour.toString().padLeft(2, '0');
    final mm = _now.minute.toString().padLeft(2, '0');
    final ss = _now.second.toString().padLeft(2, '0');
    final dateText = DateFormat('MMM d, yyyy  EEE').format(_now);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              dateText,
              style: TextStyle(
                fontSize: 16,
                color: skin.primaryTextColor,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 28),
            FlipCardRow(values: [hh, mm, ss], skin: skin),
            const SizedBox(height: 28),
            Text(
              'less is more',
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
