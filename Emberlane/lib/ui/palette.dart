import 'package:flutter/material.dart';

import '../sim/kinds.dart';

/// The colours.
///
/// A lane cut through dark ground, lit by what is burning along it. The path
/// is the warmest thing on the field because it is where everything happens;
/// the ground either side is nearly black so that a tower on it reads as a
/// thing placed rather than a thing painted.
class Palette {
  const Palette._();

  static const night = Color(0xFF14100E);
  static const ground = Color(0xFF1F1A17);
  static const lane = Color(0xFF463629);
  static const laneEdge = Color(0xFF5E4834);

  /// A square a tower could go on, while one is being placed.
  static const room = Color(0xFF2C3A33);

  /// The square under the finger.
  static const chosen = Color(0xFF3F6154);

  /// What towers cost and what killing things pays.
  static const ember = Color(0xFFF0A030);

  /// What is left of the keep.
  static const keep = Color(0xFFD4553C);

  static const ink = Color(0xFFEDE6DA);
  static const inkDim = Color(0xFF9A8E80);
  static const good = Color(0xFF5FB07A);

  static const veil = Color(0xFF14100E);

  static Color of(Tower tower) => switch (tower) {
        Tower.spark => const Color(0xFFF0C24A),
        Tower.forge => const Color(0xFFE2603A),
        Tower.frost => const Color(0xFF5FB6D8),
      };

  static Color ofWalker(Walker walker) => switch (walker) {
        Walker.drifter => const Color(0xFFC9BFA8),
        Walker.runner => const Color(0xFF9FD98C),
        Walker.lumberer => const Color(0xFFB07A4A),
        Walker.warded => const Color(0xFFA88FD0),
      };
}
