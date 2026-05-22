import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Motifs roughly follow the Japanese calendar: cherry blossoms only in the
// short Mar–Apr bloom, fresh green for May–Jun, bubbles in midsummer, maple
// leaves in autumn, snow in winter.
enum Season { sakura, fresh, summer, autumn, winter }

Season seasonForMonth(int month) {
  if (month == 3 || month == 4) return Season.sakura;
  if (month == 5 || month == 6) return Season.fresh;
  if (month == 7 || month == 8) return Season.summer;
  if (month >= 9 && month <= 11) return Season.autumn;
  return Season.winter; // 12, 1, 2
}

class _SeasonConfig {
  const _SeasonConfig({
    required this.count,
    required this.colors,
    required this.shape,
    required this.rising,
    required this.minSize,
    required this.maxSize,
    required this.minSpeed,
    required this.maxSpeed,
  });
  final int count;
  final List<Color> colors;
  final _Shape shape;
  final bool rising; // summer bubbles drift up
  final double minSize;
  final double maxSize;
  final double minSpeed; // fraction of height per second
  final double maxSpeed;
}

enum _Shape { sakura, leaf, snow, bubble }

const Map<Season, _SeasonConfig> _configs = {
  Season.sakura: _SeasonConfig(
    count: 18,
    colors: [Color(0xFFF8A5C2), Color(0xFFFFC0E2), Color(0xFFFFD6E8)],
    shape: _Shape.sakura,
    rising: false,
    minSize: 12,
    maxSize: 20,
    minSpeed: 0.05,
    maxSpeed: 0.10,
  ),
  Season.fresh: _SeasonConfig(
    count: 16,
    colors: [Color(0xFFA8D5A2), Color(0xFFC3E6B4), Color(0xFF9FCF8E)],
    shape: _Shape.leaf,
    rising: false,
    minSize: 10,
    maxSize: 18,
    minSpeed: 0.05,
    maxSpeed: 0.10,
  ),
  Season.summer: _SeasonConfig(
    count: 14,
    colors: [Color(0xFFBFE9FF), Color(0xFFD8F5E8), Color(0xFFFFFFFF)],
    shape: _Shape.bubble,
    rising: true,
    minSize: 8,
    maxSize: 20,
    minSpeed: 0.03,
    maxSpeed: 0.07,
  ),
  Season.autumn: _SeasonConfig(
    count: 16,
    colors: [Color(0xFFFFB088), Color(0xFFE8915C), Color(0xFFD9736B)],
    shape: _Shape.leaf,
    rising: false,
    minSize: 10,
    maxSize: 18,
    minSpeed: 0.05,
    maxSpeed: 0.11,
  ),
  Season.winter: _SeasonConfig(
    count: 24,
    colors: [Color(0xFFFFFFFF), Color(0xFFEAF2FF)],
    shape: _Shape.snow,
    rising: false,
    minSize: 5,
    maxSize: 11,
    minSpeed: 0.04,
    maxSpeed: 0.09,
  ),
};

class _Particle {
  _Particle(math.Random r, this.cfg)
      : x = r.nextDouble(),
        phase0 = r.nextDouble(),
        speed = cfg.minSpeed + r.nextDouble() * (cfg.maxSpeed - cfg.minSpeed),
        size = cfg.minSize + r.nextDouble() * (cfg.maxSize - cfg.minSize),
        swayAmp = 0.02 + r.nextDouble() * 0.05,
        swayFreq = 0.3 + r.nextDouble() * 0.6,
        swayPhase = r.nextDouble() * math.pi * 2,
        rotSpeed = (r.nextDouble() - 0.5) * 1.5,
        color = cfg.colors[r.nextInt(cfg.colors.length)];

  final _SeasonConfig cfg;
  final double x;
  final double phase0; // 0..1 vertical start offset
  final double speed;
  final double size;
  final double swayAmp;
  final double swayFreq;
  final double swayPhase;
  final double rotSpeed;
  final Color color;
}

class SeasonalOverlay extends StatefulWidget {
  const SeasonalOverlay({super.key, required this.season});

  final Season season;

  @override
  State<SeasonalOverlay> createState() => _SeasonalOverlayState();
}

class _SeasonalOverlayState extends State<SeasonalOverlay>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  // Real-time clock so motion is correct even when the OS "reduce motion"
  // setting makes the framework's animation clock run fast on web.
  final Stopwatch _watch = Stopwatch()..start();
  late List<_Particle> _particles;
  double _t = 0;

  @override
  void initState() {
    super.initState();
    _rebuildParticles();
    _ticker = createTicker((_) {
      setState(() => _t = _watch.elapsedMilliseconds / 1000.0);
    })
      ..start();
  }

  void _rebuildParticles() {
    final cfg = _configs[widget.season]!;
    final r = math.Random(widget.season.index + 7);
    _particles = List.generate(cfg.count, (_) => _Particle(r, cfg));
  }

  @override
  void didUpdateWidget(covariant SeasonalOverlay old) {
    super.didUpdateWidget(old);
    if (old.season != widget.season) _rebuildParticles();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _SeasonalPainter(_particles, _t),
        size: Size.infinite,
      ),
    );
  }
}

class _SeasonalPainter extends CustomPainter {
  _SeasonalPainter(this.particles, this.t);

  final List<_Particle> particles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      // Vertical progress wraps 0..1 (down) or 1..0 (up for bubbles).
      var v = (p.phase0 + p.speed * t) % 1.0;
      final y = (p.cfg.rising ? 1.0 - v : v) * size.height;
      final x = (p.x + p.swayAmp * math.sin(p.swayFreq * t + p.swayPhase)) *
          size.width;
      paint.color = p.color.withValues(alpha: 0.65);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotSpeed * t);
      _drawShape(canvas, paint, p.cfg.shape, p.size);
      canvas.restore();
    }
  }

  void _drawShape(Canvas canvas, Paint paint, _Shape shape, double s) {
    switch (shape) {
      case _Shape.snow:
        canvas.drawCircle(Offset.zero, s / 2, paint);
        break;
      case _Shape.bubble:
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(Offset.zero, s / 2, paint);
        paint.style = PaintingStyle.fill;
        break;
      case _Shape.sakura:
        // Cherry-blossom petal: rounded body with a small notch at the tip.
        final h = s * 0.5;
        final w = s * 0.42;
        final path = Path()
          ..moveTo(0, h) // base (stem end)
          ..cubicTo(w, h * 0.4, w, -h * 0.55, w * 0.32, -h)
          ..lineTo(0, -h * 0.7) // notch in
          ..lineTo(-w * 0.32, -h)
          ..cubicTo(-w, -h * 0.55, -w, h * 0.4, 0, h)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case _Shape.leaf:
        final path = Path()
          ..moveTo(0, -s / 2)
          ..quadraticBezierTo(s / 2, 0, 0, s / 2)
          ..quadraticBezierTo(-s / 2, 0, 0, -s / 2)
          ..close();
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(_SeasonalPainter old) => old.t != t;
}
