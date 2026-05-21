import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/alerts.dart';
import '../state/app_state.dart';
import '../theme/fonts.dart';
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

  // Reference-time based timing keeps the display accurate across pauses
  // regardless of how precisely the ticker fires.
  Duration _accumulated = Duration.zero;
  DateTime? _startedAt;

  Duration _countDownInitial = const Duration(minutes: 10);
  DateTime _targetTime = DateTime.now().add(const Duration(hours: 1));

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Duration get _elapsed {
    var e = _accumulated;
    if (_running && _startedAt != null) {
      e += DateTime.now().difference(_startedAt!);
    }
    return e;
  }

  void _toggleStart() {
    if (_running) {
      _accumulated = _elapsed;
      _startedAt = null;
      _ticker?.cancel();
      setState(() => _running = false);
      return;
    }
    _startedAt = DateTime.now();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 33), (_) {
      if (!mounted) return;
      setState(() {
        if (_mode == TimerMode.countDown && _elapsed >= _countDownInitial) {
          _finish();
        } else if (_mode == TimerMode.targetTime &&
            DateTime.now().isAfter(_targetTime)) {
          _finish();
        }
      });
    });
    setState(() => _running = true);
  }

  void _finish() {
    _ticker?.cancel();
    _running = false;
    _startedAt = null;
    _accumulated = _countDownInitial;
    Alerts.notify(context.read<AppState>());
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _running = false;
      _accumulated = Duration.zero;
      _startedAt = null;
    });
  }

  void _switchMode(TimerMode mode) {
    _ticker?.cancel();
    setState(() {
      _mode = mode;
      _running = false;
      _accumulated = Duration.zero;
      _startedAt = null;
    });
  }

  Duration _shownDuration() {
    switch (_mode) {
      case TimerMode.countUp:
        return _elapsed;
      case TimerMode.countDown:
        final r = _countDownInitial - _elapsed;
        return r.isNegative ? Duration.zero : r;
      case TimerMode.targetTime:
        final r = _targetTime.difference(DateTime.now());
        return r.isNegative ? Duration.zero : r;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final skin = appState.skin;
    final font = appState.font;
    final d = _shownDuration();
    final hh = (d.inHours % 100).toString().padLeft(2, '0');
    final mm = (d.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    final cc = ((d.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
    final showCenti = _mode != TimerMode.targetTime;

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
              font: font,
            ),
            if (showCenti) ...[
              const SizedBox(height: 14),
              _CentiReadout(value: cc, skin: skin, font: font),
            ],
            const SizedBox(height: 28),
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
                ? () => setState(
                    () => _countDownInitial = Duration(minutes: minutes - 1))
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
                ? () => setState(
                    () => _countDownInitial = Duration(minutes: minutes + 1))
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

/// Centiseconds (1/100 s) shown as a small static readout. It changes too fast
/// to flip, so it is rendered as plain text in the selected digit font.
class _CentiReadout extends StatelessWidget {
  const _CentiReadout({
    required this.value,
    required this.skin,
    required this.font,
  });

  final String value;
  final Skin skin;
  final DigitFont font;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: skin.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: skin.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '.',
            style: font.build(34, skin.digitColor),
          ),
          const SizedBox(width: 2),
          Text(
            value,
            style: font.build(34, skin.digitColor),
          ),
          const SizedBox(width: 8),
          Text(
            '1/100s',
            style: TextStyle(
              color: skin.subTextColor,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
