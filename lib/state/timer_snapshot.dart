import 'package:flutter/foundation.dart';

/// Everything the Timer page needs to pick up where it left off after the
/// process has been killed. Times are absolute, so the time spent away counts.
@immutable
class TimerSnapshot {
  const TimerSnapshot({
    required this.mode,
    required this.running,
    required this.startedAtMillis,
    required this.accumulatedMillis,
    required this.countDownMillis,
    required this.targetMillis,
  });

  /// Index into `TimerMode.values`: Count Up, Count Down, Target.
  final int mode;
  final bool running;

  /// When the current run began, as milliseconds since the epoch; 0 while
  /// paused.
  final int startedAtMillis;

  /// Time counted before the current run began (the paused total).
  final int accumulatedMillis;

  /// The Count Down length chosen on the wheels.
  final int countDownMillis;

  /// The Target moment, as milliseconds since the epoch; 0 if never set.
  final int targetMillis;

  @override
  bool operator ==(Object other) =>
      other is TimerSnapshot &&
      other.mode == mode &&
      other.running == running &&
      other.startedAtMillis == startedAtMillis &&
      other.accumulatedMillis == accumulatedMillis &&
      other.countDownMillis == countDownMillis &&
      other.targetMillis == targetMillis;

  @override
  int get hashCode => Object.hash(mode, running, startedAtMillis,
      accumulatedMillis, countDownMillis, targetMillis);

  @override
  String toString() => 'TimerSnapshot(mode: $mode, running: $running, '
      'startedAt: $startedAtMillis, accumulated: $accumulatedMillis, '
      'countDown: $countDownMillis, target: $targetMillis)';
}
