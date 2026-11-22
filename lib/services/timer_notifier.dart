import 'timer_notifier_stub.dart'
    if (dart.library.io) 'timer_notifier_mobile.dart'
    if (dart.library.js_interop) 'timer_notifier_web.dart' as impl;

/// Tells the user a countdown has ended while the app is not in front.
///
/// Kept this small so the screens can be tested against a fake: a notice is
/// booked for a known end time when a countdown starts, and withdrawn when it
/// is paused, reset or replaced. Booking an [id] again replaces the earlier
/// notice with that id.
abstract class TimerNotifier {
  /// Asks for permission to notify. Returns whether it is granted.
  Future<bool> requestPermission();

  Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    bool sound = true,
  });

  /// Withdraws a pending notice, and clears it if it is already showing.
  Future<void> cancel(int id);
}

/// One slot per countdown, so the Pomodoro and the Timer never overwrite
/// one another's notice.
abstract final class NoticeId {
  static const int pomodoro = 1;
  static const int timer = 2;
}

/// Local notifications on Android and iOS, the browser's Notification API on
/// the web, and nothing anywhere else.
TimerNotifier createTimerNotifier() => impl.createTimerNotifier();
