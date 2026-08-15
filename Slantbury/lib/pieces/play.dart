import 'geometry.dart';
import 'level.dart';
import 'rules.dart';

/// A frame being laid. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.level, this.rules, this.layings, this.ways, this.held, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, level.rules, const [null, null, null, null], const [(0, false), (0, false), (0, false), (0, false)], null, 0, null);

  /// A play stood at a laying, for the mark and the tests.
  factory Play.standing(Level level, List<Laying> laid) => Play._(
      level, level.rules, List.of(laid), [for (final l in laid) (l.turn, l.flipped)], null, laid.length, null);

  final Level level;
  final Rules rules;

  /// Where each piece lies, or null for one still in the tray.
  final List<Laying?> layings;

  /// Which way each piece is turned and whether flipped, tray or frame.
  final List<(int, bool)> ways;

  /// The piece in hand, if any.
  final int? held;

  /// Pieces laid, counted; taking up, turning and flipping are free.
  final int moves;

  final Play? before;

  /// The line past which the hopeless frame admits it, if the sliver
  /// has not shown it first.
  static const gaveUpAt = 24;

  bool laidDown(int p) => layings[p] != null;

  int get laidCount => layings.where((l) => l != null).length;

  bool get allLaid => laidCount == 4;

  /// Piece [p]'s corners on the frame, or null in the tray.
  List<Pt>? cornersOf(int p) {
    final l = layings[p];
    return l == null ? null : rules.laid(p, l);
  }

  /// The polygons two laid pieces share, pair by pair, with the pair.
  List<((int, int), List<Pt>)> get overlaps {
    final out = <((int, int), List<Pt>)>[];
    for (var p = 0; p < 4; p++) {
      for (var q = p + 1; q < 4; q++) {
        final lp = layings[p], lq = layings[q];
        if (lp == null || lq == null) continue;
        if (rules.overlap2(p, lp, q, lq).sign == 0) continue;
        out.add(((p, q), shared(rules.laid(p, lp), rules.laid(q, lq))));
      }
    }
    return out;
  }

  /// Twice the area the laid pieces share.
  Q get overlap2 {
    var sum = Q.zero;
    for (final (_, poly) in overlaps) {
      sum = sum + area2(poly);
    }
    return sum;
  }

  /// The area shared, in squares.
  Q get overlap => overlap2 / Q(2);

  /// Twice the frame left bare, once all four are laid; the frame less
  /// what is laid, plus what is shared, before that.
  Q get gap2 {
    var laid2 = Q.zero;
    for (var p = 0; p < 4; p++) {
      if (layings[p] != null) laid2 = laid2 + rules.pieces[p].area2;
    }
    return rules.frame2 - laid2 + overlap2;
  }

  Q get gap => gap2 / Q(2);

  bool get isDone =>
      allLaid && overlap2 <= level.overlapAllowed2 && (!level.mustFill || gap2.sign == 0);

  /// The sliver has shown: all four inside with no overlap and a square
  /// still bare, which the hopeless frame can never mend.
  bool get sliverShown => !level.winnable && allLaid && overlap2.sign == 0;

  bool get gaveUp => !level.winnable && !isDone && (sliverShown || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// Takes up piece [p], from the tray or off the frame; taking up the
  /// piece in hand puts it down in the tray.
  Play hold(int p) {
    if (isOver || p < 0 || p > 3) return this;
    if (held == p) return Play._(level, rules, layings, ways, null, moves, this);
    final next = [for (var i = 0; i < 4; i++) i == p ? null : layings[i]];
    return Play._(level, rules, next, ways, p, moves, this);
  }

  /// Turns the piece in hand a quarter turn.
  Play get turn {
    final p = held;
    if (p == null || isOver) return this;
    final (t, f) = ways[p];
    final next = [for (var i = 0; i < 4; i++) i == p ? ((t + 1) % 4, f) : ways[i]];
    return Play._(level, rules, layings, next, held, moves, this);
  }

  /// Flips the piece in hand left for right.
  Play get flip {
    final p = held;
    if (p == null || isOver) return this;
    final (t, f) = ways[p];
    final next = [for (var i = 0; i < 4; i++) i == p ? (t, !f) : ways[i]];
    return Play._(level, rules, layings, next, held, moves, this);
  }

  /// Sets the piece in hand to lie as [way] says, for the show-me.
  Play turnTo(int p, (int, bool) way) {
    if (isOver) return this;
    final next = [for (var i = 0; i < 4; i++) i == p ? way : ways[i]];
    return Play._(level, rules, layings, next, held, moves, this);
  }

  /// Lays the piece in hand with its box's corner at ([x], [y]), if that
  /// keeps it inside the frame.
  Play lay(int x, int y) {
    final p = held;
    if (p == null || isOver) return this;
    final (t, f) = ways[p];
    final laying = Laying(t, f, x, y);
    if (!rules.inside(p, laying)) return this;
    final next = [for (var i = 0; i < 4; i++) i == p ? laying : layings[i]];
    return Play._(level, rules, next, ways, null, moves + 1, this);
  }

  /// Undoes the last laying, or puts the piece in hand down.
  Play get back {
    final was = before;
    if (was == null) return held == null ? this : Play._(level, rules, layings, ways, null, moves, null);
    if (was.moves < moves) return Play._(level, rules, was.layings, was.ways, null, was.moves, was.before);
    return was.back;
  }

  /// What the show-me points at: ('lift', piece) for a laid piece off the
  /// aimed laying, else ('lay', piece) for the first piece not laid, to
  /// go where the aim says; null when nothing lands.
  (String, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    for (var p = 0; p < 4; p++) {
      final l = layings[p];
      if (l != null && l != aim[p]) return ('lift', p);
    }
    final hand = held;
    if (hand != null && layings[hand] == null) return ('lay', hand);
    for (var p = 0; p < 4; p++) {
      if (layings[p] == null) return ('lay', p);
    }
    return null;
  }

  /// The sweep's first laying meeting the ask, kept once found.
  static List<Laying>? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      final (_, _, first) = level.rules.sweep(overlapAllowed2: level.overlapAllowed2, mustFill: level.mustFill);
      _aims[level.name] = first;
    }
    return _aims[level.name];
  }

  static final _aims = <String, List<Laying>?>{};
}
