import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

/// Picks a photo for the clock background and shrinks it before it is stored.
///
/// The picture is kept as a string in the same store as the other settings, so
/// it has to stay small: a phone photo is several megabytes, which browsers
/// refuse to keep. Shrinking to 1280px on the long side leaves it sharp behind
/// the cards while landing well under a megabyte.
class BackgroundImage {
  BackgroundImage._();

  static const int maxEdge = 1280;
  static const int quality = 78;

  static Future<Uint8List?> pick() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return null;
    final raw = await picked.readAsBytes();
    return compute(shrink, raw);
  }
}

/// Top level so it can run off the main thread on mobile.
Uint8List shrink(Uint8List raw) {
  final decoded = img.decodeImage(raw);
  if (decoded == null) return raw;
  final longEdge =
      decoded.width > decoded.height ? decoded.width : decoded.height;
  final resized = longEdge <= BackgroundImage.maxEdge
      ? decoded
      : img.copyResize(
          decoded,
          width: decoded.width >= decoded.height
              ? BackgroundImage.maxEdge
              : null,
          height: decoded.height > decoded.width
              ? BackgroundImage.maxEdge
              : null,
          interpolation: img.Interpolation.average,
        );
  return img.encodeJpg(resized, quality: BackgroundImage.quality);
}
