import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'timer_notifier.dart';

TimerNotifier createTimerNotifier() => WebTimerNotifier();

/// A browser cannot book a notification for later without a push server, so
/// this only covers a tab that is still alive: a timer waits for the end time
/// and, if the page is not the one being looked at and permission was given,
/// shows a notification. A closed or discarded tab stays silent.
class WebTimerNotifier implements TimerNotifier {
  final Map<int, Timer> _pending = {};

  // setTimeout takes a 32-bit count of milliseconds; a longer wait wraps
  // around and fires at once.
  static const Duration _longestWait = Duration(days: 24);

  bool get _supported => globalContext.has('Notification');

  bool get _granted => _supported && web.Notification.permission == 'granted';

  @override
  Future<bool> requestPermission() async {
    if (!_supported) return false;
    try {
      if (web.Notification.permission == 'default') {
        final answer = await web.Notification.requestPermission().toDart;
        return answer.toDart == 'granted';
      }
    } catch (_) {
      return false;
    }
    return _granted;
  }

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    bool sound = true,
  }) async {
    await cancel(id);
    final wait = at.difference(DateTime.now());
    if (wait <= Duration.zero || wait > _longestWait) return;
    _pending[id] = Timer(wait, () {
      _pending.remove(id);
      // The page shows its own flash and plays its own chime when it is the
      // one in front.
      if (!_granted || web.document.hasFocus()) return;
      try {
        web.Notification(
          title,
          web.NotificationOptions(
            body: body,
            tag: 'flipclock-$id',
            silent: !sound,
          ),
        );
      } catch (_) {
        // Some mobile browsers only allow notifications from a service
        // worker; there is nothing simpler to fall back to.
      }
    });
  }

  @override
  Future<void> cancel(int id) async {
    _pending.remove(id)?.cancel();
  }
}
