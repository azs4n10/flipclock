import 'timer_notifier.dart';

TimerNotifier createTimerNotifier() => const SilentTimerNotifier();

/// For platforms with no way to notify.
class SilentTimerNotifier implements TimerNotifier {
  const SilentTimerNotifier();

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    bool sound = true,
  }) async {}

  @override
  Future<void> cancel(int id) async {}
}
