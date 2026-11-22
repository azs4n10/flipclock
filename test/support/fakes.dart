import 'package:flipclock/services/bgm.dart';
import 'package:flipclock/services/timer_notifier.dart';

class BookedNotice {
  const BookedNotice({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
    required this.sound,
  });

  final int id;
  final DateTime at;
  final String title;
  final String body;
  final bool sound;
}

/// Records what the app asks of the notification system, in order.
class FakeTimerNotifier implements TimerNotifier {
  /// `ask`, `schedule:ID` and `cancel:ID` in the order they arrived.
  final List<String> log = [];

  /// Every notice ever booked, oldest first.
  final List<BookedNotice> booked = [];

  /// What would still be delivered: the last booking per id not yet cancelled.
  final Map<int, BookedNotice> pending = {};

  bool grant = true;

  int get asks => log.where((e) => e == 'ask').length;

  @override
  Future<bool> requestPermission() async {
    log.add('ask');
    return grant;
  }

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    bool sound = true,
  }) async {
    log.add('schedule:$id');
    final notice =
        BookedNotice(id: id, at: at, title: title, body: body, sound: sound);
    booked.add(notice);
    pending[id] = notice;
  }

  @override
  Future<void> cancel(int id) async {
    log.add('cancel:$id');
    pending.remove(id);
  }
}

/// Records which tracks were asked for; [succeed] false stands for a browser
/// that is still refusing to start sound.
class FakeBgmPlayer implements BgmPlayer {
  final List<String> played = [];
  bool succeed = true;

  @override
  Future<bool> play(String id) async {
    if (!succeed) return false;
    played.add(id);
    return true;
  }
}
