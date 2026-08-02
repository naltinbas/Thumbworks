import 'package:flutter/material.dart';

import '../play/session.dart';

/// The colours.
///
/// Four lanes need four colours a player can tell apart in the corner of an
/// eye while a note is falling at them, so they are spread right around the
/// wheel rather than being four shades of one idea.
class Palette {
  const Palette._();

  static const night = Color(0xFF0E1119);
  static const stage = Color(0xFF161B27);

  /// The line notes are hit on.
  static const line = Color(0xFF3E4A63);
  static const lineLit = Color(0xFFE8EDF7);

  static const ink = Color(0xFFEDF1F8);
  static const inkDim = Color(0xFF8892A8);

  static const perfect = Color(0xFF5AD1A6);
  static const good = Color(0xFFE8C25A);
  static const missed = Color(0xFFDD6070);

  static const veil = Color(0xFF0E1119);

  static const _lanes = [
    Color(0xFF5AB0E8),
    Color(0xFF7A7FE0),
    Color(0xFFD07AD0),
    Color(0xFFE8905A),
  ];

  static Color of(int lane) => _lanes[lane % _lanes.length];

  static Color say(Judgement judgement) => switch (judgement) {
        Judgement.perfect => perfect,
        Judgement.good => good,
        Judgement.missed => missed,
      };
}
