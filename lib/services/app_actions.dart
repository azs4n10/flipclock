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

  /// Published alongside the web build, so it goes live with the next deploy.
  static const String privacyUrl =
      'https://azs4n10.github.io/flipclock/privacy.html';

  /// Empty until the app has an address of its own. While it is empty the
  /// feedback entry stays hidden rather than opening a blank mail draft.
  /// Set it with tool/set_contact_email.py, which also updates the policy.
  static const String contactEmail = 'kamiyo.desk24@gmail.com';

  static Future<void> share() async {
    try {
      await Share.share(_shareText);
    } catch (_) {}
  }

  static Future<void> feedback() async {
    if (contactEmail.isEmpty) return;
    final uri = Uri(
      scheme: 'mailto',
      path: contactEmail,
      query: 'subject=Flipclock Feedback',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  static Future<void> privacy() async {
    try {
      await launchUrl(
        Uri.parse(privacyUrl),
        mode: LaunchMode.externalApplication,
      );
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
