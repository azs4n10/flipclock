import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/alerts.dart';
import '../state/app_state.dart';
import '../theme/skin.dart';
import '../widgets/flip_card_row.dart';
import '../widgets/pill_button.dart';
import '../widgets/segmented_tabs.dart';

enum TimerMode { countUp, countDown, targetTime }

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  TimerMode _mode = TimerMode.countUp;
  Timer? _ticker;
  bool _running = false;

  Duration _elapsed = Duration.zero;
  Duration _countDownInitial = const Duration(minutes: 10);
  Duration _countDownRemaining = const Duration(minutes: 10);
  DateTime _targetTime = DateTime.now().add(const Duration(hours: 1));
  Duration _targetRemaining = const Duration(hours: 1);

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _toggleStart() {
    if (_running) {
      _ticker?.cancel();
      setState(() => _running = false);
      return;
    }
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted) return;
      setState(() {
        switch (_mode) {
          case TimerMode.countUp:
            _elapsed += const Duration(milliseconds: 250);
            break;
          case TimerMode.countDown:
            if (_countDownRemaining.inMilliseconds <= 250) {
              _countDownRemaining = Duration.zero;
              _ticker?.cancel();
              _running = false;
              Alerts.notify(context.read<AppState>());
            } else {
              _countDownRemaining -= const Duration(milliseconds: 250);
            }
            break;
          case TimerMode.targetTime:
            final diff = _targetTime.difference(DateTime.now());
            _targetRemaining = diff.isNegative ? Duration.zero : diff;
            if (diff.isNegative) {
              _ticker?.cancel();
              _running = false;
              Alerts.notify(context.read<AppState>());
            }
            break;
        }
      });
    });
    setState(() => _running = true);
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _running = false;
      switch (_mode) {
        case TimerMode.countUp:
          _elapsed = Duration.zero;
          break;
        case TimerMode.countDown:
          _countDownRemaining = _countDownInitial;
          break;
        case TimerMode.targetTime:
          _targetRemaining = _targetTime.difference(DateTime.now());
          if (_targetRemaining.isNegative) _targetRemaining = Duration.zero;
          break;
      }
    });
  }

  void _switchMode(TimerMode mode) {
    _ticker?.cancel();
    setState(() {
      _mode = mode;
      _running = false;
      _elapsed = Duration.zero;
      _countDownRemaining = _countDownInitial;
      _targetRemaining = _targetTime.difference(DateTime.now());
      if (_targetRemaining.isNegative) _targetRemaining = Duration.zero;
    });
  }

  Duration _shownDuration() {
    switch (_mode) {
      case TimerMode.countUp:
        return _elapsed;
      case TimerMode.countDown:
        return _countDownRemaining;
      case TimerMode.targetTime:
        return _targetRemaining;
    }
  }

  @override
  Widget build(BuildContext context) {
    final skin = context.watch<AppState>().skin;
    final d = _shownDuration();
    final hh = (d.inHours % 100).toString().padLeft(2, '0');
    final mm = (d.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            SegmentedTabs(
              items: const ['Count Up', 'Count Down', 'Target'],
              selectedIndex: _mode.index,
              onChanged: (i) => _switchMode(TimerMode.values[i]),
              skin: skin,
            ),
            const SizedBox(height: 24),
            _modeConfig(skin),
            const Spacer(),
            FlipCardRow(
              values: [hh, mm, ss],
              labels: const ['HOUR', 'MIN', 'SEC'],
              skin: skin,
            ),
            const SizedBox(height: 32),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                PillButton(
                  label: _running ? 'Pause' : 'Start',
                  onPressed: _toggleStart,
                  skin: skin,
                  icon: _running ? Icons.pause : Icons.play_arrow,
                ),
                PillButton(
                  label: 'Reset',
                  onPressed: _reset,
                  skin: skin,
                  outlined: true,
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _modeConfig(Skin skin) {
    switch (_mode) {
      case TimerMode.countUp:
        return Text(
          'Tap Start to begin',
          style: TextStyle(color: skin.subTextColor, fontSize: 13),
        );
      case TimerMode.countDown:
        return _countDownConfig(skin);
      case TimerMode.targetTime:
        return _targetTimeConfig(skin);
    }
  }

  Widget _countDownConfig(Skin skin) {
    final minutes = _countDownInitial.inMinutes;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: skin.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: skin.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Length: ',
            style: TextStyle(color: skin.primaryTextColor, fontSize: 14),
          ),
          IconButton(
            icon: Icon(Icons.remove_circle_outline, color: skin.accentColor),
            onPressed: minutes > 1 && !_running
                ? () => setState(() {
                      _countDownInitial = Duration(minutes: minutes - 1);
                      _countDownRemaining = _countDownInitial;
                    })
                : null,
          ),
          Text(
            '$minutes min',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: skin.digitColor,
              fontSize: 16,
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: skin.accentColor),
            onPressed: !_running
                ? () => setState(() {
                      _countDownInitial = Duration(minutes: minutes + 1);
                      _countDownRemaining = _countDownInitial;
                    })
                : null,
          ),
        ],
      ),
    );
  }

  Widget _targetTimeConfig(Skin skin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: skin.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: skin.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Target: ',
            style: TextStyle(color: skin.primaryTextColor, fontSize: 14),
          ),
          TextButton(
            onPressed: _running
                ? null
                : () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _targetTime,
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (picked == null || !mounted) return;
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_targetTime),
                    );
                    if (time == null || !mounted) return;
                    setState(() {
                      _targetTime = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        time.hour,
                        time.minute,
                      );
                      _targetRemaining =
                          _targetTime.difference(DateTime.now());
                      if (_targetRemaining.isNegative) {
                        _targetRemaining = Duration.zero;
                      }
                    });
                  },
            child: Text(
              DateFormat('MMM d, yyyy  HH:mm').format(_targetTime),
              style: TextStyle(
                color: skin.digitColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
