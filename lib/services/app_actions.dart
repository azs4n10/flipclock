import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Share / feedback / rate actions. Each is wrapped so an unsupported platform
/// (e.g. desktop web without the Web Share API) fails silently instead of
/// crashing.
class AppActions {
  AppActions._();

  static const String _shareText =
      'Flipclock — a cute pastel flip clock with timer & pomodoro';

  static Future<void> share() async {
    try {
      await Share.share(_shareText);
    } catch (_) {}
  }

  static Future<void> feedback() async {
    final uri = Uri(scheme: 'mailto', query: 'subject=Flipclock Feedback');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  static Future<void> rate() async {
    try {
      final review = InAppReview.instance;
      if (await review.isAvailable()) {
        await review.requestReview();
      }
    } catch (_) {}
  }
}
