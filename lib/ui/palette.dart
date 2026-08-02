import 'package:flutter/material.dart';

/// The colours.
///
/// A runner is read at speed and mostly out of the corner of an eye, so there
/// are four things on screen and they are as far apart as four colours get:
/// a dark sky, a darker ground, one bright runner, and one alarming red for
/// the only thing that is trying to hurt you.
class Palette {
  const Palette._();

  static const sky = Color(0xFF161B2E);
  static const skyLow = Color(0xFF232A45);

  /// The ground, in silhouette.
  static const ground = Color(0xFF0C0F1B);

  /// Whatever is a long way behind it, going by more slowly.
  static const far = Color(0xFF1E2540);

  /// The lit edge along the top of it, which is what makes a step read as a
  /// step rather than as a hole in the sky.
  static const edge = Color(0xFF3C4E7C);

  /// The one thing on the field that is out to get you.
  static const spike = Color(0xFFE2536B);

  /// The runner.
  static const runner = Color(0xFFF2C14E);
  static const runnerDark = Color(0xFFC08A1E);

  static const ink = Color(0xFFECEFF7);
  static const inkDim = Color(0xFF8791AE);
  static const good = Color(0xFFF2C14E);

  static const veil = Color(0xFF161B2E);
}
