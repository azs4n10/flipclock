import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/alerts.dart';
import '../state/app_state.dart';
import '../widgets/completion_flash.dart';
import '../widgets/flip_card_row.dart';
import '../widgets/pill_button.dart';

enum PomodoroPhase { focus, shortBreak, longBreak }

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen>
    with WidgetsBindingObserver {
  Timer? _ticker;
  PomodoroPhase _phase = PomodoroPhase.focus;
  int _completedFocus = 0;
  Duration _remaining = const Duration(minutes: 25);
  bool _running = false;
  // Absolute end time while running; elapsed is derived from the wall clock so
  // time keeps counting while the app is backgrounded.
  DateTime? _endAt;
  int _flashTick = 0;
  String _flashMsg = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final state = context.read<AppState>();
    _restore(state);
  }

  void _restore(AppState state) {
    _phase = PomodoroPhase.values[
        state.pomoPhase.clamp(0, PomodoroPhase.values.length - 1)];
    _completedFocus = state.pomoCompleted;
    if (state.pomoRunning && state.pomoEndMillis > 0) {
      final end = DateTime.fromMillisecondsSinceEpoch(state.pomoEndMillis);
      final left = end.difference(DateTime.now());
      if (left > Duration.zero) {
        _endAt = end;
        _remaining = left;
        _running = true;
        _startTicker();
        return;
      }
      // Ended while away: show the phase finished, ready to start the next.
      _running = false;
      _remaining = Duration.zero;
      return;
    }
    final saved = state.pomoRemainingSec;
    _remaining = saved > 0
        ? Duration(seconds: saved)
        : Duration(minutes: state.focusMinutes);
    _running = false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.resumed && _running) {
      // Recompute immediately so the display catches up after backgrounding.
      setState(_syncFromClock);
    }
  }

  void _syncFromClock() {
    if (_endAt == null) return;
    final left = _endAt!.difference(DateTime.now());
    if (left <= Duration.zero) {
      _onPhaseEnd();
    } else {
      _remaining = left;
    }
  }

  void _persist() {
    context.read<AppState>().savePomodoro(
          phase: _phase.index,
          completed: _completedFocus,
          running: _running,
          endMillis: _endAt?.millisecondsSinceEpoch ?? 0,
          remainingSec: _remaining.inSeconds,
        );
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      setState(_syncFromClock);
    });
  }

  void _start() {
    if (_running) return;
    if (_remaining <= Duration.zero) return;
    _running = true;
    _endAt = DateTime.now().add(_remaining);
    _startTicker();
    _persist();
    setState(() {});
  }

  void _pause() {
    _syncFromClock();
    _ticker?.cancel();
    _running = false;
    _endAt = null;
    _persist();
    setState(() {});
  }

  void _reset() {
    _ticker?.cancel();
    final state = context.read<AppState>();
    setState(() {
      _running = false;
      _endAt = null;
      _phase = PomodoroPhase.focus;
      _completedFocus = 0;
      _remaining = Duration(minutes: state.focusMinutes);
    });
    _persist();
  }

  void _onPhaseEnd() {
    _ticker?.cancel();
    final state = context.read<AppState>();
    Alerts.notify(state);
    _flashMsg = _phase == PomodoroPhase.focus ? 'Focus complete' : 'Break over';
    _flashTick++;
    _running = false;
    _endAt = null;
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
    _persist();
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

    return Stack(
      children: [
        SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              _phaseLabel(),
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                letterSpacing: 3,
                color: skin.primaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              flex: 6,
              child: LayoutBuilder(
                builder: (context, c) {
                  final portrait = MediaQuery.of(context).orientation ==
                      Orientation.portrait;
                  final fs = state.fontScale;
                  const aspect = 0.85;
                  const rowGap = 14.0;
                  final values = [mm, ss];
                  double maxCW;
                  if (portrait) {
                    final rows = values.length;
                    final hPer =
                        (c.maxHeight - rowGap * (rows - 1)) / rows * 0.98;
                    maxCW = math.min(
                        170 * fs, math.min(hPer * aspect, c.maxWidth));
                  } else {
                    maxCW = math.min(280 * fs, c.maxHeight * aspect * 0.94);
                  }
                  maxCW = math.max(24.0, maxCW);
                  final flip = portrait
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (int i = 0; i < values.length; i++) ...[
                              if (i != 0) const SizedBox(height: rowGap),
                              FlipCardRow(
                                  values: [values[i]],
                                  skin: skin,
                                  font: state.font,
                                  maxCardWidth: maxCW),
                            ],
                          ],
                        )
                      : FlipCardRow(
                          values: values,
                          skin: skin,
                          font: state.font,
                          maxCardWidth: maxCW);
                  return Center(child: flip);
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
            const Expanded(flex: 1, child: SizedBox.shrink()),
          ],
        ),
      ),
        ),
        Positioned.fill(
          child: CompletionFlash(
            trigger: _flashTick,
            skin: skin,
            message: _flashMsg,
          ),
        ),
      ],
    );
  }
}
