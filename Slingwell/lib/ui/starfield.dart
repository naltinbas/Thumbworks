import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../sim/world.dart';
import 'camera.dart';
import 'palette.dart';

/// Specks of light behind the world, drawn slower than it.
///
/// The playfield is empty space and the craft is often the only thing moving,
/// which makes a fast climb look like nothing at all. These give the eye
/// something to measure against. They live in bands of world height so the
/// sky can be endless without anything being stored: which specks a band has
/// is a function of the band's number, so the same stretch of sky looks the
/// same every time it is passed.
class Starfield {
  const Starfield();

  static const _bandMetres = 26.0;
  static const _perBand = 22;

  /// How much slower than the world the sky moves. Far enough back to read as
  /// distance, near enough to still be going by.
  static const _parallax = 0.32;

  static const _seed = 90210;

  void paint(Canvas canvas, Camera camera) {
    final sky = camera.lookingAt(camera.focusY * _parallax);
    final first = (sky.bottomY / _bandMetres).floor();
    final last = (sky.topY / _bandMetres).floor();
    final half = Camera.viewWidthMetres / 2;
    final paint = Paint();

    for (var band = first; band <= last; band++) {
      final random = math.Random(_seed + band * 977);
      for (var i = 0; i < _perBand; i++) {
        final at = Vec(
          (random.nextDouble() * 2 - 1) * half,
          (band + random.nextDouble()) * _bandMetres,
        );
        final bright = 0.08 + random.nextDouble() * 0.34;
        // Sized in pixels, not metres: a speck of sky is a speck on any
        // screen, and one scaled with the world turns into a blob.
        final size = 0.5 + random.nextDouble() * 1.1;
        paint.color = Palette.dust.withValues(alpha: bright);
        canvas.drawCircle(sky.toScreen(at), size, paint);
      }
    }
  }
}
