import 'dart:io' show Platform;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'timer_notifier.dart';
import 'timer_notifier_stub.dart';

TimerNotifier createTimerNotifier() => Platform.isAndroid || Platform.isIOS
    ? LocalTimerNotifier()
    : const SilentTimerNotifier();

/// Books a local notification with the operating system, so it is delivered
/// at the end time even if the app has been suspended or killed since.
class LocalTimerNotifier implements TimerNotifier {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  Future<bool>? _ready;

  Future<bool> _init() => _ready ??= _doInit();

  Future<bool> _doInit() async {
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          // The launcher mark: white on transparent, as a status bar icon
          // has to be.
          android: AndroidInitializationSettings('ic_launcher_foreground'),
          // Permission is asked for when the first countdown starts, not as
          // a side effect of setting the plugin up.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    if (!await _init()) return false;
    try {
      if (Platform.isAndroid) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        return await android?.requestNotificationsPermission() ?? false;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(alert: true, sound: true) ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    bool sound = true,
  }) async {
    if (!at.isAfter(DateTime.now())) return;
    if (!await _init()) return;
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        // An absolute instant, so UTC says everything and no time zone
        // database has to be loaded.
        scheduledDate: tz.TZDateTime.from(at, tz.UTC),
        notificationDetails: NotificationDetails(
          // Android fixes a channel's sound when the channel is created, so
          // the silent variant needs a channel of its own.
          android: AndroidNotificationDetails(
            sound ? 'timer_done' : 'timer_done_silent',
            sound ? 'Timer finished' : 'Timer finished (silent)',
            channelDescription: 'Shown when a timer or a Pomodoro phase ends',
            importance: Importance.high,
            priority: Priority.high,
            playSound: sound,
            category: AndroidNotificationCategory.alarm,
          ),
          // On iOS this flag is also what attaches the sound to a notice
          // delivered in the background.
          iOS: DarwinNotificationDetails(presentSound: sound),
        ),
        // Inexact on purpose: exact alarms need SCHEDULE_EXACT_ALARM or
        // USE_EXACT_ALARM, which the stores ask an app to justify. The
        // system may deliver a little late while the device is idle.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {
      // Permission refused or the platform declined; the in-app chime and
      // flash still fire if the app is open.
    }
  }

  @override
  Future<void> cancel(int id) async {
    if (!await _init()) return;
    try {
      await _plugin.cancel(id: id);
    } catch (_) {}
  }
}
