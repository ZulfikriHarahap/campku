import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/data/destinations_data.dart';

/// Menampilkan foto `assets/images/<slug>.jpg`.
/// Jika file foto belum ada, otomatis tampil ilustrasi lanskap sesuai kategori.
class DestinationImage extends StatelessWidget {
  const DestinationImage({super.key, required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      destination.imageAsset,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      semanticLabel: destination.name,
      errorBuilder: (context, error, stackTrace) => LandscapeArt(
        category: destination.category,
        seed: destination.slug.codeUnits
            .fold<int>(7, (hash, unit) => (hash * 31 + unit) & 0x7fffffff),
      ),
    );
  }
}

/// Ilustrasi lanskap sederhana. [seed] membuat tiap destinasi terlihat berbeda.
class LandscapeArt extends StatelessWidget {
  const LandscapeArt({super.key, required this.category, this.seed = 1});

  final String category;
  final int seed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(painter: _LandscapePainter(category, seed)),
    );
  }
}

class _LandscapePainter extends CustomPainter {
  _LandscapePainter(this.category, this.seed);

  final String category;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed);
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    final List<Color> sky = switch (category) {
      'Gunung' => const [Color(0xFF7FB2AA), Color(0xFFF7DDB0)],
      'Danau' => const [Color(0xFF8EC0DA), Color(0xFFE9F3EE)],
      'Air Terjun' => const [Color(0xFFA5CFC6), Color(0xFFE3F1EA)],
      'Hutan' => const [Color(0xFFBBD8B0), Color(0xFFF2F4D6)],
      _ => const [Color(0xFFF5D9A6), Color(0xFFDFEDE2)],
    };
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: sky,
        ).createShader(rect),
    );
    canvas.drawCircle(
      Offset(w * (0.2 + 0.6 * rnd.nextDouble()), h * 0.24),
      h * 0.085,
      Paint()..color = Colors.white.withAlpha(200),
    );

    switch (category) {
      case 'Gunung':
        _ridge(canvas, size, rnd, 0.55, 0.30, const Color(0xFF8FB8A8), true);
        _ridge(canvas, size, rnd, 0.70, 0.28, const Color(0xFF3F7A66), true);
        _ridge(canvas, size, rnd, 0.90, 0.16, kPrimary, false);
      case 'Danau':
        _ridge(canvas, size, rnd, 0.52, 0.22, const Color(0xFF8FB8A8), false);
        canvas.drawRect(
          Rect.fromLTWH(0, h * 0.54, w, h * 0.46),
          Paint()..color = const Color(0xFF4F94AD),
        );
        final ripple = Paint()
          ..color = Colors.white.withAlpha(90)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
        for (var i = 0; i < 5; i++) {
          final y = h * (0.60 + 0.07 * i);
          final x = w * (0.10 + 0.6 * rnd.nextDouble());
          canvas.drawLine(Offset(x, y), Offset(x + w * 0.2, y), ripple);
        }
        _ridge(canvas, size, rnd, 0.97, 0.12, kPrimary, false);
      case 'Air Terjun':
        canvas.drawRect(
          Rect.fromLTWH(0, h * 0.34, w, h * 0.66),
          Paint()..color = const Color(0xFF2A5B4B),
        );
        _ridge(canvas, size, rnd, 0.38, 0.08, const Color(0xFF2A5B4B), false);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.44, h * 0.34, w * 0.12, h * 0.46),
            const Radius.circular(6),
          ),
          Paint()..color = Colors.white.withAlpha(235),
        );
        final streak = Paint()
          ..color = const Color(0xFFBFE3E0)
          ..strokeWidth = 2;
        for (var i = 1; i < 4; i++) {
          final x = w * (0.44 + 0.03 * i);
          canvas.drawLine(Offset(x, h * 0.38), Offset(x, h * 0.76), streak);
        }
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.8),
            width: w * 0.55,
            height: h * 0.12,
          ),
          Paint()..color = const Color(0xFF7BC0C4),
        );
        canvas.drawCircle(
          Offset(w * 0.5, h * 0.8),
          h * 0.05,
          Paint()..color = Colors.white.withAlpha(150),
        );
        _trees(canvas, size, rnd, 1.0, 6, 0.30, kPrimary);
      case 'Hutan':
        _ridge(canvas, size, rnd, 0.52, 0.22, const Color(0xFFA6C9A0), false);
        _ridge(canvas, size, rnd, 0.66, 0.18, const Color(0xFF5E9A7E), false);
        _trees(canvas, size, rnd, 0.80, 9, 0.24, kPrimaryLight);
        _trees(canvas, size, rnd, 1.0, 6, 0.42, kPrimary);
      default:
        _ridge(canvas, size, rnd, 0.56, 0.24, const Color(0xFF8FB8A8), false);
        _ridge(canvas, size, rnd, 0.66, 0.16, const Color(0xFF3F7A66), false);
        _trees(canvas, size, rnd, 0.72, 5, 0.16, kPrimary);
        final river = Path()
          ..moveTo(w * 0.48, h * 0.62)
          ..cubicTo(w * 0.42, h * 0.74, w * 0.52, h * 0.86, w * 0.25, h)
          ..lineTo(w * 0.80, h)
          ..cubicTo(w * 0.72, h * 0.86, w * 0.60, h * 0.76, w * 0.52, h * 0.62)
          ..close();
        canvas.drawPath(river, Paint()..color = const Color(0xFF5DA0B5));
    }
  }

  /// Punggungan bukit: [jagged] true = lancip (gunung), false = membulat.
  void _ridge(Canvas canvas, Size size, math.Random rnd, double baseY,
      double amp, Color color, bool jagged) {
    final w = size.width;
    final h = size.height;
    final base = h * baseY;
    const steps = 5;
    final path = Path()
      ..moveTo(0, h)
      ..lineTo(0, base);
    for (var i = 1; i <= steps; i++) {
      final mx = w * (i - 0.5) / steps;
      final ex = w * i / steps;
      final peak = base - h * amp * (0.35 + 0.65 * rnd.nextDouble());
      final valley = base - h * amp * 0.25 * rnd.nextDouble();
      if (jagged) {
        path
          ..lineTo(mx, peak)
          ..lineTo(ex, valley);
      } else {
        path.quadraticBezierTo(mx, peak, ex, valley);
      }
    }
    path
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  /// Barisan pohon cemara segitiga.
  void _trees(Canvas canvas, Size size, math.Random rnd, double baseY,
      int count, double scale, Color color) {
    final w = size.width;
    final h = size.height;
    final y = h * baseY;
    final paint = Paint()..color = color;
    for (var i = 0; i < count; i++) {
      final x = w * (i + 0.5 + (rnd.nextDouble() - 0.5) * 0.5) / count;
      final treeH = h * scale * (0.7 + 0.6 * rnd.nextDouble());
      final treeW = treeH * 0.45;
      final tree = Path()
        ..moveTo(x, y - treeH)
        ..lineTo(x + treeW / 2, y)
        ..lineTo(x - treeW / 2, y)
        ..close();
      canvas.drawPath(tree, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LandscapePainter oldDelegate) =>
      oldDelegate.category != category || oldDelegate.seed != seed;
}
