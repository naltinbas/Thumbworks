import 'package:flutter/material.dart';

/// The colours.
///
/// An estate map on a table by lamplight. The fields are bare linen until
/// somebody puts a dye on them, and the hedges between them are drawn in the
/// darkest thing on the screen so that the shape of the land reads before any
/// of the colour does.
class Palette {
  const Palette._();

  static const night = Color(0xFF0E1317);
  static const verge = Color(0xFF171E24);
  static const line = Color(0xFF232C34);
  static const edge = Color(0xFF39454F);

  static const bare = Color(0xFF2C353D);
  static const hedge = Color(0xFF070A0C);

  /// The dyes, in the order the pots come out.
  static const dyes = <Color>[
    Color(0xFFC2564E),
    Color(0xFF4E7FC2),
    Color(0xFF6FA35A),
    Color(0xFFD2A64B),
    Color(0xFF8B6BB0),
  ];

  /// What each one is called, for the things the game says out loud.
  static const dyeNames = <String>['red', 'blue', 'green', 'gold', 'purple'];

  static const ink = Color(0xFFE9EEF3);
  static const inkDim = Color(0xFF8A939D);
  static const good = Color(0xFF7FB86D);
  static const bad = Color(0xFFE2645A);
}
