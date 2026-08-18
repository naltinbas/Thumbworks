import 'rules.dart';

/// One ask: a plait, to be painted so every crossing sits right and all
/// three colours are used.
class Level {
  const Level({
    required this.name,
    required this.strands,
    required this.word,
    required this.knot,
    required this.ways,
    required this.legal,
    required this.fewest,
    required this.note,
  });

  final String name;

  /// How many ropes run down the plait.
  final int strands;

  /// The crossings, top to bottom. A turn of k crosses lane k over lane
  /// k+1, and a turn of -k crosses it under.
  final List<int> word;

  /// What the closed plait is, said in words.
  final String knot;

  /// How many paintings keep the rule and use all three colours. The
  /// sweep's number, and the checker refuses the bake if it drifts.
  final int ways;

  /// How many paintings keep the rule at all, the one-colour ones included.
  final int legal;

  /// The taps from the opening to the nearest painting that lands it; null
  /// when none does.
  final int? fewest;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  int get arcs => Rules.arcs(strands, word);

  List<(int, int, int)> get crossings => Rules.crossings(strands, word);

  /// Every painting there is of this plait's arcs.
  int get allPaintings {
    var n = 1;
    for (var i = 0; i < arcs; i++) {
      n *= Rules.colours;
    }
    return n;
  }

  /// Whether this painting lands the ask.
  bool meets(List<int> paint) =>
      Rules.legal(crossings, paint) && Rules.full(paint);

  /// The task, told in words.
  String get task => 'paint the ${word.length} crossings of $knot so each '
      'shows one colour or three, and use all three';
}
