import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
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
  // Count Down length set via the iOS-style scroll wheels.
  int _cdH = 0;
  int _cdM = 10;
  int _cdS = 0;
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
    if (_mode == TimerMode.countDown) {
      _countDownInitial =
          Duration(hours: _cdH, minutes: _cdM, seconds: _cdS);
      if (_countDownInitial == Duration.zero) return; // nothing to count down
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
            const SizedBox(height: 6),
            SegmentedTabs(
              items: const ['Count Up', 'Count Down', 'Target'],
              selectedIndex: _mode.index,
              onChanged: (i) => _switchMode(TimerMode.values[i]),
              skin: skin,
            ),
            const SizedBox(height: 10),
            _modeConfig(skin),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  // Reserve a little for the HOUR/MIN/SEC labels, then fit the
                  // cards/wheels into the remaining height.
                  final limit = math.max(
                      24.0, math.min(240.0, (c.maxHeight - 36) * 0.85));
                  final center = _mode == TimerMode.countDown && !_running
                      ? _countdownWheels(skin, font, limit)
                      : FlipCardRow(
                          values: [hh, mm, ss],
                          labels: const ['HOUR', 'MIN', 'SEC'],
                          skin: skin,
                          font: font,
                          maxCardWidth: limit,
                          // Centiseconds as a 4th static card next to SEC
                          // (stopwatch style), only when relevant.
                          staticTail: showCenti ? cc : null,
                          staticTailLabel: showCenti ? '' : null,
                        );
                  return Center(child: center);
                },
              ),
            ),
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
            const SizedBox(height: 14),
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
        return Text(
          _running ? '' : 'Scroll to set the length',
          style: TextStyle(color: skin.subTextColor, fontSize: 13),
        );
      case TimerMode.targetTime:
        return _targetTimeConfig(skin);
    }
  }

  Widget _countdownWheels(Skin skin, DigitFont font, double maxWheelWidth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Match FlipCardRow's sizing so the wheels and the running flip cards
        // are the same size; also cap by the height-derived limit.
        final gap = constraints.maxWidth / 12 * 0.7;
        final wheelWidth =
            math.min((constraints.maxWidth - gap * 2) / 3, maxWheelWidth)
                .clamp(0.0, 240.0);
        final cardHeight = wheelWidth / 0.85;
        Widget wheel(int count, int value, ValueChanged<int> onChanged,
            String label) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: wheelWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  color: skin.cardBackground,
                  borderRadius: BorderRadius.circular(wheelWidth * 0.15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: CupertinoPicker(
                  scrollController:
                      FixedExtentScrollController(initialItem: value),
                  // Item == card height so the selected number is exactly the
                  // size of the running flip digit (no jump on Start).
                  itemExtent: cardHeight,
                  squeeze: 1.0,
                  diameterRatio: 100,
                  backgroundColor: skin.cardBackground,
                  selectionOverlay: Center(
                    child: Container(
                        height: 2, width: wheelWidth, color: skin.dividerColor),
                  ),
                  onSelectedItemChanged: onChanged,
                  children: List.generate(count, (i) {
                    final two = i.toString().padLeft(2, '0');
                    // Lay out each digit in half the card width, exactly like
                    // FlipGroup, so the numbers match the running flip.
                    Widget digit(String ch) => SizedBox(
                          width: wheelWidth / 2,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: (wheelWidth / 2) * 0.08,
                              vertical: cardHeight * 0.10,
                            ),
                            child: Center(
                              child: Transform.translate(
                                offset:
                                    Offset(0, font.centerBias * cardHeight),
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(ch,
                                      style: font.build(
                                          cardHeight * 0.92, skin.digitColor)),
                                ),
                              ),
                            ),
                          ),
                        );
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [digit(two[0]), digit(two[1])],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: wheelWidth,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: skin.subTextColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            wheel(24, _cdH, (v) => setState(() => _cdH = v), 'HOUR'),
            SizedBox(width: gap),
            wheel(60, _cdM, (v) => setState(() => _cdM = v), 'MIN'),
            SizedBox(width: gap),
            wheel(60, _cdS, (v) => setState(() => _cdS = v), 'SEC'),
          ],
        );
      },
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

