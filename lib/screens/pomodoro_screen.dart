import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/alerts.dart';
import '../state/app_state.dart';
import '../widgets/flip_card_row.dart';
import '../widgets/pill_button.dart';

enum PomodoroPhase { focus, shortBreak, longBreak }

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  Timer? _ticker;
  PomodoroPhase _phase = PomodoroPhase.focus;
  int _completedFocus = 0;
  Duration _remaining = const Duration(minutes: 25);
  bool _running = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _remaining = Duration(minutes: state.focusMinutes);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _start() {
    if (_running) return;
    _running = true;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds <= 1) {
          _onPhaseEnd();
        } else {
          _remaining -= const Duration(seconds: 1);
        }
      });
    });
    setState(() {});
  }

  void _pause() {
    _ticker?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _ticker?.cancel();
    final state = context.read<AppState>();
    setState(() {
      _running = false;
      _phase = PomodoroPhase.focus;
      _completedFocus = 0;
      _remaining = Duration(minutes: state.focusMinutes);
    });
  }

  void _onPhaseEnd() {
    _ticker?.cancel();
    final state = context.read<AppState>();
    Alerts.notify(state);
    _running = false;
    if (_phase == PomodoroPhase.focus) {
      _completedFocus += 1;
      final isLong = _completedFocus % state.longBreakInterval == 0;
      _phase = isLong ? PomodoroPhase.longBreak : PomodoroPhase.shortBreak;
      _remaining = Duration(
        minutes: isLong ? state.longBreakMinutes : state.shortBreakMinutes,
      );
    } else {
      _phase = PomodoroPhase.focus;
      _remaining = Duration(minutes: state.focusMinutes);
    }
  }

  String _phaseLabel() {
    switch (_phase) {
      case PomodoroPhase.focus:
        return 'Focus';
      case PomodoroPhase.shortBreak:
        return 'Short Break';
      case PomodoroPhase.longBreak:
        return 'Long Break';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final skin = state.skin;

    final totalSeconds = _remaining.inSeconds;
    final mm = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final ss = (totalSeconds % 60).toString().padLeft(2, '0');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              _phaseLabel(),
              style: TextStyle(
                fontSize: 32,
                letterSpacing: 3,
                color: skin.primaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  // Fit the MM:SS cards into the available height too.
                  final maxCW = math.max(
                      24.0, math.min(280.0, c.maxHeight * 0.85 * 0.94));
                  return Center(
                    child: FlipCardRow(
                      values: [mm, ss],
                      skin: skin,
                      font: state.font,
                      maxCardWidth: maxCW,
                    ),
                  );
                },
              ),
            ),
            Text(
              'Completed: $_completedFocus',
              style: TextStyle(
                color: skin.subTextColor,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                if (_running)
                  PillButton(
                    label: 'Pause',
                    onPressed: _pause,
                    skin: skin,
                    icon: Icons.pause,
                  )
                else
                  PillButton(
                    label: 'Start ${_phaseLabel()}',
                    onPressed: _start,
                    skin: skin,
                    icon: Icons.play_arrow,
                  ),
                PillButton(
                  label: 'Reset',
                  onPressed: _reset,
                  skin: skin,
                  outlined: true,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
