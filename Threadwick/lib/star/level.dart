import 'rules.dart';

/// One ask: a star of so many nails, in so many strokes.
class Level {
  const Level({
    required this.name,
    required this.nails,
    required this.strokes,
    required this.ways,
    required this.aim,
    required this.note,
  });

  final String name;

  /// The nails the star must have.
  final int nails;

  /// The strokes it must take, exactly.
  final int strokes;

  /// How many of the settings land it, from the sweep.
  final int ways;

  /// The setting the pointer walks to, (nails, skip), or null when none
  /// lands it.
  final (int, int)? aim;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the setting lands the ask: the nails asked, a star and not
  /// the rim, and the strokes asked exactly.
  bool meets(int nails, int skip) => nails == this.nails && Rules.isStar(nails, skip) && Rules.strokes(nails, skip).length == strokes;

  /// The task, told in words for the ledger.
  String get task => 'set the nails and the skip so a star of ${Rules.count(nails)} nails is threaded in ${strokes == 1 ? 'one stroke' : '${Rules.count(strokes)} strokes exactly'}';
}
